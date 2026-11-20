#pragma once

#include <QColor>
#include <QPoint>
#include <QProcess>
#include <QQuickPaintedItem>
#include <QSocketNotifier>
#include <QUrl>
#include <deque>
#include <vterm.h>

class TerminalSession : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(QString error READ error NOTIFY runningChanged)
public:
    explicit TerminalSession(QObject *parent=nullptr);
    ~TerminalSession() override;
    Q_INVOKABLE void start(const QUrl &commandFolder, bool posix=false);
    Q_INVOKABLE bool stageDraft(const QString &line);
    bool running() const {return process.state()!=QProcess::NotRunning;}
    QString error() const {return failure;}
    void resize(int rowCount, int columnCount);
    int historySize() const {return alternate ? 0 : int(history.size());}
    VTermScreenCell cell(int line, int column) const;
    QString lineText(int line, int left, int right) const;
    QColor color(VTermColor color, bool dark) const;
    void send(QByteArray bytes);
    void paste(const QString &text);
    void readOutput();

    VTerm *term;
    VTermScreen *screen;
    VTermPos cursor{0,0};
    bool cursorVisible=true;
    int rows=24, columns=80, mouseMode=0;
signals:
    void changed(int scrolled);
    void runningChanged();
private:
    void flushInput();
    void closeMaster();
    QProcess process;
    QSocketNotifier *reader=nullptr, *writer=nullptr;
    QByteArray input;
    QString failure;
    std::deque<QVector<VTermScreenCell>> history;
    int master=-1, addedRows=0;
    bool alternate=false;
};

class TerminalView : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY(TerminalSession* session READ session WRITE setSession NOTIFY sessionChanged)
    Q_PROPERTY(bool readOnly MEMBER readOnly NOTIFY appearanceChanged)
    Q_PROPERTY(bool dark MEMBER dark NOTIFY appearanceChanged)
    Q_PROPERTY(int fontSize MEMBER fontSize NOTIFY appearanceChanged)
    Q_PROPERTY(QColor backgroundColor MEMBER backgroundColor NOTIFY appearanceChanged)
    Q_PROPERTY(QColor foregroundColor MEMBER foregroundColor NOTIFY appearanceChanged)
    Q_PROPERTY(QColor cursorColor MEMBER cursorColor NOTIFY appearanceChanged)
    Q_PROPERTY(qreal surfaceOpacity MEMBER surfaceOpacity NOTIFY appearanceChanged)
    Q_PROPERTY(bool hasSelection READ hasSelection NOTIFY selectionChanged)
public:
    explicit TerminalView(QQuickItem *parent=nullptr);
    TerminalSession *session() const {return terminal;}
    void setSession(TerminalSession *value);
    bool hasSelection() const {return first.x()>=0 && first!=last;}
    Q_INVOKABLE void copy();
    Q_INVOKABLE void paste();
    Q_INVOKABLE bool find(const QString &query, bool backwards=false);
    void paint(QPainter *painter) override;
signals:
    void sessionChanged();
    void appearanceChanged();
    void selectionChanged();
protected:
    void geometryChange(const QRectF &now, const QRectF &before) override;
    void keyPressEvent(QKeyEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void wheelEvent(QWheelEvent *event) override;
    void focusInEvent(QFocusEvent *event) override;
    void focusOutEvent(QFocusEvent *event) override;
    void inputMethodEvent(QInputMethodEvent *event) override;
    QVariant inputMethodQuery(Qt::InputMethodQuery query) const override;
private:
    void updateGeometry();
    void scroll(int lines);
    int firstLine() const;
    QPoint position(QPointF point) const;
    QRectF cursorRect() const;
    QString selection() const;
    void setSelection(QPoint from, QPoint to);
    TerminalSession *terminal=nullptr;
    QFont font;
    QColor backgroundColor,foregroundColor,cursorColor;
    qreal surfaceOpacity=1;
    qreal cellWidth=8, cellHeight=18, ascent=14;
    int visibleRows=1, visibleColumns=1, offset=0, matchLine=-1, matchColumn=-1;
    int fontSize=16;
    bool dark=true, readOnly=false, mouseForwarded=false;
    QPoint first{-1,-1}, last{-1,-1};
    static constexpr int padding=9;
};
