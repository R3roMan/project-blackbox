import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GridLayout {
    id: settings
    required property string fit
    required property int quality
    required property real zoom
    property int frameLimit:60
    property bool showTimer:false
    signal frameLimitChangedByUser(int value)
    signal timerChangedByUser(bool value)
    property int detail:1
    property string transitionStyle:"cinematic"
    property real transitionStrength:1
    signal fitChangedByUser(string value)
    signal qualityChangedByUser(int value)
    signal zoomChangedByUser(real value)
    signal detailChangedByUser(int value)
    signal transitionStyleChangedByUser(string value)
    signal transitionStrengthChangedByUser(real value)
    columns: 2
    rowSpacing: 8
    columnSpacing: 16

    component SettingLabel:Label {
        color:"#e1d1df"
        font.family:"Inter"
        font.pixelSize:13
    }

    SettingLabel { text: "Wallpaper framing" }
    ComboBox {
        objectName: "wallpaperFit"
        Layout.fillWidth: true
        model: ["Fill screen", "Fit entire image", "Stretch"]
        readonly property var modes: ["fill", "fit", "stretch"]
        currentIndex: Math.max(0, modes.indexOf(settings.fit))
        onActivated: settings.fitChangedByUser(modes[currentIndex])
    }
    SettingLabel { text: "Render resolution cap" }
    ComboBox {
        objectName: "wallpaperQuality"
        Layout.fillWidth: true
        model: ["Auto · 1440p scene / native wallpaper", "2160p", "1440p", "1080p"]
        readonly property var resolutions: [0, 2160, 1440, 1080]
        currentIndex: Math.max(0, resolutions.indexOf(settings.quality))
        onActivated: settings.qualityChangedByUser(resolutions[currentIndex])
    }
    SettingLabel { text: "Wallpaper zoom · " + Math.round(settings.zoom * 100) + "%" }
    Slider {
        objectName: "wallpaperZoom"
        Layout.fillWidth: true
        from: 1
        to: 1.4
        stepSize: .05
        value: settings.zoom
        onMoved: settings.zoomChangedByUser(value)
    }
    SettingLabel {text:"3D edge quality"}
    ComboBox {
        objectName:"graphicsDetail"
        Layout.fillWidth:true
        model:["Low","Standard","High"]
        currentIndex:settings.detail
        onActivated:settings.detailChangedByUser(currentIndex)
    }
    SettingLabel {text:"Screen transitions"}
    ComboBox {
        objectName:"transitionStyle"
        Layout.fillWidth:true
        model:["Cinematic 3D","Soft dissolve"]
        currentIndex:settings.transitionStyle === "cinematic" ? 0 : 1
        onActivated:settings.transitionStyleChangedByUser(currentIndex ? "soft" : "cinematic")
    }
    SettingLabel {text:"Transition depth · "+Math.round(settings.transitionStrength*100)+"%"}
    Slider {
        objectName:"transitionStrength"
        Layout.fillWidth:true
        from:.4; to:1.4; stepSize:.1; value:settings.transitionStrength
        onMoved:settings.transitionStrengthChangedByUser(value)
    }
    SettingLabel {text:"Frame limit · custom"}
    SpinBox {objectName:"frameLimit";from:20;to:240;stepSize:5;editable:true;value:settings.frameLimit;onValueModified:settings.frameLimitChangedByUser(value)}
    SettingLabel {text:"Wave timer · period key"}
    CheckBox {objectName:"showWaveTimer";checked:settings.showTimer;onClicked:settings.timerChangedByUser(checked)}

}
