# Rebuild the V0.1 Blackbox wallpaper

This is a hands-on walk through the original seven-room template. You will make a small version with two rooms, follow the same pattern to build the full scene, and package the original version for a trial. All editing takes place in a practice folder. You can compare the result with the project's [original preview](../V0.1/Preview.qml) whenever you get stuck.

## 1 · Set up your workbench

Open **Konsole**. A shell is the program that reads the commands you type there. This project uses `qml6` to open QML files directly. `pacman -Q` asks Arch what is installed.

```bash
pacman -Q qt6-declarative plasma-workspace
blackbox_source=/home/blaxim/Projects/PROJECT-BLACKBOX/V0.1
blackbox_lab=$(mktemp -d "$HOME/blackbox-v01.XXXXXX")
mkdir -p "$blackbox_lab/kde/contents/"{ui,images,config}
mkdir -p "$blackbox_lab/settings"
cp "$blackbox_source/kde/contents/images/"* "$blackbox_lab/kde/contents/images/"
cd "$blackbox_lab"
pwd
```

`$HOME` stands for your home folder. A shell variable such as `blackbox_lab` remembers a value in this terminal. The quotes let the path contain spaces. `pwd` prints the new location. Write that path down before closing Konsole.

In **Dolphin**, press **Ctrl+L**, paste the printed path, and press Enter. Open the QML and JS files below with **Kate**. To create a file in Kate, use **File → New**, paste the block, then **Save As** in the named location. Use the literal extensions `.qml` or `.js`.

## 2 · Describe two rooms in JavaScript

Save this as `kde/contents/ui/Rooms.js` inside the practice folder.

```javascript
.pragma library

var rooms = {
    shrine: { name: "Home Shrine", image: "shrine.png" },
    sky: { name: "Star Sky", image: "sky.jpg" }
}

var routes = {
    shrine: { up: "sky" },
    sky: { down: "shrine" }
}
```

`shrine` and `sky` are stable IDs. Names are what people read on the screen. An object holds named values. `routes.shrine.up` returns the ID `"sky"`. The image files already exist in the adjacent `images` directory. See the [original room data](../V0.1/kde/contents/ui/Rooms.js) for all seven rooms and the two loops.

## 3 · Build one scene and run it in a window

Save this as `kde/contents/ui/Scene.qml`.

```qml
import QtQuick
import QtQuick.Controls
import "Rooms.js" as Rooms

FocusScope {
    id: scene
    property string room: "shrine"
    clip: true

    function move(direction) {
        const next = Rooms.routes[scene.room][direction]
        if (next)
            scene.room = next
    }

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../images/" + Rooms.rooms[scene.room].image)
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 80
        color: "#e51a1420"

        Row {
            anchors.centerIn: parent
            spacing: 12

            Label {
                text: Rooms.rooms[scene.room].name
                color: "#fff3e7"
                font.pixelSize: 24
            }
            Button {
                text: scene.room === "shrine" ? "Look up" : "Return to Shrine"
                onClicked: scene.move(scene.room === "shrine" ? "up" : "down")
            }
        }
    }

    Keys.onUpPressed: scene.move("up")
    Keys.onDownPressed: scene.move("down")
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Home) {
            scene.room = "shrine"
            event.accepted = true
        }
    }
}
```

Save this second file as `Preview.qml` at the top of your practice folder.

```qml
import QtQuick
import QtQuick.Controls
import "kde/contents/ui"

ApplicationWindow {
    width: 1000
    height: 620
    visible: true
    title: "Blackbox practice"

    Scene {
        anchors.fill: parent
        focus: true
    }
}
```

Run it from the practice terminal.

```bash
qml6 Preview.qml
```

Click **Look up**, press Down, then press Up and Home. If your current folder differs from the one printed earlier, use `cd "$blackbox_lab"` first. If the terminal gives a QML error, start with the first filename and line number. Save the change, close the window and run the command again.

### Follow one click

1. `onClicked` is a signal handler. Qt runs its JavaScript when the button is clicked.
2. `move("up")` looks at `routes` using the current room, finds `"sky"` and assigns it to `scene.room`.
3. `source` is a binding that reads `scene.room`. Its value changes to the relative path of the new picture. `Label.text` reads the same property and updates too.
4. `id: scene` is a reference for objects in this file. `anchors.fill: parent` tells an item to match its parent's bounds. `FocusScope` groups keyboard focus inside the scene.

Change Star Sky's name in Rooms.js. Predict which label changes and which route still works. Then try changing one wrong character in an image filename to see how a load error looks. Restore it before continuing.

## 4 · Turn an immediate swap into a transition

Your current scene commits the destination on the click. The original V0.1 scene holds the destination and draws the old and new art during a short animation. Try a crossfade first.

In the practice `Scene.qml`, add these properties after `property string room`. Replace `move()` with these two functions and add the animation just before the first `Image`.

```qml
    property string destination: ""
    property real progress: 0
    property bool performance: false

    function finishTravel() {
        if (destination === "")
            return
        room = destination
        destination = ""
        progress = 0
    }

    function move(direction) {
        if (destination !== "")
            return
        const next = Rooms.routes[room][direction]
        if (!next)
            return
        destination = next
        if (performance)
            finishTravel()
        else
            travel.start()
    }

    NumberAnimation {
        id: travel
        target: scene
        property: "progress"
        from: 0
        to: 1
        duration: 480
        easing.type: Easing.InOutCubic
        onFinished: scene.finishTravel()
    }
```

Add this second `Image` between the first `Image` and the bottom bar. The incoming picture appears above the original and below the controls because of its position in the file.

```qml
    Image {
        anchors.fill: parent
        source: scene.destination === "" ? "" : Qt.resolvedUrl("../images/" + Rooms.rooms[scene.destination].image)
        fillMode: Image.PreserveAspectCrop
        opacity: scene.progress
    }
```

Inside the Home key handler, before setting `scene.room`, add `travel.stop()`, `scene.destination = ""` and `scene.progress = 0` on separate lines. This cancels travel if Home is pressed in the middle. Test at 480 milliseconds, change it to 1000, and then set `performance` to `true` and rerun. A destination and a current room can legitimately differ during one move.

Open the [original Scene.qml](../V0.1/kde/contents/ui/Scene.qml). Find `go()`, `commit()`, `progress`, `transitionKind` and the second image. The seven-room version picks a transition from `Rooms.transitions`, uses translation and rotation for the look directions, and draws extra QML shapes for the drop, vault and star burst. These effects move image layers. The 3D design in the roadmap gives the camera real geometry for the motion to reveal.

## 5 · Add a star you can select

In the practice scene, add the block below before the bottom bar. Try Up and click the star near the top.

```qml
    Button {
        visible: scene.room === "sky" && scene.destination === ""
        x: parent.width * 0.52
        y: parent.height * 0.27
        text: "★ Return to Shrine"
        onClicked: scene.move("down")
    }
```

Original V0.1 uses a `Repeater` to make one such button per entry in `Rooms.stars`. Each `modelData` provides the star's location, title and destination. Its first click selects the star and shows its details. The selected star's action travels to the destination. Try changing one original entry's title, then use **New constellation** and see how the coordinates shift while the IDs and destinations persist.

## 6 · Reassemble the full V0.1 features

Save your practice files with new names first, then copy in the full template. The sources come from the original small project, so you can compare them with the code you wrote.

```bash
cp Preview.qml PreviewPractice.qml
cp kde/contents/ui/Rooms.js RoomsPractice.js
cp kde/contents/ui/Scene.qml ScenePractice.qml
cp "$blackbox_source/Preview.qml" .
cp "$blackbox_source/kde/contents/ui/"*.qml kde/contents/ui/
cp "$blackbox_source/kde/contents/ui/Rooms.js" kde/contents/ui/
cp "$blackbox_source/kde/contents/config/main.xml" kde/contents/config/
cp "$blackbox_source/kde/metadata.json" kde/
XDG_CONFIG_HOME="$blackbox_lab/settings" qml6 Preview.qml
```

The inline `XDG_CONFIG_HOME` assignment tells this launch to keep its settings in the practice folder. `Preview.qml` supplies a `Settings` object, reads its values into `Scene`, and writes them when the scene emits `settingsUpdated`. Repeat the same launch command after each edit.

| Learn this part | Find it in the source | Try it |
| --- | --- | --- |
| Room graph | `Rooms.js` · `rooms`, `order`, `routes` | Starting at the Shrine, press Right four times and Down four times. Find the destination of each move in the data. |
| Shared styling | `BlackboxButton.qml` · default padding, colours and focus border | Change one border colour. Find every button that inherited it. |
| Hooks and artwork | `Scene.qml` · `updateRoom()`, `FileDialog`, `artFor()` | Edit a name and choose an image. Close and relaunch. Move or delete only a spare copy of the image to see the sample fallback. |
| Constellations | `Scene.qml` · `starPoint()`, star buttons and actions | Try several selections and use **New constellation**. |
| Reduced motion | `Scene.qml` · `performance`, `ambient`, `ambientTimer.running` | Compare a normal transition with Performance and with the motion setting off. In the editor, simulate a covered wallpaper on Star Sky. |
| Demo controls | `Scene.qml` · `audioDemo`, sample CPU/GPU values, `clean` | Open the simulated status, toggle **Artwork only**, and return with Escape. |

Art replacements store the file reference. The shader file in the original `shaders/` directory is a separate Shadertoy-style experiment. Open the [implementation plan's shader lesson](IMPLEMENTATION-PLAN.md#try-the-existing-shader-wallpaper) when you're ready to try it.

## 7 · Give the same scene to KDE Plasma

The practice `kde/` folder now contains the package. Plasma reads `metadata.json` to discover it and runs `contents/ui/main.qml` as a `WallpaperItem`. That file creates the same `Scene.qml` you opened in a normal window. It reads and saves the settings through Plasma and uses the defaults in `contents/config/main.xml`. Neither launcher contains the room graph itself. [KDE WallpaperItem API](https://api.kde.org/qml-org-kde-plasma-plasmoid-wallpaperitem.html)

In your **practice copy** of `kde/metadata.json`, change the value of `"Id"` to `"local.starrain.blackboxlesson"` and `"Name"` to `"Blackbox V0.1 Lesson"`. Keep the quotes, commas and `"KPackageStructure": "Plasma/Wallpaper"`. Check package shape in a scratch package root first.

```bash
mkdir -p "$blackbox_lab/installed"
kpackagetool6 -t Plasma/Wallpaper -p "$blackbox_lab/installed" -i ./kde
kpackagetool6 -t Plasma/Wallpaper -p "$blackbox_lab/installed" -l
```

When you want to see it on the real desktop, record the current wallpaper, then install for your user.

```bash
kpackagetool6 -t Plasma/Wallpaper -i ./kde
```

From exposed desktop space, right-click and open **Configure Desktop and Wallpaper**. Select **Blackbox V0.1 Lesson** and apply. Try the buttons in open space, a right-click outside the controls, a cover and return, and Home. Observe which keys the actual desktop sends. To finish, apply your previous wallpaper through the chooser. Then remove the lesson package with `kpackagetool6 -t Plasma/Wallpaper -r local.starrain.blackboxlesson` if you want to uninstall it.

### Your V0.1 checkpoint

You can rebuild a room from its ID and image, describe how a click moves through the room graph, make a transition instant, and explain why the same scene can be hosted by both the preview and Plasma. The next exercise is the [real wallpaper input trial](BUILD-AND-LEARN.md#2--prove-the-real-plasma-input-path). Use the [game demo](../Demo/README.md) to see what that input needs to support.
