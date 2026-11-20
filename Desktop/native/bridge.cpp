#include <QtQml/QQmlExtensionPlugin>
#include <QtQml/qqml.h>
#include <QtQml/QQmlEngine>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include <QtCore/QSaveFile>
#include <QtCore/QUuid>
#include <QtGui/QDesktopServices>
#include <QtCore/QMap>
#include <QtCore/QDir>
#include <QtCore/QTimer>
#include <QtCore/QProcess>
#include <QtCore/QSettings>
#include <QtCore/QDateTime>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonArray>
#include <QtCore/QCoreApplication>
#include <QtCore/QCryptographicHash>
#include <QtCore/QRegularExpression>
#include <QtCore/QJsonObject>
#include <QtCore/QStandardPaths>
#include <QtCore/QPointer>
#include <QtDBus/QtDBus>
#include <QtGui/QGuiApplication>
#include <QtGui/QKeyEvent>
#include <QtGui/QMouseEvent>
#include <QtGui/QScreen>
#include <QtGui/QWindow>
#include <cmath>
#include <cstring>
#include <utility>
#include "terminal.h"

class DesktopBridge final : public QObject {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.projectblackbox.Desktop")
    Q_PROPERTY(bool atHome READ atHome NOTIFY visibilityChanged)
    Q_PROPERTY(bool showingDesktop READ showingDesktop NOTIFY visibilityChanged)
    Q_PROPERTY(bool cubeActive READ cubeActive NOTIFY cubeActiveChanged)
    Q_PROPERTY(QRect appPerch READ appPerch NOTIFY perchChanged)
    Q_PROPERTY(QVariantList appPerches READ appPerches NOTIFY perchChanged)
    Q_PROPERTY(bool fullscreenApp READ fullscreenApp NOTIFY perchChanged)
    Q_PROPERTY(bool visibilityReady READ visibilityReady NOTIFY visibilityChanged)
    Q_PROPERTY(bool sessionLocked READ sessionLocked NOTIFY visibilityChanged)
    Q_PROPERTY(bool hasSave READ hasSave NOTIFY stateChanged)
    Q_PROPERTY(double cpu READ cpu NOTIFY sensorsChanged)
    Q_PROPERTY(double gpu READ gpu NOTIFY sensorsChanged)
    Q_PROPERTY(double loudness READ loudness NOTIFY sensorsChanged)
    Q_PROPERTY(QVariantList bands READ bands NOTIFY sensorsChanged)
    Q_PROPERTY(QString audioStatus READ audioStatus NOTIFY sensorsChanged)
    Q_PROPERTY(QVariantMap state READ state NOTIFY stateChanged)
    Q_PROPERTY(QVariantMap config READ config NOTIFY configChanged)
    Q_PROPERTY(QString desktopFront READ desktopFront NOTIFY workspaceChanged)
    Q_PROPERTY(QStringList screens READ screens NOTIFY screensChanged)
    Q_PROPERTY(bool wallpaperActive READ wallpaperActive NOTIFY wallpaperActiveChanged)
    Q_PROPERTY(bool darkPanel READ darkPanel NOTIFY panelStyleChanged)
    Q_PROPERTY(bool darkApps READ darkApps NOTIFY panelStyleChanged)
    Q_PROPERTY(bool panelStyleBusy READ panelStyleBusy NOTIFY panelStyleChanged)
    Q_PROPERTY(QString panelStyleNotice READ panelStyleNotice NOTIFY panelStyleChanged)
public:
    explicit DesktopBridge(QObject *parent=nullptr):QObject(parent),m_settings(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/project-blackbox-desktop.ini",QSettings::IniFormat) {
        auto bus=QDBusConnection::sessionBus();
        bus.registerService("org.projectblackbox.Desktop");
        bus.connect("org.kde.KWin","/KWin","org.kde.KWin","showingDesktopChanged",this,SLOT(ShowingDesktop(bool)));
        bus.registerObject("/Blackbox",this,QDBusConnection::ExportScriptableSlots|QDBusConnection::ExportScriptableSignals);
        m_cubeLease.setSingleShot(true);
        m_cubeLease.setInterval(4000);
        connect(&m_cubeLease,&QTimer::timeout,this,&DesktopBridge::cubeActiveChanged);
        m_config=defaults();
        for(auto it=m_config.begin();it!=m_config.end();++it) if(m_settings.contains(it.key())) it.value()=m_settings.value(it.key());
        m_config["linkDesktops"]=m_settings.value("linkDesktops",false).toBool();
        m_config["backgroundPlay"]=m_settings.value("backgroundPlay",!m_settings.value("homeOnly",true).toBool()).toBool();
        m_config["backgroundIdle"]=m_settings.value("backgroundIdle",m_config.value("backgroundPlay")).toBool();
        if(!m_settings.contains("backgroundIdle"))
            m_settings.setValue("backgroundIdle",m_config.value("backgroundIdle"));
        if(m_config.value("mode").toString()=="performance")m_config["mode"]="idle";
        if(!m_settings.contains("audioMaster") && m_settings.contains("sound"))
            m_config["audioMaster"]=m_settings.value("sound").toBool() ? 1.0 : 0.0;
        {QSettings game(gameFile(),QSettings::IniFormat);m_config["achievementOverride"]=game.value("Codex/unlockAchievements",false);}
        for(const auto &front:{"front","left","right","up","down","back","cube"}) m_config[QString("wallpaper_")+front]=m_settings.value(QString("wallpaper_")+front,"");
        m_bands=QVariantList{0.,0.,0.,0.,0.,0.,0.,0.};
        connect(&m_timer,&QTimer::timeout,this,&DesktopBridge::sample);
        m_timer.start(500);
        connect(&m_audio,&QProcess::readyReadStandardOutput,this,&DesktopBridge::audioData);
        connect(&m_audio,&QProcess::errorOccurred,this,[this](QProcess::ProcessError){m_audioStatus="Audio monitor unavailable; install pipewire-audio and check the output target.";emit sensorsChanged();});
        connect(&m_audio,qOverload<int,QProcess::ExitStatus>(&QProcess::finished),this,[this](int,QProcess::ExitStatus){m_audioStatus="Audio monitor stopped";emit sensorsChanged();});
        connect(&m_nvidia,qOverload<int,QProcess::ExitStatus>(&QProcess::finished),this,[this](int code,QProcess::ExitStatus){if(!code) {bool ok=false;const auto value=m_nvidia.readAllStandardOutput().split('\n').first().trimmed().toDouble(&ok);if(ok)m_gpu=qBound(0.,value/100.,1.);}emit sensorsChanged();});
        connect(&m_style,&QProcess::stateChanged,this,&DesktopBridge::panelStyleChanged);
        connect(&m_style,&QProcess::errorOccurred,this,[this](QProcess::ProcessError error) {
            if(error==QProcess::FailedToStart) finishPanelStyle(false);
        });
        connect(&m_style,qOverload<int,QProcess::ExitStatus>(&QProcess::finished),this,[this](int code,QProcess::ExitStatus status) {
            const bool success=status==QProcess::NormalExit && code==0;
            if(success && m_changingAppColors && appearance(true)!=m_requestedStyle) {
                // KDE may return success for an effective scheme inherited from defaults.
                // Record the selected value so the Blackbox toggle can restore it.
                QSettings kde(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/kdeglobals",QSettings::IniFormat);
                kde.setValue("ColorScheme",m_requestedStyle);
                kde.sync();
            }
            finishPanelStyle(success && appearance(m_changingAppColors)==m_requestedStyle);
        });
        bus.connect("org.freedesktop.ScreenSaver","/ScreenSaver","org.freedesktop.ScreenSaver",
                    "ActiveChanged",this,SLOT(screenLocked(bool)));
        bus.connect("org.kde.KWin","/VirtualDesktopManager","org.kde.KWin.VirtualDesktopManager",
                    "currentChanged",this,SLOT(workspaceUpdated(QString)));
        const auto gui=qobject_cast<QGuiApplication *>(QCoreApplication::instance());
        if(gui) {
            connect(gui,&QGuiApplication::screenAdded,this,&DesktopBridge::screensChanged);
            connect(gui,&QGuiApplication::screenRemoved,this,&DesktopBridge::screensChanged);
        }
        QTimer::singleShot(0,this,&DesktopBridge::syncAudio);
    }
    ~DesktopBridge() override {m_audio.kill();m_audio.waitForFinished(500);m_nvidia.kill();m_nvidia.waitForFinished(500);}
    bool atHome() const {return m_home && !m_screenLocked;}
    bool showingDesktop() const {return m_showDesktop;}
    bool cubeActive() const {return m_cubeLease.isActive();}
    QRect appPerch() const {return m_appPerch;}
    QVariantList appPerches() const {return m_appPerches;}
    bool fullscreenApp() const {return m_fullscreenApp;}
    bool sessionLocked() const {return m_screenLocked;}
    bool visibilityReady() const {return m_visibilityReady;}
    double cpu() const {return m_cpu;}
    double gpu() const {return m_gpu;}
    double loudness() const {return m_loudness;}
    QVariantList bands() const {return m_bands;}
    QString audioStatus() const {return m_audioStatus;}
    QVariantMap state() const {return m_state;}
    QVariantMap config() const {return m_config;}
    QString desktopFront() const {return m_workspaces.key(m_currentWorkspace);}
    QStringList screens() const {
        QStringList names;
        for(const auto *screen:QGuiApplication::screens()) names.append(screen->name());
        return names;
    }
    bool wallpaperActive() const {return !m_owner.isEmpty();}
    bool darkPanel() const {return appearance(false)==darkStyle;}
    bool darkApps() const {return appearance(true)==darkColors;}
    bool panelStyleBusy() const {return m_style.state()!=QProcess::NotRunning;}
    QString panelStyleNotice() const {return m_styleNotice;}
    void refreshPanelStyle() {emit panelStyleChanged();}
    void setDarkAppearance(bool enabled,bool apps) {
        if(panelStyleBusy()) return;
        const auto current=appearance(apps);
        const auto dark=apps ? darkColors : darkStyle;
        if((current==dark)==enabled) return;
        const auto tool=QStandardPaths::findExecutable(apps ? "plasma-apply-colorscheme" : "plasma-apply-desktoptheme");
        if(tool.isEmpty()) {
            m_styleNotice="Open KDE System Settings to change appearance.";
            emit panelStyleChanged();
            return;
        }
        m_changingAppColors=apps;
        m_styleBeforeRequest=current;
        m_requestedStyle=enabled ? dark : m_settings.value(previousAppearanceKey(apps),apps ? "BreezeLight" : "default").toString();
        m_styleNotice.clear();
        m_style.start(tool,{m_requestedStyle});
    }
    Q_INVOKABLE bool switchWorkspace(const QString &front) {
        if(!m_config.value("linkDesktops").toBool() || !m_workspaces.contains(front)) return false;
        return setWorkspace(m_workspaces.value(front));
    }
    void restoreWorkspace() {
        const auto previous=m_settings.value("workspaceBeforeBlackbox").toString();
        if(m_workspaces.values().contains(m_currentWorkspace) && !previous.isEmpty())setWorkspace(previous);
    }
    bool setWorkspace(const QString &id) {
        if(id==m_currentWorkspace) return true;
        auto msg=workspaceCall("org.freedesktop.DBus.Properties","Set");
        msg << QStringLiteral("org.kde.KWin.VirtualDesktopManager") << QStringLiteral("current")
            << QVariant::fromValue(QDBusVariant(id));
        if(QDBusConnection::sessionBus().call(msg,QDBus::Block,1200).type()!=QDBusMessage::ReplyMessage)return false;
        workspaceUpdated(id);
        return true;
    }
    Q_INVOKABLE bool claim(const QString &screen,const QString &token) {
        const auto preferred=m_config.value("screenName").toString();
        if(!preferred.isEmpty() && screens().contains(preferred) && preferred!=screen) return false;
        if(m_owner.isEmpty()) {
            m_owner=token;
            if(m_config.value("darkDefaults").toBool() && !m_settings.value("appearanceDefaultsApplied").toBool()) {
                m_settings.setValue("appearanceDefaultsApplied",true);
                m_defaultAppearanceStep=1;
                QTimer::singleShot(0,this,&DesktopBridge::applyDarkDefaults);
            }
            if(m_config.value("linkDesktops").toBool() && m_workspaces.isEmpty() && !configureWorkspaces()) {
                m_config["linkDesktops"]=false;
                emit configChanged();
            }
            syncAudio();syncWorkspaceSlide();emit wallpaperActiveChanged();
        }
        return m_owner==token;
    }
    Q_INVOKABLE void release(const QString &token) {
        if(m_owner!=token) return;
        m_owner.clear();
        m_cubeContext.clear();
        CubeVisible(false);
        syncAudio();syncWorkspaceSlide();emit wallpaperActiveChanged();
    }
    Q_INVOKABLE void parkRun(const QString &value) {if(value.size()<4000000)m_liveRun=value;}
    Q_INVOKABLE QString parkedRun() const {return m_liveRun;}
    Q_INVOKABLE void publish(const QVariantMap &value) {m_state=value;emit stateChanged();}
    void publishCubeContext(const QVariantMap &value) {m_cubeContext=value;}
    void requestCube() {
        auto query=QDBusMessage::createMethodCall("org.kde.KWin","/Effects","org.kde.kwin.Effects","isEffectLoaded");
        query << QStringLiteral("org.projectblackbox.cube");
        auto *pending=new QDBusPendingCallWatcher(QDBusConnection::sessionBus().asyncCall(query,1000),this);
        connect(pending,&QDBusPendingCallWatcher::finished,this,[this](QDBusPendingCallWatcher *watcher) {
            const QDBusPendingReply<bool> reply=*watcher;
            watcher->deleteLater();
            if(!reply.isValid() || !reply.value()) {
                emit cubeFallbackRequested();
                return;
            }
            auto activate=QDBusMessage::createMethodCall("org.kde.kglobalaccel","/component/kwin",
                "org.kde.kglobalaccel.Component","invokeShortcut");
            activate << QStringLiteral("BlackboxCube");
            auto *invocation=new QDBusPendingCallWatcher(QDBusConnection::sessionBus().asyncCall(activate,1000),this);
            connect(invocation,&QDBusPendingCallWatcher::finished,this,[this](QDBusPendingCallWatcher *result) {
                if(result->isError()) emit cubeFallbackRequested();
                result->deleteLater();
            });
        });
    }
    static QString gameFile() {return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/project-blackbox-demo.ini";}
    Q_INVOKABLE QString savedRun() const {QSettings game(gameFile(),QSettings::IniFormat);return game.value("Codex/savedRun").toString();}
    Q_INVOKABLE QString previousRun() const {
        QSettings game(gameFile(), QSettings::IniFormat);
        return game.value("Codex/previousRun").toString();
    }
    bool hasSave() const {return m_hasSave;}
    Q_INVOKABLE bool saveRun(const QString &value) {
        if (value.isEmpty() || value.size() > 4*1024*1024) return false;
        const auto candidate=QJsonDocument::fromJson(value.toUtf8()).object();
        if (candidate.value("version").toInt()!=1 || !candidate.value("run").isObject()) return false;
        QSettings game(gameFile(), QSettings::IniFormat);
        const auto previous=game.value("Codex/savedRun").toString();
        const auto run=candidate.value("run").toObject();
        const auto belongsToRun=[&run](const QString &checkpoint) {
            const auto old=QJsonDocument::fromJson(checkpoint.toUtf8()).object().value("run").toObject();
            if (old.isEmpty()) return false;
            const QString id=old.value("attemptId").toString();
            return id.isEmpty() ? old.value("seed")==run.value("seed") : id==run.value("attemptId").toString();
        };
        if (belongsToRun(previous))
            game.setValue("Codex/previousRun", previous);
        else if (!belongsToRun(game.value("Codex/previousRun").toString()))
            game.remove("Codex/previousRun");
        game.setValue("Codex/savedRun", value);
        game.sync();
        if (game.status()!=QSettings::NoError) return false;
        if (!m_hasSave) {
            m_hasSave=true;
            emit stateChanged();
        }
        return true;
    }
    Q_INVOKABLE QString progress() const {
        QSettings game(gameFile(),QSettings::IniFormat);
        QJsonObject value;value["profile"]=QJsonDocument::fromJson(game.value("Codex/career","{}").toByteArray()).object();
        value["discoveries"]=QJsonDocument::fromJson(game.value("Codex/entries","{}").toByteArray()).object();
        return QString::fromUtf8(QJsonDocument(value).toJson(QJsonDocument::Compact));
    }
    Q_INVOKABLE void saveProgress(const QString &value) {
        if(value.size()>1000000)return;
        QSettings game(gameFile(),QSettings::IniFormat);const auto incoming=QJsonDocument::fromJson(value.toUtf8()).object();
        auto entries=QJsonDocument::fromJson(game.value("Codex/entries","{}").toByteArray()).object();
        const auto wanted=incoming.value("discoveries").toObject();
        for(const auto &key:{"enemies","abilities"}) {auto existing=entries.value(key).toArray();for(const auto &id:wanted.value(key).toArray())if(!existing.contains(id))existing.append(id);entries[key]=existing;}
        game.setValue("Codex/entries",QString::fromUtf8(QJsonDocument(entries).toJson(QJsonDocument::Compact)));game.sync();
    }
    Q_INVOKABLE QString mergeProgress(const QString &delta) {
        QSettings game(gameFile(),QSettings::IniFormat);game.sync();
        auto profile=QJsonDocument::fromJson(game.value("Codex/career","{}").toByteArray()).object();
        const auto values=QJsonDocument::fromJson(delta.toUtf8()).object();
        const QStringList best{"bestWave","bestClearedWave","bestShieldCrits","bestFlawlessWave","bestWallet","bestRunSpent","bestTimedWave"};
        for(auto it=values.begin();it!=values.end();++it) {const double v=it.value().toDouble();if(v<0 || !std::isfinite(v))continue;const double old=profile.value(it.key()).toDouble();profile[it.key()]=best.contains(it.key()) ? qMax(old,v) : old+v;}
        const auto json=QString::fromUtf8(QJsonDocument(profile).toJson(QJsonDocument::Compact));game.setValue("Codex/career",json);game.sync();return json;
    }
    Q_INVOKABLE void resetOptions(bool images) {
        if(images) {
            for(const auto &front:{"front","left","right","up","down","back","cube"}) {
                const QString key=QString("wallpaper_")+front;
                m_config[key]=QString();
                m_settings.remove(key);
            }
        } else {
            if(m_config.value("linkDesktops").toBool()) restoreWorkspace();
            const auto values=defaults();
            for(auto it=values.cbegin();it!=values.cend();++it) {
                if(it.key()=="achievementOverride") continue;
                m_config[it.key()]=it.value();
                m_settings.remove(it.key());
            }
            m_settings.remove("homeOnly");
            m_settings.remove("sound");
        }
        m_settings.sync();emit configChanged();syncAudio();
        syncWorkspaceSlide();
    }
    Q_INVOKABLE void setOption(const QString &key,const QVariant &value) {
        if(!m_config.contains(key))return;
        if(key=="mode" && !QStringList{"play","idle","performance","xd"}.contains(value.toString()))return;
        if(key=="interfaceTheme" && !QStringList{"bloodShrine","armory","terminal","dossier","lockdown","dark"}.contains(value.toString()))return;
        if(key=="idleFront" && !QStringList{"front","left","right","up","down","back"}.contains(value.toString()))return;
        if(key=="linkDesktops") {
            if(value.toBool()) {
                const auto before=workspaceProperty("current").toString();
                if(!configureWorkspaces())return;
                const auto front=m_config.value("mode").toString()=="play" ? m_state.value("front").toString()
                    : m_config.value("idleFront").toString();
                if(!setWorkspace(m_workspaces.value(front,m_workspaces.value("front"))))return;
                if(!before.isEmpty() && !m_workspaces.values().contains(before))
                    m_settings.setValue("workspaceBeforeBlackbox",before);
            }
        }
        if(key=="idlePhaseMinutes" && (value.toInt()<1 || value.toInt()>120))return;
        if(key=="idleFps" && (value.toInt()<5 || value.toInt()>30))return;
        if(key=="controlBindings") {
            const auto data=value.toString().toUtf8();
            if(data.size()>2800 || !QJsonDocument::fromJson(data).isObject()) return;
        }
        if(key=="petFolder" && !value.toString().isEmpty() && !QFileInfo(value.toString()).isDir())return;
        if(key=="terminalOpacity" && (value.toDouble()<.50 || value.toDouble()>1))return;
        if(key=="terminalImage" && !value.toString().isEmpty()) {
            const QUrl url(value.toString());
            if(!url.isLocalFile() || !QFileInfo(url.toLocalFile()).isFile())return;
        }
        if(key=="terminalFontSize" && (value.toInt()<10 || value.toInt()>26))return;
        if(key=="terminalPalette") {
            const auto palette=QJsonDocument::fromJson(value.toString().toUtf8());
            if(!palette.isObject() || value.toString().size()>220)return;
            const auto colors=palette.object();
            static const QRegularExpression hex(QStringLiteral("^#[0-9a-fA-F]{6}$"));
            for(auto it=colors.begin();it!=colors.end();++it)
                if(!QStringList{"foreground","background","accent"}.contains(it.key()) || !hex.match(it.value().toString()).hasMatch()) return;
        }
        if(key=="frameLimit" && (value.toInt()<20 || value.toInt()>240))return;
        if(key=="hudScale" && !QList<double>{.8,1,1.15,1.3}.contains(value.toDouble()))return;
        if(key.startsWith("audio") && key!="audioTarget") {
            bool ok=false;
            const double level=value.toDouble(&ok);
            if(!ok || !std::isfinite(level) || level<0 || level>1)return;
        }
        if(key=="textScale" && !QList<double>{1,1.15,1.3,1.45}.contains(value.toDouble()))return;
        if(key=="detail" && (value.toInt()<0 || value.toInt()>3))return;
        if(key=="quality" && !QList<int>{0,1080,1440,2160}.contains(value.toInt()))return;
        if(key=="framing" && !QStringList{"fill","fit","stretch","16:9"}.contains(value.toString()))return;
        if(key=="transitionStyle" && !QStringList{"cinematic","soft"}.contains(value.toString()))return;
        if(key=="transitionStrength" && (value.toDouble()<.4 || value.toDouble()>1.4))return;
        if(key=="zoom" && (value.toDouble()<1 || value.toDouble()>1.4))return;
        if(key.startsWith("wallpaper_") && !value.toString().isEmpty()) {
            const QUrl url(value.toString());
            if(!url.isLocalFile() || !QFile::exists(url.toLocalFile()))return;
        }
        if(key=="achievementOverride"){QSettings game(gameFile(),QSettings::IniFormat);game.setValue("Codex/unlockAchievements",value);game.sync();}
        if(key=="petAdmin" && value.toBool() && !m_config.value("idlePet").toBool()) {
            m_config["idlePet"]=true;
            m_settings.setValue("idlePet",true);
        }
        m_config[key]=value;m_settings.setValue(key,value);m_settings.sync();emit configChanged();
        if(key=="linkDesktops" && !value.toBool())restoreWorkspace();
        if(key=="linkDesktops" || key=="singleWorkspaceTurn")syncWorkspaceSlide();
        if(key=="musicReactive" || key=="audioTarget" || key=="mode")syncAudio();
    }
public slots:
    Q_SCRIPTABLE void Visibility(bool home) {m_focusHome=home;m_home=m_showDesktop || m_focusHome;m_visibilityReady=true;emit visibilityChanged();syncAudio();}
    Q_SCRIPTABLE QString CubeContext() const {
        if(!wallpaperActive() || sessionLocked()) return "{}";
        return QString::fromUtf8(QJsonDocument::fromVariant(m_cubeContext).toJson(QJsonDocument::Compact));
    }
    Q_SCRIPTABLE bool CubeVisible(bool visible) {
        if(visible && (!wallpaperActive() || sessionLocked() || m_cubeContext.value("available").toList().isEmpty()))
            return false;
        const bool wasActive=cubeActive();
        if(visible) m_cubeLease.start();
        else m_cubeLease.stop();
        if(wasActive!=visible) emit cubeActiveChanged();
        return true;
    }
    Q_SCRIPTABLE bool CubeSelect(const QString &room) {
        const auto available=m_cubeContext.value("available").toList();
        if(!wallpaperActive() || sessionLocked() || !available.contains(room)) return false;
        emit commandRequested("cube-room-"+room);
        return true;
    }
    bool acceptsIdleCommands() const {
        return !m_owner.isEmpty() && !m_screenLocked && QStringList{"idle","performance"}.contains(m_config.value("mode").toString());
    }
    Q_SCRIPTABLE bool BoxAdmin(const QString &session,const QString &phrase) {
        if(!wallpaperActive() || sessionLocked() || QUuid(session).isNull() || phrase.size()>128) return false;
        const auto digest=QCryptographicHash::hash(phrase.toUtf8(),QCryptographicHash::Sha256).toHex();
        if(digest!="727a73ec0b0075883fed84b094535f4b863fcf21a51b9e7474231826af616b64") return false;
        m_settings.setValue("practiceUnlocked",true);
        m_settings.sync();
        return m_settings.status()==QSettings::NoError;
    }
    Q_SCRIPTABLE bool BoxLock(const QString &session) {
        if(!wallpaperActive() || sessionLocked() || QUuid(session).isNull()) return false;
        m_settings.remove("practiceUnlocked");
        m_settings.sync();
        return m_settings.status()==QSettings::NoError;
    }
    Q_SCRIPTABLE bool BoxDebug(const QString &session,const QString &action,const QString &value) {
        if(!wallpaperActive() || sessionLocked() || QUuid(session).isNull() || !m_settings.value("practiceUnlocked",false).toBool()
            || value.size()>100 || m_state.value("phase").toString()!="ready") return false;
        if(!QStringList{"practice","money","weapon","weather","unlocks"}.contains(action)
            || action!="practice" && !m_state.value("debug").toBool()) return false;
        if(action=="practice") {
            static const QRegularExpression terms(QStringLiteral("^(normal|hard|insane),(?:[1-9]0|1[0-5]0),(standard|star|random)$"));
            if(!terms.match(value).hasMatch()) return false;
        } else if(action=="money" || action=="unlocks") {
            if(value!="true" && value!="false") return false;
        } else if(action=="weapon") {
            static const QRegularExpression identifier(QStringLiteral("^[a-zA-Z][a-zA-Z0-9_-]{0,54}$"));
            if(!identifier.match(value).hasMatch()) return false;
        }
        emit commandRequested("box-debug/"+action+"/"+value);
        return true;
    }
    Q_SCRIPTABLE QString PetCommand(const QString &json) {
        if(!wallpaperActive() || sessionLocked() || !m_config.value("petAdmin").toBool())
            return QStringLiteral("{\"ok\":false,\"message\":\"Enable Pet admin in BX or Desktop settings.\"}");
        const auto values=QJsonDocument::fromJson(json.toUtf8());
        if(json.size()>3000 || !values.isArray() || values.array().isEmpty() || values.array().size()>80)
            return QStringLiteral("{\"ok\":false,\"message\":\"Invalid pet command. Try pet help.\"}");
        QStringList args;
        for(const auto item:values.array()) {
            if(!item.isString())
                return QStringLiteral("{\"ok\":false,\"message\":\"Invalid argument.\"}");
            args.append(item.toString());
        }
        m_petResponse={{"ok",false},{"message","Pet unavailable."}};
        emit petCommandRequested(args);
        return QString::fromUtf8(QJsonDocument::fromVariant(m_petResponse).toJson(QJsonDocument::Compact));
    }
    Q_SCRIPTABLE bool BoxReport(const QString &message) {
        if(!wallpaperActive() || sessionLocked() || message.size()>4000) return false;
        if(message.trimmed().isEmpty()) emit commandRequested("report");
        else {
            QSettings reports(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                +"/project-blackbox-issues.ini",QSettings::IniFormat);
            const QVariantMap entry{{"time",QDateTime::currentDateTimeUtc().toString(Qt::ISODate)},
                {"text",message.trimmed()},{"context",QVariantMap{{"host","Plasma"},{"screen","terminal"}}}};
            reports.setValue("Reports/issue_"+QUuid::createUuid().toString(QUuid::WithoutBraces),
                QString::fromUtf8(QJsonDocument::fromVariant(entry).toJson(QJsonDocument::Compact)));
            reports.sync();
            if(reports.status()!=QSettings::NoError) return false;
        }
        return true;
    }
    Q_SCRIPTABLE void PetWindow(const QString &id,const QString &label) {
        m_petWindow=id.left(30);m_petWindowLabel=label.left(140);
    }
    Q_SCRIPTABLE QString PetCloseTarget() {
        const auto target=std::exchange(m_petCloseTarget,QString());
        const auto deadline=std::exchange(m_petCloseDeadline,qint64(0));
        return wallpaperActive() && !sessionLocked() && m_config.value("petAdmin").toBool()
            && QDateTime::currentMSecsSinceEpoch()<deadline ? target : QString();
    }
    Q_SCRIPTABLE bool BoxPetFly(int x,int y) {
        if(!acceptsIdleCommands() || !m_config.value("idlePet").toBool() || x<0 || y<0 || x>16384 || y>16384) return false;
        emit commandRequested(QString("box-pet/%1/%2").arg(x).arg(y));
        return true;
    }
    Q_SCRIPTABLE bool BoxReset(const QString &selection) {
        if(!wallpaperActive() || sessionLocked() || !QStringList{"settings","images"}.contains(selection)) return false;
        resetOptions(selection=="images");
        return true;
    }
    Q_SCRIPTABLE bool IdleTurn(const QString &direction) {
        if (!acceptsIdleCommands() || !QStringList{"left","right","up","down"}.contains(direction)) return false;
        emit commandRequested("idle-terminal-"+direction);
        return true;
    }
    void petReply(bool ok,const QString &message) {m_petResponse={{"ok",ok},{"message",message}};}
    QVariantMap petWindow() const {return {{"id",m_petWindow},{"title",m_petWindowLabel}};}
    QString petPath(const QString &input) const {
        if(input.isEmpty() || input.contains(QChar::Null)) return {};
        auto path=input;
        if(path.startsWith("file:")) path=QUrl(path).toLocalFile();
        if(path=="~" || path.startsWith("~/")) path.replace(0,1,petHome());
        const QString folder=m_config.value("petFolder").toString();
        return path.isEmpty() ? QString() : QDir(folder.isEmpty() ? petHome() : folder).absoluteFilePath(QDir::cleanPath(path));
    }
    static QString petHome() {
        if(qEnvironmentVariable("BLACKBOX_PREVIEW")=="1") return QDir(qEnvironmentVariable("BLACKBOX_DESKTOP_DIR")).absoluteFilePath("../terminal-home");
        return QDir::homePath();
    }
    QVariantMap petTask(const QString &kind,const QString &first,const QString &second) {
        auto response=[](bool ok,const QString &message){return QVariantMap{{"ok",ok},{"message",message}};};
        if(!wallpaperActive() || sessionLocked() || !m_config.value("petAdmin").toBool())
            return response(false,"Pet admin is off.");
        if(kind=="close-app") {
            if(first.isEmpty() || first.size()>30 || first!=m_petWindow) return response(false,"That window is no longer selected.");
            m_petCloseTarget=first;
            m_petCloseDeadline=QDateTime::currentMSecsSinceEpoch()+2000;
            auto action=QDBusMessage::createMethodCall("org.kde.kglobalaccel","/component/kwin",
                "org.kde.kglobalaccel.Component","invokeShortcut");
            action<<QStringLiteral("BlackboxPetClose");
            QDBusConnection::sessionBus().asyncCall(action,1000);
            return response(true,"Asked the application to close.");
        }
        if(kind=="volume") {
            if(qEnvironmentVariable("BLACKBOX_PREVIEW")=="1") return response(false,"Speaker volume is shared with the main session.");
            bool valid=false;
            const auto percent=first.toInt(&valid);
            const auto tool=QStandardPaths::findExecutable("wpctl");
            if(tool.isEmpty()) return response(false,"PipeWire volume control is unavailable.");
            if((!valid && first!="louder" && first!="quieter") || (valid && (percent<0 || percent>100)))
                return response(false,"Use a volume from 0 to 100.");
            const auto amount=valid ? QString::number(percent)+"%" : first=="louder" ? "5%+" : "5%-";
            return response(QProcess::startDetached(tool,{"set-volume","--limit","1.0","@DEFAULT_AUDIO_SINK@",amount}),"Speaker volume requested.");
        }
        const auto path=petPath(first);
        const QFileInfo info(path);
        if(path.isEmpty()) return response(false,"Give a local path.");
        if(kind=="folder") {
            if(!info.isDir()) return response(false,"Folder not found.");
            setOption("petFolder",path);
            return response(true,path);
        }
        if(kind=="locate") {
            return info.exists() ? response(true,path) : response(false,"Path not found.");
        }
        if(kind=="open" || kind=="reveal") {
            if(!info.exists())return response(false,"Path not found.");
            if(kind=="reveal" && info.isFile()) {
                const auto tool=QStandardPaths::findExecutable("dolphin");
                if(!tool.isEmpty() && QProcess::startDetached(tool,{"--select",path})) return response(true,"Revealed "+info.fileName()+".");
            }
            return response(QDesktopServices::openUrl(QUrl::fromLocalFile(path)),"Opened "+info.fileName()+".");
        }
        if(kind=="list") {
            if(!info.isDir()) return response(false,"Folder not found.");
            return response(true,QDir(path).entryList(QDir::AllEntries|QDir::NoDotAndDotDot,QDir::Name).mid(0,24).join(" · "));
        }
        if(kind=="read") {
            QFile file(path);
            if(!info.isFile() || !file.open(QIODevice::ReadOnly)) return response(false,"Could not read that file.");
            return response(true,QString::fromUtf8(file.read(600)).remove(QChar::Null));
        }
        if(kind=="mkdir") return response(QDir().mkpath(path),"Folder creation requested.");
        if(kind=="write") {
            QFile file(path);
            if(info.isSymLink() || (info.exists() && !info.isFile()))return response(false,"Choose a regular file.");
            if(!file.open(QIODevice::WriteOnly|QIODevice::Append))return response(false,"Could not open that file for writing.");
            const auto bytes=(second+QLatin1Char('\n')).toUtf8();
            return response(file.write(bytes)==bytes.size() && file.flush(),"Text appended to "+info.fileName()+".");
        }
        if(kind=="fetch") {
            QString target=petPath(second);
            if(!info.isFile() || target.isEmpty())return response(false,"Choose a file and a destination.");
            if(QFileInfo(target).isDir()) target=QDir(target).filePath(info.fileName());
            if(QFileInfo::exists(target))return response(false,"A file already exists there.");
            if(info.size()>32*1024*1024)return response(false,"Use the file manager for files larger than 32 MiB.");
            return response(QFile::copy(path,target),"Copy requested.");
        }
        return response(false,"Unknown pet action.");
    }
    Q_SCRIPTABLE bool IdleRoom(const QString &front) {
        if (!acceptsIdleCommands() || !QStringList{"front","left","right","up","down","back"}.contains(front)) return false;
        emit commandRequested("idle-room-"+front);
        return true;
    }
    Q_SCRIPTABLE void AppPerch(int x,int y,int width,int height) {
        const QRect next(x,y,qBound(0,width,16384),qBound(0,height,16384));
        if (next==m_appPerch) return;
        m_appPerch=next;
        m_appPerches=next.isEmpty() ? QVariantList{} : QVariantList{QVariantMap{{"id","legacy"},{"frame",next}}};
        emit perchChanged();
    }
    Q_SCRIPTABLE void AppPerches(const QString &json,bool fullscreen) {
        if(json.size()>4096) return;
        const auto document=QJsonDocument::fromJson(json.toUtf8());
        if(!document.isArray()) return;
        const auto items=document.array();
        QVariantList perches;
        for(const auto &entry:items) {
            if(perches.size()>=24) break;
            const auto row=entry.toArray();
            if(row.size()!=5 || !row[0].isString()) continue;
            const QRect frame(row[1].toInt(),row[2].toInt(),qBound(0,row[3].toInt(),16384),qBound(0,row[4].toInt(),16384));
            if(!frame.isEmpty()) perches.append(QVariantMap{{"id",row[0].toString()},{"frame",frame}});
        }
        if(m_appPerches==perches && m_fullscreenApp==fullscreen) return;
        m_appPerches=perches;
        m_appPerch=perches.isEmpty() ? QRect{} : perches.first().toMap().value("frame").toRect();
        m_fullscreenApp=fullscreen;
        emit perchChanged();
    }
    Q_SCRIPTABLE bool Workspace(const QString &front) {return switchWorkspace(front);}
    void screenLocked(bool locked) {
        m_screenLocked=locked;
        if(locked) CubeVisible(false);
        emit visibilityChanged();syncAudio();
    }
    void workspaceUpdated(const QString &id) {if(m_currentWorkspace!=id){m_currentWorkspace=id;emit workspaceChanged();}}
    void ShowingDesktop(bool showing) {m_showDesktop=showing;m_home=m_showDesktop || m_focusHome;emit visibilityChanged();syncAudio();}
    Q_SCRIPTABLE void Command(const QString &name) {
        const QStringList commands{"pause","resume","settings","loadout","new","continue","q","e","weapon1","weapon2","shield","left","right","up","down","save","begin","reload","play","grimoire","revert","idle-pet","overview","idle-left","idle-right","idle-up","idle-down","terminal","pet-console","report"};
        if(commands.contains(name))emit commandRequested(name);
    }
    Q_SCRIPTABLE QString Status() const {return QString::fromUtf8(QJsonDocument::fromVariant(m_state).toJson(QJsonDocument::Compact));}
    Q_SCRIPTABLE QString Options() const {return QString::fromUtf8(QJsonDocument::fromVariant(m_config).toJson(QJsonDocument::Compact));}
    Q_SCRIPTABLE void Configure(const QString &key,const QString &json) {
        const auto doc=QJsonDocument::fromJson(("["+json+"]").toUtf8());if(doc.isArray() && doc.array().size()==1)setOption(key,doc.array().at(0).toVariant());
    }
signals:
    void visibilityChanged();void sensorsChanged();void stateChanged();void configChanged();
    Q_SCRIPTABLE void commandRequested(const QString &name);
    void cubeActiveChanged();
    void cubeFallbackRequested();
    void petCommandRequested(const QStringList &args);
    void workspaceChanged();void screensChanged();
    void wallpaperActiveChanged();void panelStyleChanged();void perchChanged();
private:
    void applyDarkDefaults() {
        while(m_defaultAppearanceStep && !panelStyleBusy()) {
            const bool apps=m_defaultAppearanceStep==2;
            m_defaultAppearanceStep=apps ? 0 : 2;
            setDarkAppearance(true,apps);
        }
    }
    void syncWorkspaceSlide() {
        const bool muted=m_settings.value("slidePausedByBlackbox",false).toBool();
        const bool wanted=wallpaperActive() && m_config.value("linkDesktops").toBool()
            && m_config.value("singleWorkspaceTurn").toBool();
        if(wanted==muted) return;
        auto effect=[](const QString &method) {
            auto call=QDBusMessage::createMethodCall("org.kde.KWin","/Effects","org.kde.kwin.Effects",method);
            call << QStringLiteral("slide");
            return QDBusConnection::sessionBus().call(call,QDBus::Block,800);
        };
        const QDBusReply<bool> loaded=effect("isEffectLoaded");
        if(!loaded.isValid()) return;
        if(wanted==!loaded.value()) {
            if(!wanted) {m_settings.remove("slidePausedByBlackbox");m_settings.sync();}
            return;
        }
        if(effect(wanted ? "unloadEffect" : "loadEffect").type()!=QDBusMessage::ReplyMessage) return;
        const QDBusReply<bool> after=effect("isEffectLoaded");
        if(after.isValid() && after.value()!=wanted) {
            m_settings.setValue("slidePausedByBlackbox",wanted);
            m_settings.sync();
        }
    }
    static inline const QString darkStyle=QStringLiteral("org.projectblackbox.blood");
    static inline const QString darkColors=QStringLiteral("BreezeDark");
    static QString appearance(bool apps) {
        const auto dir=QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
        QSettings kde(dir+(apps ? "/kdeglobals" : "/plasmarc"),QSettings::IniFormat);
        return apps ? kde.value("ColorScheme","BreezeLight").toString() : kde.value("Theme/name","default").toString();
    }
    static QString previousAppearanceKey(bool apps) {
        return apps ? QStringLiteral("appColorsBeforeBlackbox") : QStringLiteral("panelStyleBeforeBlackbox");
    }
    void finishPanelStyle(bool applied) {
        if(applied) {
            const auto key=previousAppearanceKey(m_changingAppColors);
            if(m_requestedStyle==(m_changingAppColors ? darkColors : darkStyle)) m_settings.setValue(key,m_styleBeforeRequest);
            else m_settings.remove(key);
            m_settings.sync();
        }
        m_styleNotice=applied ? QString() : QStringLiteral("KDE could not change appearance. Check Colors and Plasma Style in System Settings.");
        emit panelStyleChanged();
        if(m_defaultAppearanceStep) QTimer::singleShot(0,this,&DesktopBridge::applyDarkDefaults);
    }
    static QVariantMap defaults() {
        return {{"mode","idle"},{"interfaceTheme","bloodShrine"},{"cpuAmmo",false},{"gpuEffects",false},{"musicReactive",false},{"audioTarget",""},
            {"darkDefaults",true},{"petAdmin",false},{"petMuted",false},{"petFolder",""},{"terminalFontSize",16},{"terminalPalette","{}"},{"terminalImage",""},{"terminalOpacity",.87},{"peekOverview",true},{"idlePhaseMinutes",10},{"idleFps",12},{"idlePet",false},{"safeRendering",false},{"singleWorkspaceTurn",true},{"showEnemyPreview",true},{"wheelSwitch",true},{"controlBindings","{}"},
            {"frameLimit",60},{"hudScale",1.0},{"textScale",1.0},{"autoSave",true},{"backgroundPlay",false},{"backgroundIdle",false},{"linkDesktops",false},{"idleFront","front"},{"mouseTurns",true},{"detail",1},{"quality",0},{"framing","fill"},{"zoom",1.},{"transitionStyle","cinematic"},{"transitionStrength",1.},{"audioMaster",1.0},{"audioMusic",1.0},{"audioEffects",1.0},{"audioAmbience",1.0},{"audioInterface",1.0},{"motion",true},{"showTimer",false},{"screenName",""},{"achievementOverride",false}};
    }
    static QDBusMessage workspaceCall(const QString &interface,const QString &member) {
        return QDBusMessage::createMethodCall("org.kde.KWin","/VirtualDesktopManager",interface,member);
    }
    static QVariant workspaceProperty(const QString &name) {
        auto msg=workspaceCall("org.freedesktop.DBus.Properties","Get");
        msg << QStringLiteral("org.kde.KWin.VirtualDesktopManager") << name;
        const QDBusReply<QDBusVariant> reply=QDBusConnection::sessionBus().call(msg,QDBus::Block,1200);
        return reply.isValid() ? reply.value().variant() : QVariant{};
    }
    static QMap<QString,QString> workspaceNames() {
        const auto raw=workspaceProperty("desktops");
        QMap<QString,QString> names;
        if(!raw.canConvert<QDBusArgument>()) return names;
        const auto argument=qvariant_cast<QDBusArgument>(raw);
        argument.beginArray();
        while(!argument.atEnd()) {
            qint32 position;QString id,name;
            argument.beginStructure();argument >> position >> id >> name;argument.endStructure();
            names[name]=id;
        }
        argument.endArray();
        return names;
    }
    bool configureWorkspaces() {
        static const QMap<QString,QString> labels{{"front","Shrine"},{"left","West"},{"right","Droid Lab"},{"up","Star Sky"},{"down","Abyss"},{"back","Pure Code"}};
        auto names=workspaceNames();
        if(names.isEmpty()) return false;
        auto linked=m_settings.value("linkedFronts").toMap();
        const auto bus=QDBusConnection::sessionBus();
        for(auto it=labels.begin();it!=labels.end();++it) {
            auto id=linked.value(it.key()).toString();
            if(!id.isEmpty() && names.values().contains(id)) continue;
            const QString name="Blackbox · "+it.value();
            if(!names.contains(name)) {
                auto msg=workspaceCall("org.kde.KWin.VirtualDesktopManager","createDesktop");
                msg << static_cast<uint>(workspaceProperty("count").toUInt()) << name;
                if(bus.call(msg,QDBus::Block,1200).type()!=QDBusMessage::ReplyMessage) return false;
                names=workspaceNames();
            }
            id=names.value(name);
            if(id.isEmpty()) return false;
            linked[it.key()]=id;
        }
        m_workspaces.clear();
        for(auto it=labels.begin();it!=labels.end();++it)m_workspaces[it.key()]=linked.value(it.key()).toString();
        m_settings.setValue("linkedFronts",linked);
        m_settings.sync();
        m_currentWorkspace=workspaceProperty("current").toString();
        emit workspaceChanged();
        return true;
    }
    void syncAudio() {
        const bool wanted=!m_owner.isEmpty() && m_config.value("mode").toString()!="performance" && m_config.value("musicReactive").toBool() && atHome();
        if(!wanted) {m_audio.kill();m_audioStatus="Off · no microphone capture";m_loudness=0;return;}
        if(m_audio.state()!=QProcess::NotRunning)return;
        auto executable=QStandardPaths::findExecutable("pw-record");
        if(executable.isEmpty()){m_audioStatus="Install pipewire-audio for output monitoring";return;}
        QStringList args{"--raw","--format","f32","--rate","8000","--channels","1","--latency","128ms","--properties","{ stream.capture.sink=true media.name=BlackboxOutputMonitor }"};
        const auto target=m_config.value("audioTarget").toString();if(!target.isEmpty())args<<"--target"<<target;
        args<<"-";m_audio.setProcessChannelMode(QProcess::SeparateChannels);m_audio.start(executable,args);m_audioStatus="Monitoring speaker output locally · nothing saved";
    }
    void audioData() {
        m_pcm+=m_audio.readAllStandardOutput();
        const int count=m_pcm.size()/int(sizeof(float));
        if(count<256)return;
        const int n=qMin(count,512);QVector<double> samples(n);double sum=0;
        for(int i=0;i<n;++i){float v;std::memcpy(&v,m_pcm.constData()+(count-n+i)*4,4);samples[i]=std::isfinite(v)?qBound(-1.,double(v),1.):0.;sum+=samples[i]*samples[i];}
        m_pcm.clear();m_loudness=qBound(0.,std::sqrt(sum/n)*4,1.);
        for(int b=0;b<8;b++){const double freq=55.*std::pow(1.85,b);double re=0,im=0;for(int i=0;i<n;i++){const double a=6.28318530718*freq*i/8000.;re+=samples[i]*std::cos(a);im+=samples[i]*std::sin(a);}m_bands[b]=qBound(0.,std::hypot(re,im)/n*10.,1.);}
        emit sensorsChanged();
    }
    void sample() {
        QSettings game(gameFile(),QSettings::IniFormat);
        const bool hasSave=game.contains("Codex/savedRun") && !game.value("Codex/savedRun").toString().isEmpty()
            || game.contains("Codex/previousRun") && !game.value("Codex/previousRun").toString().isEmpty();
        if (m_hasSave!=hasSave) {m_hasSave=hasSave;emit stateChanged();}
        const bool override=game.value("Codex/unlockAchievements",false).toBool();
        if(m_config.value("achievementOverride").toBool()!=override) {m_config["achievementOverride"]=override;emit configChanged();}
        // Sensors are read-only; the game's GPU pressure never changes hardware settings.
        QFile file("/proc/stat");if(file.open(QIODevice::ReadOnly)) {
            const auto parts=file.readLine().simplified().split(' ');qulonglong total=0,idle=0;
            for(int i=1;i<parts.size() && i<=8;i++){auto n=parts[i].toULongLong();total+=n;if(i==4 || i==5)idle+=n;}
            if(total>m_total)m_cpu=qBound(0.,1.-double(idle-m_idle)/double(total-m_total),1.);m_total=total;m_idle=idle;
        }
        bool read=false;QDir cards("/sys/class/drm");
        for(const auto &card:cards.entryList(QStringList{"card[0-9]*"},QDir::Dirs)){QFile gpu(cards.filePath(card+"/device/gpu_busy_percent"));if(gpu.open(QIODevice::ReadOnly)){bool ok;const double val=gpu.readAll().trimmed().toDouble(&ok);if(ok){m_gpu=qBound(0.,val/100.,1.);read=true;break;}}}
        if(!read && ++m_gpuTick%4==0 && m_nvidia.state()==QProcess::NotRunning) {const auto exe=QStandardPaths::findExecutable("nvidia-smi");if(!exe.isEmpty())m_nvidia.start(exe,{"--query-gpu=utilization.gpu","--format=csv,noheader,nounits"});}
        emit sensorsChanged();
    }
    QSettings m_settings;QTimer m_timer;QProcess m_audio,m_nvidia,m_style;QByteArray m_pcm;
    QString m_styleNotice,m_requestedStyle,m_styleBeforeRequest;
    bool m_changingAppColors=false;
    bool m_hasSave=false;
    QRect m_appPerch;
    QVariantList m_appPerches;
    bool m_fullscreenApp=false;
    bool m_home=false,m_focusHome=false,m_showDesktop=false,m_visibilityReady=false,m_screenLocked=false;QString m_owner,m_liveRun,m_audioStatus="Off · no microphone capture";
    double m_cpu=0,m_gpu=-1,m_loudness=0;qulonglong m_total=0,m_idle=0;int m_gpuTick=0;
    int m_defaultAppearanceStep=0;
    QVariantMap m_petResponse;
    QString m_petWindow,m_petWindowLabel,m_petCloseTarget;
    qint64 m_petCloseDeadline=0;
    QTimer m_cubeLease;
    QVariantList m_bands;QVariantMap m_state,m_config,m_cubeContext;
    QMap<QString,QString> m_workspaces;QString m_currentWorkspace;
};
// Plasma may create more than one QML engine. The facade is per-engine;
// the sensor service, shared game state and settings are per-process.
static DesktopBridge *sharedBackend() {
    static DesktopBridge *backend=new DesktopBridge(QCoreApplication::instance());
    return backend;
}
class DesktopFacade final:public QObject {
    Q_OBJECT
    Q_PROPERTY(bool atHome READ atHome NOTIFY visibilityChanged)
    Q_PROPERTY(bool showingDesktop READ showingDesktop NOTIFY visibilityChanged)
    Q_PROPERTY(bool cubeActive READ cubeActive NOTIFY cubeActiveChanged)
    Q_PROPERTY(QRect appPerch READ appPerch NOTIFY perchChanged)
    Q_PROPERTY(QVariantList appPerches READ appPerches NOTIFY perchChanged)
    Q_PROPERTY(bool fullscreenApp READ fullscreenApp NOTIFY perchChanged)
    Q_PROPERTY(bool visibilityReady READ visibilityReady NOTIFY visibilityChanged)
    Q_PROPERTY(bool sessionLocked READ sessionLocked NOTIFY visibilityChanged)
    Q_PROPERTY(bool hasSave READ hasSave NOTIFY stateChanged)
    Q_PROPERTY(double cpu READ cpu NOTIFY sensorsChanged)
    Q_PROPERTY(double gpu READ gpu NOTIFY sensorsChanged)
    Q_PROPERTY(double loudness READ loudness NOTIFY sensorsChanged)
    Q_PROPERTY(QVariantList bands READ bands NOTIFY sensorsChanged)
    Q_PROPERTY(QString audioStatus READ audioStatus NOTIFY sensorsChanged)
    Q_PROPERTY(QVariantMap state READ state NOTIFY stateChanged)
    Q_PROPERTY(QVariantMap config READ config NOTIFY configChanged)
    Q_PROPERTY(QString desktopFront READ desktopFront NOTIFY workspaceChanged)
    Q_PROPERTY(QStringList screens READ screens NOTIFY screensChanged)
    Q_PROPERTY(bool wallpaperActive READ wallpaperActive NOTIFY wallpaperActiveChanged)
    Q_PROPERTY(bool darkPanel READ darkPanel NOTIFY panelStyleChanged)
    Q_PROPERTY(bool darkApps READ darkApps NOTIFY panelStyleChanged)
    Q_PROPERTY(bool panelStyleBusy READ panelStyleBusy NOTIFY panelStyleChanged)
    Q_PROPERTY(QString panelStyleNotice READ panelStyleNotice NOTIFY panelStyleChanged)
    Q_PROPERTY(QWindow* idleInputWindow READ idleInputWindow WRITE setIdleInputWindow)
public:
    explicit DesktopFacade(QObject *parent=nullptr):QObject(parent),backend(sharedBackend()) {
        connect(backend,&DesktopBridge::visibilityChanged,this,&DesktopFacade::visibilityChanged);
        connect(backend,&DesktopBridge::cubeActiveChanged,this,&DesktopFacade::cubeActiveChanged);
        connect(backend,&DesktopBridge::cubeFallbackRequested,this,&DesktopFacade::cubeFallbackRequested);
        connect(backend,&DesktopBridge::perchChanged,this,&DesktopFacade::perchChanged);
        connect(backend,&DesktopBridge::petCommandRequested,this,&DesktopFacade::petCommandRequested);
        connect(backend,&DesktopBridge::sensorsChanged,this,&DesktopFacade::sensorsChanged);
        connect(backend,&DesktopBridge::stateChanged,this,&DesktopFacade::stateChanged);
        connect(backend,&DesktopBridge::configChanged,this,&DesktopFacade::configChanged);
        connect(backend,&DesktopBridge::commandRequested,this,&DesktopFacade::commandRequested);
        connect(backend,&DesktopBridge::workspaceChanged,this,&DesktopFacade::workspaceChanged);
        connect(backend,&DesktopBridge::screensChanged,this,&DesktopFacade::screensChanged);
        connect(backend,&DesktopBridge::wallpaperActiveChanged,this,&DesktopFacade::wallpaperActiveChanged);
        connect(backend,&DesktopBridge::panelStyleChanged,this,&DesktopFacade::panelStyleChanged);
    }
    bool atHome()const{return backend->atHome();}bool visibilityReady()const{return backend->visibilityReady();}
    bool sessionLocked()const{return backend->sessionLocked();}
    bool showingDesktop()const{return backend->showingDesktop();}
    bool cubeActive()const{return backend->cubeActive();}
    QRect appPerch() const {return backend->appPerch();}
    QVariantList appPerches() const {return backend->appPerches();}
    bool fullscreenApp() const {return backend->fullscreenApp();}
    double cpu()const{return backend->cpu();}double gpu()const{return backend->gpu();}double loudness()const{return backend->loudness();}
    QVariantList bands()const{return backend->bands();}QString audioStatus()const{return backend->audioStatus();}
    QString desktopFront()const{return backend->desktopFront();}
    QStringList screens()const{return backend->screens();}
    bool wallpaperActive()const{return backend->wallpaperActive();}
    bool darkPanel()const{return backend->darkPanel();}
    bool darkApps()const{return backend->darkApps();}
    bool panelStyleBusy()const{return backend->panelStyleBusy();}
    QString panelStyleNotice()const{return backend->panelStyleNotice();}
    QWindow *idleInputWindow() const {return idleWindow.data();}
    void setIdleInputWindow(QWindow *window) {
        if(idleWindow==window) return;
        if(idleWindow) idleWindow->removeEventFilter(this);
        idleWindow=window;
        if(idleWindow) idleWindow->installEventFilter(this);
    }
    Q_INVOKABLE void setDarkPanel(bool enabled){backend->setDarkAppearance(enabled,false);}
    Q_INVOKABLE void setDarkApps(bool enabled){backend->setDarkAppearance(enabled,true);}
    Q_INVOKABLE void refreshPanelStyle(){backend->refreshPanelStyle();}
    Q_INVOKABLE QString petCommand(const QString &json){return backend->PetCommand(json);}
    Q_INVOKABLE void petReply(bool ok,const QString &message){backend->petReply(ok,message);}
    Q_INVOKABLE QString petPath(const QString &input){return backend->petPath(input);}
    Q_INVOKABLE QString petHome()const{return backend->petHome();}
    Q_INVOKABLE QVariantMap petTask(const QString &kind,const QString &first,const QString &second){return backend->petTask(kind,first,second);}
    Q_INVOKABLE QVariantMap petWindow()const{return backend->petWindow();}
    Q_INVOKABLE bool boxReport(const QString &text){return backend->BoxReport(text);}
    Q_INVOKABLE bool openDisplaySettings(bool display) {
        const auto tool=QStandardPaths::findExecutable("systemsettings");
        return !tool.isEmpty() && QProcess::startDetached(tool,{display ? "kcm_kscreen" : "kcm_nightlight"});
    }
    Q_INVOKABLE bool switchWorkspace(const QString &front){return backend->switchWorkspace(front);}
    Q_INVOKABLE bool returnToPlasma(const QUrl &script) {
        backend->restoreWorkspace();
        return runDesktopSwitcher(script,"revert");
    }
    Q_INVOKABLE bool useKdeLayout(const QUrl &script) {
        return backend->wallpaperActive() || runDesktopSwitcher(script,"play");
    }
    QVariantMap state()const{return backend->state();}QVariantMap config()const{return backend->config();}
    Q_INVOKABLE bool claim(const QString &screen,const QString &token){return backend->claim(screen,token);}
    Q_INVOKABLE void release(const QString &token){backend->release(token);}
    Q_INVOKABLE void parkRun(const QString &value){backend->parkRun(value);}
    Q_INVOKABLE QString parkedRun()const{return backend->parkedRun();}
    Q_INVOKABLE void publish(const QVariantMap &value){backend->publish(value);}
    Q_INVOKABLE void publishCubeContext(const QVariantMap &value){backend->publishCubeContext(value);}
    Q_INVOKABLE void requestCube(){backend->requestCube();}
    Q_INVOKABLE QString savedRun()const{return backend->savedRun();}
    Q_INVOKABLE QString previousRun() const {return backend->previousRun();}
    bool hasSave() const {return backend->hasSave();}
    Q_INVOKABLE bool saveRun(const QString &value){return backend->saveRun(value);}
    Q_INVOKABLE QString progress()const{return backend->progress();}
    Q_INVOKABLE void saveProgress(const QString &value){backend->saveProgress(value);}
    Q_INVOKABLE QString mergeProgress(const QString &value){return backend->mergeProgress(value);}
    Q_INVOKABLE void setOption(const QString &key,const QVariant &value){backend->setOption(key,value);}
    Q_INVOKABLE void resetOptions(bool images){backend->resetOptions(images);}
    Q_INVOKABLE void command(const QString &name){backend->Command(name);}
    Q_INVOKABLE void reportHome(bool home){backend->Visibility(home);}
signals:
    void visibilityChanged();void sensorsChanged();void stateChanged();void configChanged();void workspaceChanged();void screensChanged();void commandRequested(const QString &name);
    void wallpaperActiveChanged();void panelStyleChanged();void perchChanged();
    void cubeActiveChanged();void cubeFallbackRequested();
    void petCommandRequested(const QStringList &args);
    void idleKey(int key,int modifiers,bool pressed,bool repeated);
    void idlePointerChanged(bool held);
    void idlePointerMoved(qreal x,qreal y,int modifiers);
private:
    bool eventFilter(QObject *receiver,QEvent *event) override {
        if(receiver==idleWindow.data() && backend->atHome()) {
            if(event->type()==QEvent::KeyPress || event->type()==QEvent::KeyRelease) {
                const auto *key=static_cast<QKeyEvent *>(event);
                emit idleKey(key->key(),int(key->modifiers()),event->type()==QEvent::KeyPress,key->isAutoRepeat());
            } else if(event->type()==QEvent::MouseButtonPress || event->type()==QEvent::MouseButtonRelease) {
                emit idlePointerChanged(static_cast<QMouseEvent *>(event)->buttons()!=Qt::NoButton);
            } else if(event->type()==QEvent::MouseMove) {
                const auto *mouse=static_cast<QMouseEvent *>(event);
                emit idlePointerMoved(mouse->position().x(),mouse->position().y(),int(mouse->modifiers()));
            }
        }
        return false;
    }
    static bool runDesktopSwitcher(const QUrl &script,const QString &action) {
        const auto python=QStandardPaths::findExecutable("python");
        return !python.isEmpty() && script.isLocalFile() && QProcess::startDetached(python,{script.toLocalFile(),action});
    }
    DesktopBridge *backend;
    QPointer<QWindow> idleWindow;
};
class BlackboxDesktopPlugin final: public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override {
        qmlRegisterType<TerminalSession>(uri,1,0,"TerminalSession");
        qmlRegisterType<TerminalView>(uri,1,0,"TerminalView");
        qmlRegisterSingletonType<DesktopFacade>(uri,1,0,"Desktop",[](QQmlEngine *engine,QJSEngine*)->QObject*{
            auto *bridge=new DesktopFacade(engine);return bridge;
        });
    }
};
#include "bridge.moc"
