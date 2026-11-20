# PROJECT BLACKBOX implementation plan

Target: Звезден Дъщ, Arch Linux, KDE Plasma on Wayland, Intel Core Ultra 7 270K Plus, Radeon RX 9070 XT and a 3840×2160 display at up to 144 Hz. The desktop renders ordinary windows in KDE. BLACKBOX provides scenery, navigation and controls. The shooter belongs to a later optional module after the desktop interaction and performance tests pass.

## Shader Wallpaper decision

**Use it for a short visual and performance trial. Keep BLACKBOX's controls and workspace mapping in the native project.** The likely match is y4my4my4m's Shader Wallpaper, package ID `online.knowmad.shaderwallpaper`. The installed version is unconfirmed. The development environment was Debian without Plasma or Star Rain's user files. Its source and documentation can be evaluated independently. Confirm the local match with `bash tools/inspect-kde.sh`.

| Requirement | Upstream Shader Wallpaper | BLACKBOX decision |
| --- | --- | --- |
| Star drift, caustics, fog, distortion | Designed for continuous fragment effects and supports multipass rendering | Good for visual experiments. Try one inexpensive pass before adding complexity. |
| Audio and authored images | PipeWire input, image inputs, configurable channel routing | Trial an audio channel only after an idle baseline. Keep the now-playing controls in the shared UI. |
| Performance and pause | Frame and resolution controls, pause policies and performance monitoring. Upstream describes a separate audio processing rate. | Measure both renderer and audio overhead. Test fullscreen, maximised windows, lock, resume and Show Desktop on the installed version. |
| Clickable constellations, room actions, editor | Mouse uniforms let shaders respond to exposed wallpaper input. Room focus, accessible buttons and application actions require interface code. | Keep these in the QML interface. |
| First-person navigation and KDE virtual desktops | The plugin renders a wallpaper in Plasma. It supplies no documented interface for the required room and KWin orchestration. | Implement navigation with KWin and keep a single authoritative room ID. |
| Packaging | Plasma wallpaper package plus a compiled C++/OpenGL engine | Evaluate the installed copy. Preserve the option of a light native ShaderEffect in BLACKBOX for a proven effect. |

Plasma selects a wallpaper provider for a desktop containment. The optional shader trial and the BLACKBOX wallpaper package are two selectable providers. For the finished experience, port a successful effect into BLACKBOX with Qt Quick's shader pipeline, or integrate a documented backend after proving runtime control and pause. Avoid basing room navigation on editing the third-party plugin's internal state.

Sources: [Shader Wallpaper upstream](https://github.com/y4my4my4m/kde-shader-wallpaper), [architecture](https://github.com/y4my4my4m/kde-shader-wallpaper/blob/master/docs/ARCHITECTURE.md), [shader development and imports](https://github.com/y4my4my4m/kde-shader-wallpaper/blob/master/docs/DEVELOPMENT.md).

## Environments and directional effects

The Shrine connects to the Droid Lab on the right, Media on the left, Star Sky above and the Abyss below. Reverse input returns to the Shrine. The Home shortcut works everywhere and tabs offer direct access.

| Room | Behaviour | Art and motion |
| --- | --- | --- |
| Home Shrine | Default home, shortcuts to daily work | Fixed forward view. Pitch up to Star Sky, yaw left to Media, yaw right to Droid Lab. |
| Star Sky | Clickable links to projects and research. Shuffle constellation layout while preserving labels and destinations. | Static stars in the plate plus a sparse moving layer. Pitch down to Shrine. |
| Abyss | Research, experiments, writing and unfinished work | Ruins and Trench samples. Add cave and drowned-city variants later. Shrine descent pushes through a hole. Rising returns to the surface. |
| Media | Watchlist, artwork and reference shelf | Wide scene plate or user image. Approach from the Shrine's left. |
| Droid Lab | Game library, Ace Druggie development, assets and builds | View to the right of the Shrine. Use restrained terminal and lighting effects. |

For the first production camera pass, create a continuous pano or compact 3D courtyard with four authored viewpoints. Give the forward and sky plates matching horizon, exposure and colour. Give left and right views consistent occlusion and foreground anchors. Start the downward move with a shared shot of the path and a foreground hole rim. Hand off at the dark crossing to a short descent shot, then reveal the current Abyss variant. The prototype uses rotation and translation of image layers, scale and fades to establish timing. A single perspective panorama or small 3D scene is required for a continuous camera rotation with correct perspective.

Wrap transitions use a star emitter or short authored clip. Keep stars as actual selectable QML items, positioned independently of the decorative texture. Use stable identifiers and optional seeded variation. Reserve the Media plate for personal images, including the Stone Ocean artwork once chosen in the editor.

## Modes and rendering policy

| Policy | Wallpaper | Performance |
| --- | --- | --- |
| Room switches | Short camera sequences. Default prototype 480 ms, editable. | Immediate switches. |
| Ambient layers | Only the active scene. Start at 24 fps for sparse motion. | Stop timer and unload moving effects. |
| Images | Native-size still images with a cap on decoded size. Effects may render at a lower resolution. | Static image and static controls. |
| Audio and data | Event-driven now playing. Audio sampling starts only when the effect is enabled. Sensors sampled slowly. | Keep playback controls. Stop spectrum processing and decorative polling. |
| Coverage | Suspend work when locked, covered, fullscreen or output inactive. Resume after a brief stable interval. | Remain static. |
| Workload rule | Fullscreen games and manually selected workload holds suppress decorations. | User can explicitly select this mode and keep it selected. |

The request named Performance and ended mid-sentence. Wallpaper is the working counterpart for this version. The preview's covered switch and demo audio/telemetry stand in for real inputs. Keep the display refresh rate independent from the wallpaper frame cap. At 4K, one 32-bit surface takes about 31.6 MiB before extra textures or compositor buffers, so keep one active base plus one temporary transition image. Start the shader test at 1080p equivalent since it shades one quarter of the pixels per pass compared with 4K.

In native integration, track pause reasons independently. Treat fullscreen, session lock, disabled motion and Performance as reasons to stop updating. Removing one reason only resumes when the others are clear. Scope window coverage to each output. Keep playing music, rendering a Blender job and compiling a project independent of which room is on screen. CPU and GPU sampling reads stats and leaves the machine's power and cooling configuration alone.

## Implementation order and checks

1. **Run the prototype.** Check the four camera directions, the Abyss fall, image replacement and static mode. This version has working editor controls, image selection, per-room art and names, a mock pulse and sample load controls. Transitional artwork is temporary.
2. **Test Plasma and plugin independently.** Identify the locally installed package and version. Test the bundled wallpaper package on one screen. Verify that covering the desktop preserves application input, right-click still exposes normal Plasma settings, colours work with the active Qt style, and settings survive logging out. Switch back to the previous wallpaper if the trial fails. Run the plugin test described below before deciding whether to bring a shader into BLACKBOX.
3. **Connect seven native virtual desktops.** Give each room a stable room ID mapped to a KDE desktop ID. Set up explicit Meta+arrow routes and a direct Home shortcut through a KWin script. Keep the scene and KWin in sync when using the pager, Overview, a keyboard shortcut or a star. Handle missing desktops with a clear fallback to the Shrine. Keep configuration in one room manifest. First prove this handoff without an effect.
4. **Add the KDE transitions.** Use KWin's effect API to own the fullscreen transition and restore input/focus. Prototype Shrine ↔ Sky with an open window. Fade out the source windows, move the viewpoint, switch the workspace at the handoff, then reveal the destination windows. Ensure an interrupted effect returns to the correct desktop and releases input immediately. Test directional and reduced-motion paths before adding the drop and wrap. Use QML first, then assess whether the camera needs a separately rendered sequence or custom effect backend.
5. **Connect signals and actions.** Subscribe to MPRIS for track title and playback, and add a separately toggled PipeWire spectrum. Use low-rate system and GPU readings for an unobtrusive load display. Connect window tabs to KDE task information. Define app and project actions as allowlisted app IDs or local paths. Send vault operations to their own applications and keep secrets outside BLACKBOX's settings.
6. **Finish art and package.** Replace sample plates incrementally. Keep scene layers and fallbacks in the project so changing a single artwork never disables navigation. Offer a global quick switch to Performance and preserve the ordinary Plasma desktop if an effect fails. Record the tested Plasma/KWin/Qt versions before calling the integration ready.

References: [KDE wallpaper components](https://api.kde.org/qml-org-kde-plasma-plasmoid-wallpaperitem.html), [KWin scripting API](https://develop.kde.org/docs/plasma/kwin/api/), [KWin QML effects](https://develop.kde.org/docs/plasma/kwineffect/), [Qt Quick 3D viewport](https://doc.qt.io/qt-6/qml-qtquick3d-view3d.html), [MPRIS](https://specifications.freedesktop.org/mpris/latest/).

## Star Rain benchmark

Use the same monitor settings, desktop apps and repeatable game benchmark or replay in each sample. Let the system settle for 30 seconds and sample the next 60 seconds. Repeat each condition three times in alternating order. Record the Plasma/KWin version, plugin version, shader, effect resolution, frame limit, game resolution, game cap and whether audio is active.

1. **Baseline:** ordinary KDE still wallpaper at idle and in the game.
2. **Plugin visible:** single-pass starfield at 20–24 fps, 1080p rendering or equivalent, audio off. Repeat with the intended effect and audio separately.
3. **Plugin covered:** repeat with fullscreen pause on. After closing the game, check that motion resumes. Test a maximised non-game window, session lock and Show Desktop separately.
4. **BLACKBOX visible:** compare static and Wallpaper on the same scene, then measure repeated Shrine ↔ Sky transitions.
5. **BLACKBOX Performance:** repeat the game benchmark and check that the mode stays active on room changes. Repeat with the renderer disabled completely if there is a measurable regression.

Record GPU busy, GPU power where reported, VRAM, plasmashell CPU usage and game frame times including the 99th percentile. Find the Radeon card by its PCI/device identity before reading AMDGPU sysfs files. Existing system monitoring tools can provide readings without changing fan controls. Compare idle fan behaviour with the existing setup and check frame times over multiple runs. Keep the shader if it visibly improves the scene and the covered and Performance profiles are close to the static baseline within normal run-to-run variation. Prefer 20–24 fps or a simpler effect if routine idle GPU power climbs. The preview's timer checks establish that its own animation work stops. Native GPU cost and third-party plugin pause behaviour require this hardware test.

References: [AMDGPU utilisation and power interfaces](https://docs.kernel.org/gpu/amdgpu/thermal.html), [AMDGPU memory reporting](https://docs.kernel.org/gpu/amdgpu/driver-misc.html).
