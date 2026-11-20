import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Rooms.js" as Rooms
import "ViewTurn.js" as ViewTurn

FocusScope {
    id: root
    objectName: "blackboxScene"
    clip: true

    property string mode: "wallpaper"
    property string editsJson: "{}"
    property int durationMs: 480
    property bool showTransitionCaption:true
    property int ambientFps: 24
    property bool motionAllowed: true
    property var roomArtwork:({})
    property Component roomLighting:null
    property Component artworkView:null
    readonly property bool useArtworkView:!!artworkView && !!roomArtwork[room] && (!moving || !!roomArtwork[destination])
    property bool preview: false
    property bool exposed: true
    property bool coverDemo: false

    readonly property bool performance: mode === "performance"
    readonly property bool ambient: !performance && motionAllowed && exposed && !coverDemo && visible
    readonly property string activeTitle: Rooms.title(room, edits)
    readonly property var edits: Rooms.readEdits(editsJson)
    readonly property var current: Rooms.rooms[room]
    readonly property color accent: mode === "performance" ? "#b5e9bc" : current.accent

    property string room: "shrine"
    property string destination: ""
    property string transitionKind: ""
    property string transitionLabel: ""
    readonly property string lookDirection:({lookLeft:"left",lookRight:"right",lookUp:"up",lookDown:"down"})[transitionKind] || ""
    readonly property bool looking:moving && lookDirection.length>0
    readonly property bool artworkDescent:moving && !!roomArtwork.abyss && ["drop","rise"].includes(transitionKind)
    readonly property bool returningFromAbyss:transitionKind==="rise"
    property real progress: 0
    property int frames: 0
    property real ambientSeconds:0
    property int phase: 0
    property int abyssVariant: 0
    property int selectedStar: -1
    property int constellationSeed: 0
    property bool drawerOpen: false
    property bool clean: false
    property bool externalChrome:false
    property Item chromeSurface:null
    property real chromeOpacity:1
    property real chromeBottom:0
    property bool buildsOpen:false
    property var navigationKeyHandler:null
    property bool audioDemo: false
    property int demoCpu: 12
    property int demoGpu: 20
    property bool loadDemo: false
    property int demoTrack: 0
    readonly property var demoTracks: ["Dusk at the Shrine", "Abyssal Current", "Constellation Drift"]
    property string detail: ""
    property string editRoom: "shrine"
    property string pickRoom: ""
    property string imageError: ""
    property string invalidImage: ""
    readonly property bool artReady: useArtworkView || base.status === Image.Ready
    readonly property bool moving: destination.length > 0
    readonly property real signalLevel: audioDemo && ambient
        ? .24 + .58 * Math.pow(Math.max(0, Math.sin(phase * Math.PI / 14)), 6) : 0
    readonly property string wallSource: artFor(room) === invalidImage ? defaultArt(room) : artFor(room)

    signal settingsUpdated()

    function artFor(id) {
        var custom = edits[id] && edits[id].image
        return typeof custom === "string" && custom.indexOf("file:") === 0
            ? custom : defaultArt(id)
    }

    function defaultArt(id) {
        if (roomArtwork[id]) return String(roomArtwork[id])
        return String(Qt.resolvedUrl("../images/" +
            (id === "abyss" && abyssVariant ? "trench.jpg" : Rooms.rooms[id].image)))
    }

    function starPoint(star, index) {
        var angle = constellationSeed * 2.399963 + index * 1.618034
        var amount = constellationSeed ? .025 : 0
        return Qt.point(star.x + Math.cos(angle) * amount, star.y + Math.sin(angle) * amount)
    }

    property var extraRoutes:({})
    property var extraTransitions:({})
    function neighbor(direction) {
        return extraRoutes[room]?.[direction] || Rooms.routes[room]?.[direction]
    }
    function move(direction, instant) {
        var next = neighbor(direction)
        if (next)
            go(next,instant)
    }

    function stopTransition() {
        travel.stop()
        if (destination)
            commit()
    }

    function commit() {
        room = destination
        destination = ""
        progress = 0
        selectedStar = -1
        detail = ""
    }

    function go(id, instant) {
        if (!Object.prototype.hasOwnProperty.call(Rooms.rooms, id))
            return
        if (moving) {
            if (!instant)
                return
            stopTransition()
        }
        if (id === room)
            return
        imageError = ""
        invalidImage = ""
        if (id === "abyss" && !roomArtwork.abyss && !performance)
            abyssVariant = (abyssVariant + 1) % 2
        destination = id
        var decision = extraTransitions[room + ":" + id] || Rooms.transitions[room + ":" + id]
        transitionKind = decision ? decision.kind : "cross"
        transitionLabel = decision?.label || "Travel to " + Rooms.rooms[id].name
        if (instant || performance || !motionAllowed || durationMs === 0 || !exposed || coverDemo) {
            commit()
        } else {
            progress = 0
            travel.start()
        }
    }

    function changeMode(value) {
        mode = value === "performance" ? value : "wallpaper"
        settingsUpdated()
    }

    function updateRoom(id, field, value) {
        var copy = Rooms.readEdits(editsJson)
        var edit = copy[id] || {}
        if (value)
            edit[field] = value
        else
            delete edit[field]
        copy[id] = edit
        invalidImage = ""
        imageError = ""
        editsJson = JSON.stringify(copy)
        settingsUpdated()
    }

    function openEditor() {
        editRoom = room
        drawerOpen = true
    }

    function run(action) {
        if (action.target) {
            go(action.target)
        } else if (action.action === "variant") {
            if (edits.abyss && edits.abyss.image)
                detail = "Restore the Abyss sample image to cycle the built-in variants."
            else
                abyssVariant = (abyssVariant + 1) % 2
        } else if (action.action === "clean") {
            clean = true
        } else if (action.action === "edit") {
            openEditor()
        } else {
            detail = detail === action.detail ? "" : action.detail
        }
    }

    onPerformanceChanged: if (performance) stopTransition()
    onMotionAllowedChanged: if (!motionAllowed) stopTransition()
    onExposedChanged: if (!exposed) stopTransition()
    onCoverDemoChanged: if (coverDemo) stopTransition()

    NumberAnimation {
        id: travel
        target: root
        property: "progress"
        from: 0
        to: 1
        duration: root.durationMs
        easing.type: Easing.InOutCubic
        onFinished: root.commit()
    }

    Timer {
        id: ambientTimer
        objectName: "ambientTimer"
        interval: Math.round(1000 / Math.max(1, root.ambientFps))
        repeat: true
        running: root.ambient && (root.roomLighting || !root.clean && !root.moving && (root.audioDemo || ["sky","abyss","lab"].includes(root.room)))
        onTriggered: {
            root.frames += 1
            root.ambientSeconds += interval/1000
            root.phase = (root.phase + 1) % 1680
        }
    }

    FileDialog {
        id: picker
        objectName: "artPicker"
        title: "Choose artwork for " + Rooms.title(root.pickRoom || root.room, root.edits)
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.bmp)"]
        onAccepted: root.updateRoom(root.pickRoom, "image", String(selectedFile))
    }

    Rectangle {
        anchors.fill: parent
        color: "#080b13"
    }

    Loader {
        anchors.fill:parent
        active:!!root.artworkView
        visible:root.useArtworkView
        sourceComponent:root.artworkView
    }

    Image {
        id: base
        visible:!root.useArtworkView
        objectName: "roomImage"
        anchors.fill: parent
        source: root.useArtworkView ? "" : root.wallSource
        sourceSize.width: Math.min(3840, Math.max(1600, Math.ceil(root.width * Screen.devicePixelRatio)))
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        opacity: root.moving && !root.looking && !root.artworkDescent ? Math.min(1, 1.42 - root.progress * 1.42) : 1
        x: 0
        readonly property var descent:root.artworkDescent ? ViewTurn.descent(height,root.progress,false,root.returningFromAbyss,1)
            : ({scale:root.moving && root.transitionKind==="drop" ? 1+root.progress*.52 : 1,y:0})
        scale:descent.scale

        transform: [
            Translate {y:base.descent.y},
            Matrix4x4 {matrix:root.looking ? ViewTurn.panel(root.width,root.height,root.lookDirection,root.progress,false,1) : ViewTurn.identity()}
        ]
        Loader {
            anchors.centerIn:parent
            width:base.paintedWidth;height:base.paintedHeight
            readonly property string sceneRoom:root.room
            readonly property bool customImage:String(base.source)!==root.defaultArt(sceneRoom)
            active:base.visible && !!root.roomLighting && base.status===Image.Ready && !!root.roomArtwork[sceneRoom]
            sourceComponent:root.roomLighting
        }
        onStatusChanged: {
            if (status === Image.Error && String(source) !== root.defaultArt(root.room)) {
                var failed = String(source)
                Qt.callLater(function() {
                    if (String(base.source) === failed && base.status === Image.Error) {
                        root.imageError = "Image unavailable. Showing the sample artwork."
                        root.invalidImage = failed
                    }
                })
            }
        }

    }

    Image {
        id: incoming
        anchors.fill: parent
        visible: root.moving && !root.useArtworkView
        source: visible ? root.artFor(root.destination) : ""
        sourceSize: base.sourceSize
        fillMode: Image.PreserveAspectCrop
        cache: false
        opacity: root.looking ? 1 : root.artworkDescent ? root.progress : Math.max(0, (root.progress - .19) / .81)
        readonly property var descent:root.artworkDescent ? ViewTurn.descent(height,root.progress,true,root.returningFromAbyss,1)
            : ({scale:1,y:0})
        scale: {
            if (root.artworkDescent)
                return descent.scale
            if (root.transitionKind === "drop")
                return 1 + (1 - root.progress) * .30
            if (root.transitionKind === "rise")
                return .86 + root.progress * .14
            return 1
        }
        transform: [
            Translate {y:incoming.descent.y},
            Matrix4x4 {matrix:root.looking ? ViewTurn.panel(root.width,root.height,root.lookDirection,root.progress,true,1) : ViewTurn.identity()}
        ]
        Loader {
            anchors.centerIn:parent
            width:incoming.paintedWidth;height:incoming.paintedHeight
            readonly property string sceneRoom:root.destination
            readonly property bool customImage:sceneRoom.length>0 && String(incoming.source)!==root.defaultArt(sceneRoom)
            active:!!root.roomLighting && incoming.status===Image.Ready && !!root.roomArtwork[sceneRoom]
            sourceComponent:root.roomLighting
        }
    }

    TurnJoin {
        anchors.fill:parent
        active:root.looking && !root.useArtworkView;outgoing:base;direction:root.lookDirection;progress:root.progress
    }
    DescentShade {
        anchors.fill:parent
        progress:root.artworkDescent && !root.useArtworkView ? root.progress : 0
    }

    Rectangle {
        anchors.fill: parent
        visible: root.moving && !root.artworkDescent && root.transitionKind === "drop"
        color: "#02040a"
        opacity: Math.sin(root.progress * Math.PI) * .85
    }

    Rectangle {
        visible: root.moving && !root.artworkDescent && root.transitionKind === "drop" && root.progress < .66
        width: root.width * (.08 + root.progress * 2.85)
        height: width * (.24 + root.progress * .51)
        x: (root.width - width) / 2
        y: root.height * (.85 - root.progress * .60) - height / 2
        radius: height / 2
        color: "#03050b"
        border.color: "#343b42"
        border.width: Math.max(2, root.width * .008 * (1 - root.progress))
        opacity: Math.min(1, (1 - root.progress / .66) * 3.8)
    }

    Repeater {
        model: root.ambient && !root.moving && !root.clean && ["sky", "abyss", "lab"].indexOf(root.room) >= 0 ? 20 : 0

        Rectangle {
            x: root.width * (((index * 97) % 997) / 997 + .022 * Math.sin(root.phase * .026 + index))
            y: root.height * (.14 + ((index * 37) % 63) / 100 + .026 * Math.cos(root.phase * .018 + index))
            width: 2 + index % 3
            height: width
            radius: width / 2
            color: root.accent
            opacity: .12 + (root.loadDemo ? root.demoGpu / 280 : .34) *
                Math.pow((1 + Math.sin(root.phase * .045 + index)) / 2, 2)
        }
    }

    Item {
        parent:root.chromeSurface || root
        anchors.fill:parent
        z:1
        opacity:root.chromeOpacity
        visible:opacity>0
        enabled:!root.externalChrome || opacity>.95
        Item {
            id: constellation
            anchors.fill: parent
            visible: root.room === "sky" && !root.moving && !root.clean && !root.drawerOpen
            objectName: "constellation"

            Canvas {
                id: constellationLines
                anchors.fill: parent
                visible: !root.performance
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onVisibleChanged: if (visible) requestPaint()
                Connections {
                    target: root
                    function onConstellationSeedChanged() { constellationLines.requestPaint() }
                }
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.beginPath()
                    ctx.lineWidth = 1
                    ctx.strokeStyle = "#9ab5ef"
                    ctx.globalAlpha = .52
                    Rooms.stars.forEach(function(star, index) {
                        var point = root.starPoint(star, index)
                        if (index === 0)
                            ctx.moveTo(point.x * width, point.y * height)
                        else
                            ctx.lineTo(point.x * width, point.y * height)
                    })
                    ctx.stroke()
                }
            }

            Repeater {
                model: Rooms.stars
                Button {
                    id: starButton
                    required property var modelData
                    required property int index
                    objectName: "star-" + index
                    readonly property point starPosition: root.starPoint(modelData, index)
                    x: constellation.width * starPosition.x - width / 2
                    y: constellation.height * starPosition.y - height / 2
                    width: 44
                    height: 44
                    text: modelData.title
                    hoverEnabled: true
                    Accessible.name: text
                    ToolTip.visible: hovered || activeFocus
                    ToolTip.text: text
                    onClicked: {
                        root.selectedStar = root.selectedStar === index ? -1 : index
                        root.detail = ""
                    }
                    contentItem: Item {}
                    background: Rectangle {
                        anchors.centerIn: parent
                        width: root.selectedStar === starButton.index || starButton.hovered || starButton.visualFocus ? 20 : 12
                        height: width
                        radius: width / 2
                        color: "#e8eaff"
                        border.width: 4
                        border.color: "#8d90ce"
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            visible: !root.clean
            gradient: Gradient {
                GradientStop { position: 0; color: "#c4080b14" }
                GradientStop { position: .19; color: "#00080b14" }
                GradientStop { position: .49; color: "#00080b14" }
                GradientStop { position: .74; color: root.externalChrome ? "#00080b14" : "#84080b14" }
                GradientStop { position: 1; color: root.externalChrome ? "#28080b14" : "#f5080b14" }
            }
        }

        RowLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: root.width < 800 ? 14 : 24
            spacing: 9
            visible: !root.clean
            z: 2

            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true
                Text {
                    text: "PROJECT BLACKBOX"
                    font.pixelSize: root.width < 640 ? 13 : 15
                    font.weight: Font.DemiBold
                    font.letterSpacing: 2.1
                    color: "#f2f0f4"
                }
                Text {
                    text: root.preview ? "Звезден Дъщ  /  Desktop simulation" : "Звезден Дъщ"
                    color: "#bdc5d5"
                    font.pixelSize: 12
                    visible: root.width >= 595
                }
            }

            Row {
                spacing: 8
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                BlackboxButton {
                    text: "Wallpaper"
                    objectName: "wallpaperMode"
                    selected: !root.performance
                    accent: root.accent
                    compact: root.width < 740
                    onClicked: root.changeMode("wallpaper")
                }
                BlackboxButton {
                    text: "Performance"
                    objectName: "performanceMode"
                    selected: root.performance
                    accent: root.accent
                    compact: root.width < 740
                    onClicked: root.changeMode("performance")
                }
                BlackboxButton {
                    text: root.externalChrome ? "Scene editor" : "Edit"
                    objectName: "editButton"
                    compact: root.width < 740
                    onClicked: root.drawerOpen ? root.drawerOpen = false : root.openEditor()
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.showTransitionCaption && root.moving && !root.clean
            text: root.transitionLabel
            color: "#f2f1fa"
            font.pixelSize: 16
            font.letterSpacing: 1.2
            opacity: Math.sin(root.progress * Math.PI)
        }

        ColumnLayout {
            objectName:"legacySceneDetails"
            anchors.left: parent.left
            anchors.right: directionPad.left
            anchors.bottom: dock.top
            anchors.leftMargin: root.width < 800 ? 14 : 24
            anchors.rightMargin: 16
            anchors.bottomMargin: 15
            visible: !root.externalChrome && !root.clean && !root.moving
            spacing: 8
            z: 1

            Text {
                text: root.activeTitle
                font.pixelSize: root.width < 800 ? 33 : 49
                font.weight: Font.DemiBold
                color: "#f2f3fa"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: root.current.subtitle
                font.pixelSize: 14
                color: "#d0d6e3"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            Flow {
                spacing: 7
                Layout.fillWidth: true
                Repeater {
                    model: (Rooms.actions[root.room] || []).filter(function(action){return action.action!=="variant" || !root.roomArtwork.abyss})
                    BlackboxButton {
                        required property var modelData
                        text: modelData.title
                        compact: true
                        accent: root.accent
                        onClicked: root.run(modelData)
                    }
                }
                BlackboxButton {
                    visible: root.room === "sky"
                    text: "New constellation"
                    objectName: "reshuffleStars"
                    compact: true
                    onClicked: root.constellationSeed = (root.constellationSeed + 1) % 9999
                }
                BlackboxButton {
                    visible: root.room === "sky" && root.selectedStar >= 0
                    text: root.selectedStar >= 0 ? Rooms.stars[root.selectedStar].title + "  ↗" : ""
                    compact: true
                    accent: root.accent
                    onClicked: root.go(Rooms.stars[root.selectedStar].target)
                }
            }
            Text {
                visible: text.length > 0
                text: root.imageError || root.detail || (root.selectedStar >= 0 ? Rooms.stars[root.selectedStar].detail : "")
                font.pixelSize: 13
                color: "#ecedf5"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        GridLayout {
            id: directionPad
            anchors.right: parent.right
            anchors.bottom: root.externalChrome ? parent.bottom : dock.top
            anchors.rightMargin: root.width < 800 ? 14 : 24
            anchors.bottomMargin: 15+root.chromeBottom
            columns: 3
            rowSpacing: 5
            columnSpacing: 5
            visible: !root.clean && !root.moving
            z: 1

            Repeater {
                model: [
                    { key: "up", symbol: "↑", row: 0, column: 1 },
                    { key: "left", symbol: "←", row: 1, column: 0 },
                    { key: "home", symbol: "⌂", row: 1, column: 1 },
                    { key: "right", symbol: "→", row: 1, column: 2 },
                    { key: "down", symbol: "↓", row: 2, column: 1 }
                ]
                BlackboxButton {
                    required property var modelData
                    objectName: "nav-" + modelData.key
                    text: modelData.symbol
                    Layout.row: modelData.row
                    Layout.column: modelData.column
                    Layout.preferredWidth: 36
                    compact: true
                    enabled: modelData.key === "home" || !!root.neighbor(modelData.key)
                    Accessible.name: modelData.key === "home" ? "Return to Home Shrine" : "Move " + modelData.key
                    ToolTip.visible: hovered && enabled
                    ToolTip.text: modelData.key === "home" ? "Return to Home Shrine"
                        : enabled ? Rooms.title(root.neighbor(modelData.key), root.edits) : ""
                    onClicked: modelData.key === "home" ? root.go("shrine", true) : root.move(modelData.key)
                }
            }
        }

        Rectangle {
            id: dock
            objectName:"legacySceneDock"
            visible: !root.externalChrome && !root.clean
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: dockFlow.implicitHeight + 17
            color: "#ec101624"
            z: 1

            Rectangle { width: parent.width; height: 1; color: "#3c4658" }

            Flow {
                id: dockFlow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 9
                anchors.top: parent.top
                spacing: 6

                Repeater {
                    model: Rooms.order
                    BlackboxButton {
                        required property string modelData
                        objectName: "room-" + modelData
                        text: Rooms.title(modelData, root.edits)
                        compact: true
                        selected: root.room === modelData
                        accent: root.accent
                        width: Math.min(implicitWidth, 150)
                        onClicked: root.go(modelData)
                    }
                }
                BlackboxButton {
                    text: root.audioDemo ? "Pause demo pulse" : "Demo pulse"
                    objectName: "audioDemo"
                    compact: true
                    enabled: !root.performance
                    onClicked: root.audioDemo = !root.audioDemo
                }
                BlackboxButton {
                    visible: root.audioDemo && !root.performance
                    text: root.demoTracks[root.demoTrack] + "  ›"
                    compact: true
                    ToolTip.visible: hovered
                    ToolTip.text: "Simulated now playing · switch demo track"
                    onClicked: root.demoTrack = (root.demoTrack + 1) % root.demoTracks.length
                }
                Rectangle {
                    width: 54
                    height: 34
                    radius: 6
                    color: "#1a2130"
                    visible: root.audioDemo && !root.performance
                    Row {
                        anchors.centerIn: parent
                        spacing: 3
                        Repeater {
                            model: 5
                            Rectangle {
                                width: 4
                                height: 4 + (20 - Math.abs(index - 2) * 4) * root.signalLevel
                                radius: 2
                                color: root.accent
                                anchors.bottom: parent.bottom
                            }
                        }
                    }
                }
                BlackboxButton {
                    visible: root.loadDemo
                    enabled: false
                    text: "Demo  CPU " + root.demoCpu + "%  ·  GPU " + root.demoGpu + "%"
                    compact: true
                }
                BlackboxButton {
                    text: "Artwork only"
                    objectName: "cleanButton"
                    compact: true
                    onClicked: root.clean = true
                }
            }
        }
    }

    BlackboxButton {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 13
        visible: root.clean && !root.externalChrome
        text: "Show controls"
        objectName: "showControls"
        compact: true
        z: 2
        onClicked: root.clean = false
    }

    Rectangle {
        visible: root.drawerOpen
        anchors.fill: parent
        color: "#7604070c"
        z: 3
        TapHandler { onTapped: root.drawerOpen = false }
    }

    Rectangle {
        id: editor
        objectName: "editor"
        width: Math.min(370, parent.width - 24)
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 12
        anchors.bottomMargin:12+root.chromeBottom
        visible: root.drawerOpen
        color: "#111826"
        border.color: "#414c61"
        radius: 10
        clip: true
        z: 4

        ScrollView {
            anchors.fill: parent
            anchors.margins: 16
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Scene editor"
                        color: "#f2f3fa"
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }
                    BlackboxButton { text: "Done"; objectName: "doneEditing"; compact: true; onClicked: root.drawerOpen = false }
                }

                BlackboxButton {
                    text: "Builds"
                    objectName: "sceneEditorBuilds"
                    compact: true
                    selected: root.buildsOpen
                    onClicked: root.buildsOpen = !root.buildsOpen
                }
                Text {
                    visible:root.buildsOpen
                    Layout.fillWidth:true
                    color:"#b4bfd2"
                    wrapMode:Text.WordWrap
                    text:"Build and export directories can be linked here when the native build integration is available."
                }

                Label { text: "Environment"; color: "#c8cfda" }
                ComboBox {
                    objectName: "editRoom"
                    Layout.fillWidth: true
                    model: Rooms.order.map(function(id) { return Rooms.rooms[id].name })
                    currentIndex: Rooms.order.indexOf(root.editRoom)
                    onActivated: root.editRoom = Rooms.order[index]
                }

                Label { text: "Display name"; color: "#c8cfda" }
                RowLayout {
                    Layout.fillWidth: true
                    TextField {
                        id: nameField
                        objectName: "roomName"
                        Layout.fillWidth: true
                        selectByMouse: true
                        maximumLength: 36
                        text: Rooms.title(root.editRoom, root.edits)
                        onAccepted: root.updateRoom(root.editRoom, "name", text.trim())
                    }
                    BlackboxButton {
                        text: "Save"
                        objectName: "saveName"
                        compact: true
                        onClicked: root.updateRoom(root.editRoom, "name", nameField.text.trim())
                    }
                }
                RowLayout {
                    BlackboxButton {
                        text: "Choose image…"
                        objectName: "chooseImage"
                        onClicked: { root.pickRoom = root.editRoom; picker.open() }
                    }
                    BlackboxButton {
                        text: "Restore sample"
                        objectName: "restoreImage"
                        enabled: !!(root.edits[root.editRoom] && root.edits[root.editRoom].image)
                        onClicked: root.updateRoom(root.editRoom, "image", "")
                    }
                }
                Text {
                    color: "#b4bfd2"
                    text: root.edits[root.editRoom] && root.edits[root.editRoom].image
                        ? root.edits[root.editRoom].image.split("/").pop()
                        : "Built-in " + Rooms.rooms[root.editRoom].image
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAnywhere
                    font.pixelSize: 12
                }
                Rectangle { Layout.fillWidth: true; Layout.topMargin: 3; height: 1; color: "#38465c" }

                Label { text: "Camera transition · " + root.durationMs + " ms"; color: "#d6dbeb" }
                Slider {
                    objectName: "transitionDuration"
                    Layout.fillWidth: true
                    from: 200
                    to: 900
                    stepSize: 20
                    value: root.durationMs
                    onMoved: { root.durationMs = Math.round(value); root.settingsUpdated() }
                }
                Label { text: "Ambient effects · " + root.ambientFps + " fps"; color: "#d6dbeb" }
                Slider {
                    objectName: "ambientFps"
                    Layout.fillWidth: true
                    from: 8
                    to: 30
                    stepSize: 1
                    value: root.ambientFps
                    onMoved: { root.ambientFps = Math.round(value); root.settingsUpdated() }
                }

                CheckBox {
                    objectName: "motionSetting"
                    palette.windowText: "#d6dbeb"
                    text: "Enable motion in Wallpaper mode"
                    checked: root.motionAllowed
                    onToggled: { root.motionAllowed = checked; root.settingsUpdated() }
                }
                CheckBox {
                    objectName: "coveredSetting"
                    palette.windowText: "#d6dbeb"
                    visible: root.preview
                    text: "Simulate a covered desktop"
                    checked: root.coverDemo
                    onToggled: root.coverDemo = checked
                }
                CheckBox {
                    text: "Show sample CPU and GPU values"
                    palette.windowText: "#d6dbeb"
                    checked: root.loadDemo
                    onToggled: root.loadDemo = checked
                }
                Label {
                    visible: root.loadDemo
                    text: "Sample CPU " + root.demoCpu + "%  ·  GPU " + root.demoGpu + "%"
                    color: "#d6dbeb"
                }
                RowLayout {
                    visible: root.loadDemo
                    Layout.fillWidth: true
                    Slider {
                        Layout.fillWidth: true
                        from: 0; to: 100; stepSize: 1
                        value: root.demoCpu
                        onMoved: root.demoCpu = Math.round(value)
                        Accessible.name: "Sample CPU utilisation"
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 0; to: 100; stepSize: 1
                        value: root.demoGpu
                        onMoved: root.demoGpu = Math.round(value)
                        Accessible.name: "Sample GPU utilisation"
                    }
                }
                Text {
                    color: "#b4bfd2"
                    text: root.performance ? "Performance mode stops scene motion and the demo pulse."
                        : (!root.exposed || root.coverDemo) ? "Rendering paused while covered." : "Use the arrows to navigate. Home returns to the Shrine."
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                }
            }
        }
    }

    Shortcut {
        sequence: "Esc"
        context: Qt.WindowShortcut
        enabled: root.drawerOpen || root.clean
        onActivated: {
            root.drawerOpen = false
            root.clean = false
            root.forceActiveFocus()
        }
    }

    Keys.priority: Keys.BeforeItem
    Keys.onPressed: function(event) {
        if (root.drawerOpen || root.clean) {
            return
        } else if (root.navigationKeyHandler && event.key !== Qt.Key_Home) {
            const direction=root.navigationKeyHandler(event)
            if (!direction) return
            if (!event.isAutoRepeat) root.move(direction)
        } else if (event.key === Qt.Key_Up) {
            root.move("up")
        } else if (event.key === Qt.Key_Down) {
            root.move("down")
        } else if (event.key === Qt.Key_Left) {
            root.move("left")
        } else if (event.key === Qt.Key_Right) {
            root.move("right")
        } else if (event.key === Qt.Key_Home) {
            root.go("shrine", true)
        } else {
            return
        }
        event.accepted = true
    }
}
