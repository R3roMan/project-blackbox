> Current implementation: a plugin bundle and visible nested preview now exist in [Desktop](../Desktop/README.md). Start with `./Desktop/preview.sh`. The input-probe sections below remain useful learning exercises and a checklist for additional hardware/display testing. The desktop architecture and upgrade path are in [Maintenance](../Desktop/MAINTENANCE.md).

# Build and learn Project Blackbox

Your first target is a working Play session on the Plasma desktop. The [playable demo](../Demo/README.md) gives you a reference for the controls, enemies, waves and rewards. The [V0.1 walkthrough](BUILD-V0.1.md) teaches you how the original wallpaper works by rebuilding it in a practice folder. The [implementation plan](IMPLEMENTATION-PLAN.md) has the detailed design, performance and Blender notes.

## Start here

1. Open **Konsole** from the Plasma launcher. Paste these two lines and press Enter.

   ```bash
   cd /home/blaxim/Projects/PROJECT-BLACKBOX
   qml6 Demo/Demo.qml
   ```

2. Open **Controls**, then choose **Play**, **Normal**, and one of the three companions. Clear wave one's Silophosus at the Shrine. Wave two starts automatically. Pick your first reward when you clear it. Turn right from the Shrine to Droid Lab, then left to return. Open the **Field codex** after exiting with **Esc**. Try the Shrine ↔ Droid Lab turn in **Idle** and **Performance** too.
3. Start the [V0.1 walkthrough](BUILD-V0.1.md). Write the small two-room version yourself. The checkpoint is one button and one keyboard shortcut moving between two real images.
4. Open the visible nested desktop and compare its input/focus behaviour with the standalone demo. Use the probe below to investigate any remaining differences.

For the native build, treat Home as one chosen KDE workspace on your main display. The Shrine is the entry point. Room tours and combat views happen inside that workspace. Start with that definition in the Plasma eligibility check, then verify it against your actual desktop setup.

## The build order

| Order | Work | Checkpoint you can see |
| --- | --- | --- |
| 1. Baseline | Run V0.1, work through the two-room exercise, learn to apply and restore a wallpaper package. | You can change a room label and explain when Qt updates it. |
| 2. Input and Home | Install an opt-in input probe as a per-user wallpaper and test on KDE Wayland. | Start takes local input. Arrows and clicks arrive. Escape exits. Focus loss, leaving Home and lock pause work. |
| 3. First native shot | Mount one demo 3D target in the eligible wallpaper. | One real shot hits the target on your 4K display and at a different scale. |
| 4. Play | Bring over the demo rules and UI. Tune the first two waves. | Start from the Shrine, fight in all directions, take a Droid Lab reward, restart on defeat and exit cleanly. |
| 5. Assets and performance | Export the first distinct enemies from Blender, tune the audio and benchmark the scene. | A family of readable enemies and a repeatable before/after result. |
| 6. Idle and Performance | Preserve room tools, add the first 3D transition and make the static path cheap. | The usual desktop is pleasant to use, and Performance behaves like a still wallpaper under load. |
| 7. XD and expansion | Develop the small 3D courtyard and assess cost. Add bosses, secrets and other desktop integrations in smaller trials. | One optional XD environment runs at an acceptable cost and unloads when you leave Home. |

### 1 · Learn the baseline

- Run `qml6 V0.1/Preview.qml` from the project folder. Right follows the horizontal loop. Down follows the vertical loop. Home returns to the Shrine.
- Edit a room title in the UI, use a trial image, and relaunch. Compare a normal turn with the immediate Performance switch. Try the simulated covered setting to see ambient motion stop.
- Work through the tutorial in a scratch directory. Make a backup or Git checkpoint before editing a trial package. Use `git status` to check whether your own copy is under Git. In a Git workspace, `git diff` shows exactly what changed.
- Write one sentence about each file in the path from a keypress to a new picture. That shows you can find the right file the next time a feature changes.

### 2 · Prove the real Plasma input path

Use a practice copy with the package name **Blackbox input trial** and a different ID, such as `local.starrain.blackboxtrial`. Start with a small QML panel inside the Shrine. Give it a Start button, a counter for left-clicks, the last key seen, an active indicator and an Exit button.

1. In the preview, click Start and call `forceActiveFocus()` on the probe's `FocusScope`. Add `Keys.onPressed` to update the label and handle Escape. Use a `MouseArea` for the target, enabled only while the probe is active. Route Escape and Exit through the same function.
2. Install the practice package from the project copy with `kpackagetool6 -t Plasma/Wallpaper -i ./kde`. Record your selected wallpaper before applying the trial. If the ID is already installed, use `-u ./kde`.
3. In **Configure Desktop and Wallpaper**, apply the trial on the chosen output. Start by checking that clicks, arrows, Home and Escape reach the probe in an exposed part of the desktop. Test **Show Desktop** and both **Desktop** and **Folder View** layouts if it helps diagnose event routing.
4. Check an app stealing focus, a maximised or fullscreen window, a virtual desktop switch, a lock and unlock, and another output. Exercise a press held through focus loss. The probe should clear its held input, stop updating and wait for another explicit Start or Resume. When exited, check that right-click opens Plasma's menu and that Konsole receives regular keys.
5. Use the narrowest host signals that pass. Start with active item/window focus. Add a filtered task model for app coverage and workspace state, and the Plasma lock signal where needed. Treat those as separate conditions. Wallpaper visibility by itself tells you whether the QML item is visible. [Qt keyboard focus](https://doc.qt.io/qt-6/qtquick-input-focus.html), [KWin workspace API](https://develop.kde.org/docs/plasma/kwin/api/)
6. If the real workspace keeps keys, check which component accepts the event and when the desktop surface gains focus. Try a desktop applet that explicitly hands off to the wallpaper scene if the direct opt-in path fails. Continue practising the combat scene in the demo while you investigate. The check for the native release is gameplay and exit on the actual wallpaper.

Keep a table of **case**, **expected**, **actual**, and **next check**. Change one thing at a time. Return to your previous wallpaper in the chooser when you finish testing.

### 3 · Make one native 3D hit

- Open [World3D.qml](../Demo/game/World3D.qml) and find `View3D`, the camera and `pickTarget()`. In a practice copy, start with a `#Cube`, one camera and one light. Give the cube a target ID.
- Request input through the probe that passed Stage 2. Show the ID returned by a centre click. Add one side view and move the target farther back to see the perspective change.
- Keep the input cursor in viewport-local units. If the stage fills the same parent as the pointer area, their coordinates line up. If you add a margin or a panel, map the point into the actual viewport with `mapFromItem`. Test centre, edges and fractional scaling. [Qt View3D picking](https://doc.qt.io/qt-6/qml-qtquick3d-view3d.html)
- Unload the viewport outside Play and repeat Escape during a turn. Restore the former passive mode and ordinary desktop input every time.

### 4 · Move the full Play loop into the wallpaper

1. Use the demo to set the target experience. Bring the rules, 3D world and HUD into the package once one hit works. Give the run one owner and make the Plasma wrapper supply permission to play or resume. Keep comparisons, damage and rewards in JavaScript. Keep views, input and display in QML.
2. Test one ground demon, one Star Sky attacker and one Void seal before packaging the full wave. Use the directions to check attacks while the threat is offscreen. Keep the active camera fixed between turn commands.
3. Bring up the complete cycle. Start a wave, clear all enemies and outstanding attacks, choose one random reward in Droid Lab, start the next wave. Aim for two clean waves before tuning endless difficulty. Try getting defeated on purpose and restarting.
4. Keep the demo bindings for the initial tests. Use WASD, arrow keys or the mouse edge to turn. Use 1 and 2 to switch guns, R to reload, Q and E for the independent active slots, Space for the field shield, and hold F to seal the Void. Check that Left from Droid Lab returns to the Shrine and that holding fire follows each weapon's cycle. Hold Shift and aim near the edge to test the scope and turn lockout.
5. Test deactivation during a shot, a held seal, reload, reward selection and defeat. The active session pauses and drops input on coverage or focus loss. Use a fresh click to resume. Keep ordinary wallpaper settings separate from an in-progress run.

### 5 · Learn Blender while replacing one object at a time

- **First object.** Make a lantern from cubes. Learn orbit, pan, zoom, object versus edit mode, move, scale and rotate, materials, and where to place an origin. Save your `.blend` source.
- **First export.** Export the selected object as uncompressed GLB. Import it into a small Qt Quick window and verify scale, front, and ground contact. Your Arch build's Qt asset importer needs `assimp` for this lesson. Follow the [tested import diagnosis](IMPLEMENTATION-PLAN.md#fix-the-qt-import-lesson-on-arch) when you reach it. [Arch Qt Quick 3D package](https://archlinux.org/packages/extra/x86_64/qt6-quick3d/)
- **First monster.** Build a bulky body, wings, one eye and a mouth for Silophosus. Replace its primitive model while keeping the same gameplay target ID. Check its outline against actual game backgrounds.
- **First motion.** Add a simple armature, weight the wings, and export one wingbeat cycle. Let game code move the creature forward. Add a wind-up and a reaction after one imported clip plays. Repeat for a ranged silhouette and the Void creature.
- **First polish pass.** Add a readable attack sound, hit effect and stronger combat music. Measure the scene with the final amount of moving geometry before adding heavier shadows, gore or post-processing.

### 6 · Finish everyday wallpaper and test cost

- Keep the room graph, editor and constellation actions from V0.1. Replace one transition first, starting with Shrine ↔ Star Sky. Match the horizon and perspective, run the 3D sequence during the move, then settle to the chosen room artwork. Add left, right, the Abyss drop and the vault afterward.
- Keep Performance's image, links and controls. Stop effect timers, audio and 3D loaders. Check that state by watching counters after switching out of Play and while a game covers the desktop.
- Record a still wallpaper sample on Star Rain. Compare Performance, visible Idle, covered Idle and the same Play encounter at the same resolution and refresh. Log GPU busy and power where available, memory, CPU and slow frame times. Change 3D resolution before replacing finished art.
- Try the bundled star drift in Shader Wallpaper 4.2.4 as a separate wallpaper setting. Measure it at a modest frame rate, with audio disabled and with cover pause enabled. If you want it in Blackbox, port the GLSL pass to Qt's `ShaderEffect` and learn to bake a `.qsb` with `qsb`. [Shader Wallpaper development notes](https://github.com/y4my4my4m/kde-shader-wallpaper/blob/master/docs/DEVELOPMENT.md), [Qt ShaderEffect](https://doc.qt.io/qt-6/qml-qtquick-shadereffect.html)

### 7 · Turn the bonus ideas into small experiments

- Start XD with the demo courtyard and replace one group of primitives with your own Blender assets. Try baked lighting and a small live light. Add costly effects one at a time and measure open, covered and closed behaviour.
- Play wave three to see Fhantamegus change fronts and wave five to try Hosphoragus's stun. Turn on **Debug** at run setup to replay wave ten or twenty while tuning a boss. Then try wave fifty to see how the same hit-detection code separates a ship's guns from its projectiles. Tune a weapon, complete a kit, and compare the time it takes to clear a wave. [Demo progression and equipment](../Demo/README.md)
- Try real KDE workspace mapping and app shortcuts after Play works inside Home. Add now-playing metadata, window integration and telemetry when you have a reason to use them. Reuse the same Home gate when enabling optional work.

## Teaching plan

Treat each row as a short workshop. Start by reproducing the example, make one change, and explain what you saw. Ask for help with the first broken step and include the exact terminal message.

| Workshop | Learn and practise | Demonstrate it back |
| --- | --- | --- |
| 1. Arch and files | Konsole, folders, absolute and relative paths, `pacman -Q`, Kate, launching and closing a Qt window. | Launch both previews from the project root and point to the file each command opens. |
| 2. QML basics | `import`, objects, `id`, anchors, properties, bindings and signal handlers. Build the first button in the V0.1 tutorial. | Change what the button says and have one click update a bound label. |
| 3. JavaScript and state | Objects, arrays, functions, an `if` guard, reading a room route and calculating ammunition. | Add one room route and predict a shot's effect at zero ammo and at full ammo. |
| 4. Shell, packages and focus | Plasma, KWin, Wayland, package IDs, local versus user settings, keyboard focus and event delivery. | Install and roll back the practice wallpaper, then show your input probe log. |
| 5. Cameras and aim | X/Y/Z, positive Y, depth, one eye, field of view, and clicking into a 3D viewport. | Turn a camera with an arrow and make a 3D target get smaller with distance. |
| 6. Game loops | Fixed time steps, enemy states, telegraphs, simulation versus drawing, seeded random choices. | Make a chosen enemy slower and replay wave one. Add a reward in the sandbox and observe the result in wave two. |
| 7. Blender | Viewport controls, mesh editing, materials, a clean export, armatures and keyframes. | Import a lantern, then swap a primitive for one animated enemy. |
| 8. Finishing | Sound levels, visual readability, profiling a frame, testing on Wayland, recording results and packaging a release. | Produce an open/covered/Performance comparison and execute the release checklist below. |

### Commands to keep handy

| Command | Use |
| --- | --- |
| `pwd`, `ls`, `cd path` | See where you are, list files, enter a different folder. |
| `qml6 V0.1/Preview.qml` | Run the original template from the project root. |
| `qml6 Demo/Demo.qml` | Run the new game demo from the project root. |
| `bash V0.1/tools/inspect-kde.sh` | Read the session type, Plasma versions and wallpaper package IDs. |
| `pacman -Q qt6-declarative qt6-quick3d qt6-multimedia` | Check your installed Qt packages. Arch's `pacman` calls the list of installed packages a query. |
| `kpackagetool6 -t Plasma/Wallpaper -l` | Check which wallpaper packages are installed. |
| `journalctl --user -b -u plasma-plasmashell.service -n 80 --no-pager` | Read recent shell messages from this boot if the Plasma user service is present. |

If a command fails, copy its exact output before changing anything. Use a QML error's file and line number first. For a module import error, check the relevant package and the spelling of the QML import. For a blank scene with no import errors, check the image or model path, whether the component is visible, and whether it is loaded. If a panel works in the preview but keys are missing on the wallpaper, return to Stage 2's focus probe.

## Ship checklist

- [ ] The package upgrades from the original Blackbox package, and old room edits and Performance settings load.
- [ ] Play starts from Home on Star Rain and receives aim, turns, seal, reload and both ability inputs.
- [ ] A player can clear two waves using the actual wallpaper, take a reward, lose and restart.
- [ ] Escape and the visible Exit work during every phase. Cover, lock, workspace changes and a second screen pass the input and pause tests.
- [ ] Idle room navigation and editing still work. Performance drops animated work, confirmed by measurements with the same comparison setup.
- [ ] Sound and art have credits where needed. Pause, exit and mute stop game audio.
- [ ] The trial works on your usual display scaling. Write down your Plasma, Qt, display and graphics versions and how to go back to the previous wallpaper.

**Next learning exercise after the tutorial:** run the nested desktop, trace a panel Q command into the game, and change one background using its file picker. Then complete the lock/multi-screen checks on your hardware.
