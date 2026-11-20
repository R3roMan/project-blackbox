#include "terminal.h"

#include <QClipboard>
#include <QCursor>
#include <QDesktopServices>
#include <QRegularExpression>
#include <QDir>
#include <QFileInfo>
#include <QFontDatabase>
#include <QFontMetricsF>
#include <QGuiApplication>
#include <QInputMethodEvent>
#include <QKeyEvent>
#include <QPainter>
#include <QWheelEvent>
#include <QUuid>
#include <cerrno>
#include <cmath>
#include <fcntl.h>
#include <pty.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <unistd.h>

namespace {
constexpr int historyLimit=1800;
constexpr int inputLimit=1024*1024;
VTermModifier mods(Qt::KeyboardModifiers value) {
    return VTermModifier((value&Qt::ShiftModifier ? VTERM_MOD_SHIFT : 0)
        | (value&Qt::AltModifier ? VTERM_MOD_ALT : 0)
        | (value&Qt::ControlModifier ? VTERM_MOD_CTRL : 0));
}
bool before(QPoint left, QPoint right) {
    return left.y()<right.y() || (left.y()==right.y() && left.x()<right.x());
}
}

TerminalSession::TerminalSession(QObject *parent)
    :QObject(parent),term(vterm_new(24,80)),screen(vterm_obtain_screen(term)) {
    static const VTermScreenCallbacks callbacks{
        nullptr,nullptr,
        [](VTermPos pos,VTermPos,int visible,void *owner) {
            auto *session=static_cast<TerminalSession*>(owner);
            session->cursor=pos;
            session->cursorVisible=visible;
            return 1;
        },
        [](VTermProp property,VTermValue *value,void *owner) {
            auto *session=static_cast<TerminalSession*>(owner);
            if(property==VTERM_PROP_CURSORVISIBLE) session->cursorVisible=value->boolean;
            if(property==VTERM_PROP_ALTSCREEN) session->alternate=value->boolean;
            if(property==VTERM_PROP_MOUSE) session->mouseMode=value->number;
            return 1;
        },
        nullptr,nullptr,
        [](int columns,const VTermScreenCell *cells,void *owner) {
            auto *session=static_cast<TerminalSession*>(owner);
            session->history.emplace_back(cells,cells+columns);
            if(session->history.size()>historyLimit) session->history.pop_front();
            ++session->addedRows;
            return 1;
        },
        [](int columns,VTermScreenCell *cells,void *owner) {
            auto *session=static_cast<TerminalSession*>(owner);
            if(session->history.empty()) return 0;
            const auto &line=session->history.back();
            for(int column=0;column<columns;++column) {
                if(column<line.size()) cells[column]=line.at(column);
                else {
                    cells[column]=VTermScreenCell{};
                    cells[column].width=1;
                    vterm_state_get_default_colors(vterm_obtain_state(session->term),&cells[column].fg,&cells[column].bg);
                }
            }
            session->history.pop_back();
            return 1;
        },
        [](void *owner) {
            static_cast<TerminalSession*>(owner)->history.clear();
            return 1;
        }
    };
    vterm_set_utf8(term,1);
    vterm_screen_enable_altscreen(screen,1);
    vterm_screen_enable_reflow(screen,true);
    vterm_screen_set_callbacks(screen,&callbacks,this);
    vterm_screen_reset(screen,1);
    vterm_output_set_callback(term,[](const char *bytes,size_t size,void *owner) {
        static_cast<TerminalSession*>(owner)->send(QByteArray(bytes,size));
    },this);
    connect(&process,&QProcess::stateChanged,this,&TerminalSession::runningChanged);
    connect(&process,&QProcess::errorOccurred,this,[this](QProcess::ProcessError error) {
        if(error!=QProcess::FailedToStart) return;
        failure=process.errorString();
        closeMaster();
        emit runningChanged();
    });
    connect(&process,qOverload<int,QProcess::ExitStatus>(&QProcess::finished),this,[this](int code,QProcess::ExitStatus) {
        if(code==126) failure=QStringLiteral("Unable to attach the shell to its terminal.");
        readOutput();
        closeMaster();
        emit runningChanged();
    });
}

TerminalSession::~TerminalSession() {
    disconnect(&process,nullptr,this,nullptr);
    closeMaster();
    if(process.state()!=QProcess::NotRunning) {
        process.kill();
        process.waitForFinished(150);
    }
    vterm_free(term);
}

void TerminalSession::start(const QUrl &commandFolder,bool posix) {
    if(running() || !commandFolder.isLocalFile()) return;
    failure.clear();
    const QString shell=qEnvironmentVariable("SHELL");
    const QString executable=!posix && QFileInfo(shell).isAbsolute() && QFileInfo(shell).isExecutable()
        ? shell : QStringLiteral("/bin/sh");
    winsize size{};
    size.ws_row=rows;
    size.ws_col=columns;
    int slave=-1;
    if(openpty(&master,&slave,nullptr,nullptr,&size)<0) {
        failure=QStringLiteral("Unable to open a Linux terminal.");
        emit runningChanged();
        return;
    }
    fcntl(master,F_SETFD,FD_CLOEXEC);
    fcntl(slave,F_SETFD,FD_CLOEXEC);
    fcntl(master,F_SETFL,fcntl(master,F_GETFL)|O_NONBLOCK);
    reader=new QSocketNotifier(master,QSocketNotifier::Read,this);
    writer=new QSocketNotifier(master,QSocketNotifier::Write,this);
    writer->setEnabled(false);
    connect(reader,&QSocketNotifier::activated,this,&TerminalSession::readOutput);
    connect(writer,&QSocketNotifier::activated,this,&TerminalSession::flushInput);
    auto env=QProcessEnvironment::systemEnvironment();
    env.insert("PATH",commandFolder.toLocalFile()+QLatin1Char(':')+env.value("PATH"));
    env.insert("TERM","xterm-256color");
    env.insert("COLORTERM","truecolor");
    env.insert("TERM_PROGRAM","PureCode");
    env.insert("BLACKBOX_TERMINAL_SESSION",QUuid::createUuid().toString(QUuid::WithoutBraces));
    QString home=QDir::homePath();
    const bool preview=qEnvironmentVariable("BLACKBOX_PREVIEW")=="1";
    if(preview) {
        home=QDir(qEnvironmentVariable("BLACKBOX_DESKTOP_DIR")).absoluteFilePath("../terminal-home");
        QDir().mkpath(home);
        env.insert("HOME",home);
        env.insert("ZDOTDIR",home);
        env.remove("HISTFILE");
    }
    process.setProcessEnvironment(env);
    process.setWorkingDirectory(home);
    // Qt creates the only child. These POSIX operations run between fork and exec.
    process.setChildProcessModifier([slave] {
        if(setsid()<0 || ioctl(slave,TIOCSCTTY,0)<0) _exit(126);
        for(int descriptor=0;descriptor<3;++descriptor)
            if(dup2(slave,descriptor)<0) _exit(126);
    });
    QStringList arguments{"-i"};
    if(QFileInfo(executable).fileName()=="zsh") {
        arguments << "-o" << "NO_EQUALS";
        if(preview) arguments << "-f";
    }
    process.start(executable,arguments);
    close(slave);
}

void TerminalSession::closeMaster() {
    delete reader; reader=nullptr;
    delete writer; writer=nullptr;
    if(master>=0) close(master);
    master=-1;
    input.clear();
}

void TerminalSession::resize(int rowCount,int columnCount) {
    if(rows==rowCount && columns==columnCount) return;
    rows=rowCount;
    columns=columnCount;
    addedRows=0;
    vterm_set_size(term,rows,columns);
    if(master>=0) {
        winsize size{};
        size.ws_row=rows;
        size.ws_col=columns;
        ioctl(master,TIOCSWINSZ,&size);
    }
    emit changed(addedRows);
}

void TerminalSession::readOutput() {
    if(master<0) return;
    addedRows=0;
    bool updated=false;
    char buffer[8192];
    // Bound work per wakeup so a noisy job leaves Plasma responsive.
    for(int chunk=0;chunk<8;++chunk) {
        const auto count=read(master,buffer,sizeof(buffer));
        if(count<=0) {
            if((count==0 || (errno!=EAGAIN && errno!=EINTR)) && reader) reader->setEnabled(false);
            break;
        }
        vterm_input_write(term,buffer,size_t(count));
        updated=true;
    }
    if(updated) {
        vterm_screen_flush_damage(screen);
        emit changed(addedRows);
    }
}

void TerminalSession::send(QByteArray bytes) {
    if(master<0 || input.size()+bytes.size()>inputLimit) return;
    input.append(bytes);
    flushInput();
}

void TerminalSession::flushInput() {
    if(master<0 || !writer) return;
    if(!input.isEmpty()) {
        const auto written=write(master,input.constData(),size_t(input.size()));
        if(written>0) input.remove(0,written);
        else if(written<0 && errno!=EAGAIN && errno!=EINTR) input.clear();
    }
    writer->setEnabled(!input.isEmpty());
}

bool TerminalSession::stageDraft(const QString &line) {
    if(master<0 || !running() || line.isEmpty() || line.size()>1200 || tcgetpgrp(master)!=process.processId())
        return false;
    for(const auto character:line)
        if(!character.isPrint()) return false;
    paste(line);
    return true;
}

void TerminalSession::paste(const QString &text) {
    QByteArray bytes=text.toUtf8();
    if(bytes.isEmpty() || bytes.size()>inputLimit/2) return;
    bytes.replace("\r\n","\r");
    bytes.replace('\n','\r');
    bytes.removeIf([](char c){return (c>=0 && c<32 && c!='\t' && c!='\r') || c==127;});
    vterm_keyboard_start_paste(term);
    send(std::move(bytes));
    vterm_keyboard_end_paste(term);
}

VTermScreenCell TerminalSession::cell(int line,int column) const {
    VTermScreenCell result{};
    vterm_state_get_default_colors(vterm_obtain_state(term),&result.fg,&result.bg);
    result.width=1;
    if(line<0 || column<0) return result;
    if(line<historySize()) {
        const auto &row=history.at(size_t(line));
        if(column<row.size()) return row.at(column);
    } else if(line<historySize()+rows && column<columns)
        vterm_screen_get_cell(screen,{line-historySize(),column},&result);
    return result;
}

QString TerminalSession::lineText(int line,int left,int right) const {
    QString result;
    for(int col=left;col<right;++col) {
        const auto value=cell(line,col);
        if(value.chars[0]==UINT32_MAX) continue;
        if(!value.chars[0]) result+=QLatin1Char(' ');
        for(char32_t ch:value.chars) {
            if(!ch) break;
            result+=QString::fromUcs4(&ch,1);
        }
    }
    while(result.endsWith(QLatin1Char(' '))) result.chop(1);
    return result;
}

QColor TerminalSession::color(VTermColor value,bool dark) const {
    if(VTERM_COLOR_IS_DEFAULT_FG(&value)) return dark ? QColor("#deeee7") : QColor("#1b2826");
    if(VTERM_COLOR_IS_DEFAULT_BG(&value)) return dark ? QColor("#10151a") : QColor("#eff4f1");
    if(VTERM_COLOR_IS_INDEXED(&value) && value.indexed.idx<16) {
        static const char *darkPalette[]={"#1b2428","#ee7b86","#9ed89b","#edc98e","#8fb7ec","#d3a3ea","#9bd4d1","#d4dcd9",
            "#718086","#ff9da6","#c1efb8","#ffe3b1","#b0ccff","#eec6fc","#c0f2ed","#ffffff"};
        static const char *lightPalette[]={"#172421","#a12c46","#2c6536","#805413","#254e95","#7f3e95","#226c67","#566a65",
            "#455554","#a93b4e","#267035","#795a20","#315ba0","#7b4b90","#21736a","#3a4945"};
        return QColor((dark ? darkPalette : lightPalette)[value.indexed.idx]);
    }
    vterm_screen_convert_color_to_rgb(screen,&value);
    return QColor(value.rgb.red,value.rgb.green,value.rgb.blue);
}

TerminalView::TerminalView(QQuickItem *parent):QQuickPaintedItem(parent) {
    setAcceptedMouseButtons(Qt::LeftButton);
    setAcceptHoverEvents(false);
    setFlag(ItemAcceptsInputMethod,true);
    setActiveFocusOnTab(true);
    setCursor(QCursor(Qt::IBeamCursor));
    connect(this,&TerminalView::appearanceChanged,this,&TerminalView::updateGeometry);
}

void TerminalView::setSession(TerminalSession *value) {
    if(value==terminal) return;
    if(terminal) disconnect(terminal,nullptr,this,nullptr);
    terminal=value;
    offset=0;
    setSelection({-1,-1},{-1,-1});
    if(terminal) {
        connect(terminal,&QObject::destroyed,this,[this] {terminal=nullptr;emit sessionChanged();update();});
        connect(terminal,&TerminalSession::changed,this,[this](int scrolled) {
            if(offset>0) offset=qBound(0,offset+scrolled,qMax(0,terminal->historySize()+terminal->rows-visibleRows));
            update();
        });
    }
    emit sessionChanged();
    updateGeometry();
}

void TerminalView::geometryChange(const QRectF &now,const QRectF &before) {
    QQuickPaintedItem::geometryChange(now,before);
    updateGeometry();
}

void TerminalView::updateGeometry() {
    font=QFontDatabase::systemFont(QFontDatabase::FixedFont);
    font.setPixelSize(qBound(8,fontSize,28));
    const QFontMetricsF metrics(font);
    cellWidth=qMax(3.,std::ceil(metrics.horizontalAdvance(QLatin1Char('M'))));
    cellHeight=qMax(8.,std::ceil(metrics.height())+1);
    ascent=metrics.ascent();
    visibleRows=qBound(2,int((height()-padding*2)/cellHeight),240);
    visibleColumns=qBound(2,int((width()-padding*2)/cellWidth),380);
    if(terminal && !readOnly && width()>2*padding && height()>2*padding)
        terminal->resize(visibleRows,visibleColumns);
    update();
}

int TerminalView::firstLine() const {
    return terminal ? qMax(0,terminal->historySize()+terminal->rows-visibleRows-offset) : 0;
}

QPoint TerminalView::position(QPointF point) const {
    return {qBound(0,int((point.x()-padding)/cellWidth),visibleColumns-1),
        firstLine()+qBound(0,int((point.y()-padding)/cellHeight),visibleRows-1)};
}

QRectF TerminalView::cursorRect() const {
    if(!terminal) return {};
    const int row=terminal->historySize()+terminal->cursor.row-firstLine();
    return {padding+terminal->cursor.col*cellWidth,padding+row*cellHeight,cellWidth,cellHeight};
}

void TerminalView::paint(QPainter *painter) {
    const QColor background=backgroundColor.isValid() && backgroundColor.alpha()>0 ? backgroundColor : (dark ? QColor("#10151a") : QColor("#eff4f1"));
    auto surface=background;
    surface.setAlphaF(qBound(0.,surfaceOpacity,1.));
    painter->fillRect(boundingRect(),surface);
    if(!terminal) return;
    painter->setFont(font);
    QFont styled=font;
    const int from=firstLine();
    QPoint low=first, high=last;
    if(before(high,low)) std::swap(low,high);
    const bool selected=hasSelection();
    const int lines=qMin(visibleRows,terminal->historySize()+terminal->rows-from);
    const int columns=qMin(visibleColumns,terminal->columns);
    for(int row=0;row<lines;++row) {
        const int absolute=from+row;
        const qreal y=padding+row*cellHeight;
        for(int col=0;col<columns;++col) {
            const auto value=terminal->cell(absolute,col);
            if(value.chars[0]==UINT32_MAX) continue;
            QColor fg=foregroundColor.isValid() && foregroundColor.alpha()>0 && VTERM_COLOR_IS_DEFAULT_FG(&value.fg)
                ? foregroundColor : terminal->color(value.fg,dark);
            QColor bg=VTERM_COLOR_IS_DEFAULT_BG(&value.bg) ? background : terminal->color(value.bg,dark);
            if(value.attrs.reverse) std::swap(fg,bg);
            const QPoint position{col,absolute};
            if(selected && !before(position,low) && !before(high,position))
                bg=dark ? QColor("#305752") : QColor("#c0dbd1");
            const qreal x=padding+col*cellWidth;
            if(bg!=background)
                painter->fillRect(QRectF(x,y,cellWidth*qMax(1,int(value.width)),cellHeight),bg);
            if(!value.chars[0] || value.attrs.conceal) continue;
            char32_t glyph[VTERM_MAX_CHARS_PER_CELL];
            int length=0;
            while(length<VTERM_MAX_CHARS_PER_CELL && value.chars[length]) {
                glyph[length]=value.chars[length];
                ++length;
            }
            const bool underline=value.attrs.underline!=0;
            if(styled.bold()!=bool(value.attrs.bold) || styled.italic()!=bool(value.attrs.italic)
                || styled.underline()!=underline || styled.strikeOut()!=bool(value.attrs.strike)) {
                styled.setBold(value.attrs.bold);
                styled.setItalic(value.attrs.italic);
                styled.setUnderline(underline);
                styled.setStrikeOut(value.attrs.strike);
                painter->setFont(styled);
            }
            painter->setPen(fg);
            painter->drawText(QPointF(x,y+ascent),QString::fromUcs4(glyph,length));
        }
    }
    if(hasActiveFocus() && terminal->running() && terminal->cursorVisible && !readOnly && offset==0) {
        const QRectF caret=cursorRect();
        painter->fillRect(QRectF(caret.x(),caret.bottom()-2,cellWidth,2),cursorColor.isValid() ? cursorColor : (dark ? QColor("#a8dfc8") : QColor("#26634e")));
    }
}

void TerminalView::setSelection(QPoint from,QPoint to) {
    first=from;
    last=to;
    emit selectionChanged();
    update();
}

QString TerminalView::selection() const {
    if(!hasSelection() || !terminal) return {};
    QPoint low=first, high=last;
    if(before(high,low)) std::swap(low,high);
    QString text;
    for(int line=low.y();line<=high.y();++line) {
        if(line>low.y()) text+=QLatin1Char('\n');
        text+=terminal->lineText(line,line==low.y() ? low.x() : 0, line==high.y() ? high.x()+1 : terminal->columns);
    }
    return text;
}

void TerminalView::copy() {
    const auto text=selection();
    if(!text.isEmpty()) QGuiApplication::clipboard()->setText(text);
}

void TerminalView::paste() {
    if(!terminal || readOnly) return;
    offset=0;
    terminal->paste(QGuiApplication::clipboard()->text());
}

void TerminalView::scroll(int lines) {
    if(!terminal) return;
    offset=qBound(0,offset+lines,qMax(0,terminal->historySize()+terminal->rows-visibleRows));
    update();
}

bool TerminalView::find(const QString &query,bool backwards) {
    if(!terminal || query.isEmpty()) {
        matchLine=-1;
        setSelection({-1,-1},{-1,-1});
        return false;
    }
    const int total=terminal->historySize()+terminal->rows;
    const int start=matchLine>=0 && matchLine<total ? matchLine : (backwards ? total-1 : 0);
    const int direction=backwards ? -1 : 1;
    for(int i=0;i<=total;++i) {
        const int row=(start+i*direction+2*total)%total;
        const QString text=terminal->lineText(row,0,terminal->columns);
        const int index=backwards ? text.lastIndexOf(query,i==0 && matchLine>=0 ? matchColumn-1 : -1,Qt::CaseInsensitive)
            : text.indexOf(query,i==0 && matchLine>=0 ? matchColumn+1 : 0,Qt::CaseInsensitive);
        if(index<0 || (backwards && i==0 && matchLine>=0 && matchColumn==0)) continue;
        matchLine=row;
        matchColumn=index;
        offset=qBound(0,total-qMax(0,row-visibleRows/2)-visibleRows,qMax(0,total-visibleRows));
        setSelection({index,row},{index+int(query.size())-1,row});
        return true;
    }
    return false;
}

void TerminalView::keyPressEvent(QKeyEvent *event) {
    if(!terminal) {event->ignore();return;}
    const int key=event->key();
    const auto modifiers=event->modifiers();
    const bool shifted=modifiers&Qt::ShiftModifier, controlled=modifiers&Qt::ControlModifier;
    if(controlled && shifted && key==Qt::Key_C) {copy();return;}
    if((controlled && shifted && key==Qt::Key_V) || (shifted && key==Qt::Key_Insert)) {paste();return;}
    if((shifted || readOnly) && (key==Qt::Key_PageUp || key==Qt::Key_PageDown)) {
        scroll(key==Qt::Key_PageUp ? visibleRows : -visibleRows);
        return;
    }
    if(readOnly || !terminal->running()) {event->ignore();return;}
    VTermKey mapped=VTERM_KEY_NONE;
    switch(key) {
        case Qt::Key_Return: case Qt::Key_Enter:mapped=VTERM_KEY_ENTER;break;
        case Qt::Key_Tab: case Qt::Key_Backtab:mapped=VTERM_KEY_TAB;break;
        case Qt::Key_Escape:mapped=VTERM_KEY_ESCAPE;break;
        case Qt::Key_Backspace:mapped=VTERM_KEY_BACKSPACE;break;
        case Qt::Key_Up:mapped=VTERM_KEY_UP;break;
        case Qt::Key_Down:mapped=VTERM_KEY_DOWN;break;
        case Qt::Key_Left:mapped=VTERM_KEY_LEFT;break;
        case Qt::Key_Right:mapped=VTERM_KEY_RIGHT;break;
        case Qt::Key_Home:mapped=VTERM_KEY_HOME;break;
        case Qt::Key_End:mapped=VTERM_KEY_END;break;
        case Qt::Key_Delete:mapped=VTERM_KEY_DEL;break;
        case Qt::Key_Insert:mapped=VTERM_KEY_INS;break;
        case Qt::Key_PageUp:mapped=VTERM_KEY_PAGEUP;break;
        case Qt::Key_PageDown:mapped=VTERM_KEY_PAGEDOWN;break;
        default:
            if(key>=Qt::Key_F1 && key<=Qt::Key_F12) mapped=VTermKey(VTERM_KEY_FUNCTION(key-Qt::Key_F1+1));
            break;
    }
    offset=0;
    if(mapped!=VTERM_KEY_NONE) vterm_keyboard_key(terminal->term,mapped,mods(modifiers));
    else if(controlled && key>=Qt::Key_A && key<=Qt::Key_Z)
        vterm_keyboard_unichar(terminal->term,'a'+key-Qt::Key_A,mods(modifiers));
    else if(controlled && key==Qt::Key_Space) terminal->send(QByteArray(1,'\0'));
    else if(!event->text().isEmpty())
        for(auto ch:event->text().toUcs4()) vterm_keyboard_unichar(terminal->term,ch,mods(modifiers&~Qt::ShiftModifier));
    else event->ignore();
    update();
}

void TerminalView::mousePressEvent(QMouseEvent *event) {
    if(!terminal) {event->ignore();return;}
    forceActiveFocus(Qt::MouseFocusReason);
    const QPoint cell=position(event->position());
    if(event->modifiers()==Qt::ControlModifier) {
        static const QRegularExpression urlPattern(QStringLiteral("(?:file|https?)://[^\\s<>]+"));
        const QString line=terminal->lineText(cell.y(),0,terminal->columns);
        auto urls=urlPattern.globalMatch(line);
        while(urls.hasNext()) {
            const auto match=urls.next();
            if(cell.x()>=match.capturedStart() && cell.x()<match.capturedEnd()) {
                QDesktopServices::openUrl(QUrl(match.captured()));
                return;
            }
        }
    }
    mouseForwarded=!readOnly && terminal->mouseMode && offset==0 && !(event->modifiers()&Qt::ShiftModifier);
    if(mouseForwarded) {
        vterm_mouse_move(terminal->term,cell.y()-terminal->historySize(),cell.x(),mods(event->modifiers()));
        vterm_mouse_button(terminal->term,1,true,mods(event->modifiers()));
    } else setSelection(cell,cell);
}

void TerminalView::mouseMoveEvent(QMouseEvent *event) {
    if(!terminal) return;
    const QPoint cell=position(event->position());
    if(mouseForwarded) vterm_mouse_move(terminal->term,cell.y()-terminal->historySize(),cell.x(),mods(event->modifiers()));
    else setSelection(first,cell);
}

void TerminalView::mouseReleaseEvent(QMouseEvent *event) {
    if(!terminal) return;
    if(mouseForwarded) vterm_mouse_button(terminal->term,1,false,mods(event->modifiers()));
    mouseForwarded=false;
}

void TerminalView::wheelEvent(QWheelEvent *event) {
    if(!terminal) {event->ignore();return;}
    const int delta=event->angleDelta().y();
    if(!readOnly && terminal->mouseMode && offset==0 && !(event->modifiers()&Qt::ShiftModifier)) {
        const QPoint cell=position(event->position());
        vterm_mouse_move(terminal->term,cell.y()-terminal->historySize(),cell.x(),mods(event->modifiers()));
        vterm_mouse_button(terminal->term,delta>0 ? 4 : 5,true,mods(event->modifiers()));
    } else scroll(delta==0 ? event->pixelDelta().y()/4 : delta/40);
    event->accept();
}

void TerminalView::focusInEvent(QFocusEvent *event) {QQuickPaintedItem::focusInEvent(event);update();}
void TerminalView::focusOutEvent(QFocusEvent *event) {QQuickPaintedItem::focusOutEvent(event);update();}
void TerminalView::inputMethodEvent(QInputMethodEvent *event) {
    if(terminal && !readOnly && !event->commitString().isEmpty()) terminal->send(event->commitString().toUtf8());
}
QVariant TerminalView::inputMethodQuery(Qt::InputMethodQuery query) const {
    if(query==Qt::ImEnabled) return !readOnly;
    if(query==Qt::ImCursorRectangle) return cursorRect();
    return QQuickPaintedItem::inputMethodQuery(query);
}
