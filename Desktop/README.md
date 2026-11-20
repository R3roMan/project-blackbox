# Blackbox on KDE Plasma

Blackbox extends Plasma through removable packages. Its game and art are shared by the wallpaper and panel. Your existing Plasma shell, window manager, launcher, task manager and network services remain ordinary KDE components.

## First: try it in a window

From the project folder:

```sh
./Desktop/preview.sh
```

This builds the small Qt bridge and opens **nested KWin**, an entire temporary Plasma desktop inside a window. It uses its own session bus, runtime directory, settings and data under `/tmp/project-blackbox-preview.*`. Close that window to end it. The preview's game saves are temporary too. Its log is `session.log` inside that directory.

The preview opens in Idle. Reveal the controls with **Ctrl**, then use **Back to Play** to choose your starting weapon and companion manually. Use **Debug** for boss practice. The preview has a standard KDE panel and uses **Folder View** with its own temporary desktop folder. Drag across blank desktop space to select files with KDE’s blue selection rectangle. During Play the wallpaper receives input over the work area and the panel keeps its usual space. Opening a regular app or entering Plasma edit mode suspends gameplay by default.

The preview requests Qt Quick 3D through OpenGL by default. The panel's Blackbox Controls reports which renderer is live. If the nested desktop cannot initialise the 3D field, the game can fall back to projected sprites. To open that lighter renderer directly, run `./Desktop/preview.sh --software`.

Blackbox opens in Idle with its wallpaper controls hidden. Tap **Ctrl** on the Blackbox desktop to fade those controls in or out. **Ctrl+left click** the wallpaper, hold **Ctrl+Space**, or right-click and choose **Play** to start a Normal Wave 1 with a random weapon and pet after a red three-second countdown. All three work with the controls hidden. Press **Esc** to cancel. Paid next-run items and tarot omens stay available for a regular New Game. Quick-start shortcuts operate when Blackbox has focus.

Right-click the wallpaper and choose **Idle settings** to change either quick-start shortcut under **Controls**. Idle settings temporarily hides the toolbar. With mouse turns enabled, hold Ctrl and move to the edge just above the panel on the Shrine wallpaper to descend into the Abyss. Open **Scene editor** from the revealed controls to find **Builds**.

The demo and desktop share the same combat and idle scenery. Use **Desktop → Keep Idle running behind other apps** for Idle and **Gameplay → Keep battles running behind other apps** for combat. Auto uses the speed you selected and stops at your best cleared wave, with Wave 90 as the ceiling. Open the cube with **Ctrl+Alt+M** or **Room overview** in the private preview. Use `BLACKBOX_PREVIEW_AUDIO=0 ./Desktop/preview.sh` for a silent preview.

**Back to Play** appears in Idle and in Blackbox Controls. **Return to KDE desktop** in Desktop settings saves the run, restores your previous wallpaper plug-in, and leaves a Project Blackbox shortcut with a demon icon. If Blackbox was selected directly in Plasma before the launcher had a chance to snapshot the wallpaper, Return uses KDE’s standard image wallpaper. The shortcut activates Blackbox again.

Enable **Link each wallpaper to a KDE virtual desktop** to link the five game views and Pure Code to six named KWin virtual desktops. Turning in the game switches the active KWin desktop, and switching between those desktops also moves the game’s view. **Use only the Blackbox turn animation while linked** temporarily unloads KDE’s Slide effect for the linked session and restores it when you unlink or leave the wallpaper. Disabling the link returns to the previous desktop. The named desktops can be removed in KDE’s Virtual Desktops settings. Background play pauses on the screen lock. The app with focus keeps its input while the wave runs. Click the exposed game desktop to resume manual aim, or use Auto while working in another app.

CPU heat, virtual GPU pressure, and optional speaker reactivity are exposed in Desktop settings. GPU pressure changes the game’s rendering detail, and the corresponding rings show what the game is responding to. Speaker reactivity influences the composition of a freshly planned wave.

## Install and activate

Build dependencies on Arch are `cmake`, a C++ compiler, `qt6-base`, `qt6-declarative`, `qt6-quick3d`, `qt6-multimedia`, and `qt6-shadertools`. Plasma and KWin are already needed for the desktop. PipeWire output analysis additionally uses `pw-record` from `pipewire-audio`. Spoken pet dialogue uses `qt6-speech` and an installed speech backend. Query installed versions before adding packages.

```sh
python Desktop/manage.py install
```

The installer copies Blackbox’s user packages and shared runtime. It records their hashes and backs up earlier versions. Enable the components you want in KDE System Settings after installing.

1. Right-click the desktop → **Desktop and Wallpaper**. Choose the **Project Blackbox** wallpaper and apply it to your chosen game screen. Keep your current layout. The icon-free **Desktop** layout gives the game a clear play area if you prefer it.
2. In System Settings → Window Management → KWin Scripts, enable **Blackbox desktop visibility**. This is required for automatic Home-only activity. Show Desktop once if the startup status still asks for the helper.
3. To use the compositor overview, enable **Blackbox Cube** in **Desktop Effects**. Assign a hot corner in **Screen Edges** or change its shortcut under **Shortcuts**.
4. Add the **Blackbox Controls** widget to your existing panel. Select Play in it, or in the wallpaper's Desktop settings.
5. Pick your starting offers and begin the wave. Esc pauses. The panel exposes abilities, save/continue, mode selection and loadout/settings access.
6. Blackbox applies its dark Plasma style and Breeze Dark app colours on first activation by default. Open **BX → Appearance** to restore the previous choices individually. Custom choices are available under **Plasma Style** and **Colors** in KDE System Settings. The preview puts BX next to the clock. On an existing panel, use Plasma **Edit Mode** to drag the widget next to your clock.

If the packages do not appear immediately, log out and back in. Reopening the standalone demo loads corrected QML after source changes.

## What the pieces do

| Piece | Standard location under `~/.local/share` | Responsibility |
| --- | --- | --- |
| Wallpaper `org.projectblackbox.wallpaper` | `plasma/wallpapers/` | Hosts the game or animated room scene. |
| Widget `org.projectblackbox.controls` | `plasma/plasmoids/` | Panel controls and live cooldown/state readouts. |
| Visibility helper `org.projectblackbox.visibility` | `kwin/scripts/` | Reports desktop exposure and active-window geometry. Registers remappable background Idle shortcuts. |
| Optional cube `org.projectblackbox.cube` | `kwin/effects/` | KWin owns the fullscreen overview and its input. |
| Optional style `org.projectblackbox.blood` | `plasma/desktoptheme/` | Blood/brass panel styling with standard theme fallbacks. |
| Shared runtime and Qt bridge | `project-blackbox/` | One copy of the game, art and audio; read-only sensors and local communication. |

Plasma documents wallpapers, widgets, KWin scripts, effects and styles as separate extension types. The wallpaper uses `WallpaperItem`, the panel uses `PlasmoidItem`, and the helper uses the public KWin scripting signals. The optional compositor overview uses KWin’s declarative `SceneEffect`. Show Desktop is observed through KWin's public D-Bus signal. No private KDE C++ libraries are linked. [KDE extension types](https://develop.kde.org/docs/plasma/), [widget setup](https://develop.kde.org/docs/plasma/widget/setup/), [KWin scripting API](https://develop.kde.org/docs/plasma/kwin/api/), [KWin effects](https://develop.kde.org/docs/plasma/kwineffect/)

## Modes and customisation

- **Play** uses the full game. Tap **Ctrl** to fade the battle HUD out or bring it back. Pause and combat still work with the HUD hidden. Opening another application pauses by default. Return to the desktop and Resume.
- **Idle** combines the original animated rooms and the lighter wallpaper mode. Switch animation off or choose a lower detail level to reduce rendering work.

In **Desktop settings → Desktop**, adjust the Idle phase duration from 1 to 120 minutes. The default is 10 minutes each for Day, Sunset, Night and Sunrise. Every change of phase has about a 70% chance of a weather effect and 30% chance of clear skies. The forecast is shared across the five scenic rooms. Pure Code has its own static artwork.

Idle updates effects 12 times per second by default. Change that under **Idle effects updates per second**. Camera turns use a separate smooth animation. **Safe rendering** switches combat to the 2D renderer and disables continuous Idle effects. Auto in Debug can continue past Wave 90 and stops if the run loses or you turn Auto off. Regular Auto still uses your highest cleared wave, capped at Wave 90.

Hold Ctrl and move to an edge or press an arrow key to turn in Idle and Performance. Reaching for the Plasma panel leaves the wallpaper in place. Drag selection stays active when the pointer reaches an edge. **Roaming Idle pet** adds an optional companion. It scales with the desktop work area. Click it for hearts, drag it to move it, and click any splashes to clean them. Companion glow, HUD and aim colours are shared with the standalone game under **Controls**. The panel uses KDE's standard System Tray and clipboard. **Night Light** and **Displays and HDR** open KDE’s native settings. HDR availability depends on the display and driver.

### The cube and Pure Code

- With **Blackbox Cube** enabled in KDE’s **Desktop Effects**, press **Meta+Alt+C** to open it above your apps. Assign a screen corner in **Screen Edges** or change **Toggle Blackbox Cube** in **Shortcuts**. **Esc** returns to your app. Drag, scroll, or use the arrow keys to choose a face, then press **Enter**. **Room overview** in BX or the wallpaper menu also opens the effect. With the effect disabled, those controls open the wallpaper picker when you’re on the desktop. KDE’s **Peek at Desktop** remains available and can show the wallpaper picker if enabled in Blackbox Desktop settings.
- Use **Desktop settings → Images → Blackbox cube backdrop** to change the image behind the cube, and **Display → Wallpaper framing → 16:9 composition** to centre a 16:9 composition. At 16:9 screen proportions it fills the screen. On other shapes it leaves margins.
- In Idle and Performance, go outward from the West Approach, Droid Lab, Star Sky or Abyss to reach **Pure Code**. With **Link each wallpaper to a KDE virtual desktop**, Pure Code has its own workspace. The wallpaper opens an embedded terminal running your normal shell. Right-click to open another shell or split off a linked output view horizontally or vertically. Drag the dividers to resize. **Ctrl+F** searches, **Ctrl+Shift+C / Ctrl+Shift+V** use the desktop clipboard, and **Alt+Left** leaves Pure Code while keeping its shell sessions alive. Type `box help` for the command tree and `box me` for the ASCII animation. [Pure Code command reference](runtime/terminal/COMMANDS.md)
- To keep Idle running with an app focused, enable **Desktop → Keep Idle running behind other apps**. **Meta+Ctrl+arrow** turns the wallpaper through KDE’s remappable global shortcuts. Mouse turns still use the desktop surface. On Wayland the roaming Idle pet can fly over windowed apps and use the upper edges of open windows on this workspace as perches. Its overlay lets clicks reach the app. Return to the wallpaper to drag the pet or clean up splashes.

During the quick-start countdown, press **Esc** or right-click the wallpaper to cancel. In battle, **Esc** pauses in the current room. **Retire** on the pause screen ends the current run and opens its expedition report after confirmation.

Open **BX → Appearance** to choose Blood Shrine, Armory Grid, Field Terminal, Black Dossier, Lockdown or Dark. Desktop settings also expose the same picker under **Display**. Blackbox defaults to its dark Plasma style and Breeze Dark app colours on first activation. Each KDE appearance setting has a separate **Restore** control that brings back the previous choice. Under **Desktop settings → Display**, you can also disable the first-activation default before using it on another profile.

### Pet terminal

Turn on **Pet admin** in BX or **Desktop settings → Desktop**. On the wallpaper, press **Ctrl+P** or choose **Pet terminal** in the right-click menu. The same commands run through `pet` or `box pet` in a shell inside Blackbox. `pet help tasks` shows everyday jobs, `pet folder` shows the configured quick-access folder, and `pet transform Wendy` switches to Wendy. BX and Desktop settings both show the mood meter and audio controls. Disable and re-enable Pet admin to reset mood.

File edits and copies, application closes, speaker-volume changes, shell drafts and battle starts ask for approval. A shell draft is inserted into a Blackbox terminal. Press **Enter** after reviewing it. Use `pet terminal left` to open a terminal on the West Approach, or `pet code COMMAND` to draft on your current wallpaper. Under **Images**, use **Pure Code** and **Dark terminal opacity** to set an independent terminal image and translucency. [Pet command reference](runtime/terminal/PET.md)

Use **Gameplay → Show enemy lineup before waves** to toggle forecast models. Regular runs keep the equipment and reward screens. Use **Controls** to rebind keyboard actions, mouse buttons, Idle shortcuts and the quick-start chord. The editor flags conflicts within Blackbox. Quick start requires a modifier, and the keyboard shortcut must be held. Old unmodified quick-start bindings fall back to the defaults. Scroll-wheel weapon switching is optional. The standalone demo exposes gameplay bindings in its own settings.

Plasma Activities own separate desktop wallpaper plug-ins and widget layouts. Create or switch Activities using **Show Activity Manager**, then use **Desktop and Wallpaper** and **Add Widgets** within the Activity you want to customize. A KWin virtual desktop changes the window workspace. Virtual desktops in the same Activity share its wallpaper and widgets. Blackbox’s workspace option maps the five game views and the Idle-only Pure Code room to six KWin desktops. The Blackbox launcher changes one screen in the current Activity and remembers that wallpaper for **Return to KDE desktop**. [KDE Activities](https://userbase.kde.org/Plasma/Activities)

The regular installation uses your existing Plasma desktop and panel. To activate the wallpaper from that panel, open **Blackbox Controls → Use my KDE layout**. Your pinned apps, tray and widgets carry over automatically. Use Plasma’s **Edit Mode → Add Widgets** and the **System Tray** configuration to manage notifications, brightness, volume, Wi-Fi, KDE Connect, the clock and system monitors. Which controls appear depends on the KDE components installed and the hardware available.


Desktop settings offers a file picker for each game background, Pure Code and the cube backdrop. **Restore all default images** clears those overrides. **Restore desktop settings** resets Blackbox preferences and keeps your artwork and run history. In desktop play, use the arrow keys or turn at the mouse edges. Escape opens Pause on any wallpaper. The files stay where you choose them; replacing artwork does not require editing game code. The desktop and standalone game use the same main save/progress file, `~/.config/project-blackbox-demo.ini`. Desktop-specific settings live in `~/.config/project-blackbox-desktop.ini`. Use the standalone main-menu Export/Import for game-data backups; include both settings files in your normal desktop backups. The Witch’s Vault and expedition records share the same game profile. In desktop Idle mode, use **Witch’s Vault** beside the Grimoire. The windowed game also opens it from Home.

Optional bindings are off initially:

- **CPU ammunition:** real CPU utilisation sets a heat floor, firing adds virtual heat, and 100% requires cooling. Disable it for ordinary magazines. It does not create CPU work to simulate ammunition.
- **GPU response:** reads AMD's busy-percent file or queries `nvidia-smi` asynchronously when available. Rendering detail drops under high GPU load. Demon hits also raise a separate *virtual* pressure meter; they do not change hardware clocks or intentionally overload the GPU. Unsupported GPU telemetry is shown as unavailable.
- **Music response:** monitors the selected speaker output locally through PipeWire, with no recording saved. Eight bands drive visible bars. Bass/treble/pulse emphasis biases eligible enemy selection when the next roster is first prepared, within the existing difficulty budget. A displayed roster stays fixed. This is output analysis, not microphone input.

The native bridge exposes local `org.projectblackbox.Desktop` D-Bus commands and JSON status. The pet opens local files using KDE associations and requests normal window closure through KWin after approval. Terminal-only encounters, AI application control and Wi-Fi-disabling attacks remain future experiments.

## Upgrades and maintenance

The implementation choices are compared in [Maintenance](MAINTENANCE.md). Continue normal full Arch upgrades. There are no patched system packages, custom Plasma forks, package holds, mandatory global themes or automatic upgrade hooks.

Both Play hosts use the same combat, balance, asset and HUD code. The demo draws inside its window, and the wallpaper reserves space for the Plasma panel. Options such as GPU pressure, CPU ammo, linked desktops and speaker reactivity are desktop extensions. For a side-by-side comparison, choose the same renderer, resolution cap, graphics preset, frame limit, difficulty and stage and turn off those desktop extensions.

The game is QML and JavaScript. Only the small sensor/communication bridge is compiled C++, using public Qt APIs. A normal Plasma update should chiefly require checking the wallpaper/widget/helper APIs. After a Qt major upgrade, or if Qt rejects the native plugin, rebuild and reinstall with the same command above. Build information records the Qt version. Log out/in after replacing a library already loaded by Plasma. Keep this repository so rebuilding is straightforward.

The installer leaves a manifest under `~/.local/share/project-blackbox-installations/`. It can restore an earlier Blackbox installation. Future release work should add automated Plasma/Qt-version matrix testing and an Arch package; that packaging is not yet a maintained distribution channel.

## Revert

Select your previous wallpaper and Plasma Style, remove the Blackbox panel widget, and disable Blackbox Cube and the visibility script in KDE System Settings. Then run:

```sh
python Desktop/manage.py remove
```

One call reverses the latest installation. If earlier Blackbox installations were restored, repeat to unwind those as well. Only the Blackbox package and runtime paths are removed or restored. Modified installed files are preserved in the installation history. Saves, progress and settings are kept. The installer has not written to `/usr`, replaced KDE binaries or edited your existing desktop layout.

## Recover from a freeze

**Return to KDE desktop** saves an eligible run and restores your previous wallpaper while Plasma responds. If Blackbox is unresponsive, the installed recovery command can be run from an existing terminal or from KRunner.

```sh
python "${XDG_DATA_HOME:-$HOME/.local/share}/project-blackbox/runtime/desktop-session.py" recover
```

If Plasma Shell itself is stuck, add `--restart-shell`. On Arch's systemd-managed Plasma session this stops only `plasma-plasmashell.service`, backs up the desktop layout, restores the Blackbox wallpaper entries and starts Plasma Shell again. It uses the previous wallpaper recorded for each desktop and KDE’s image wallpaper as a fallback. KWin and application processes are separate from Plasma Shell. Any Blackbox progress since its last checkpoint may be lost. Close the preview window to recover a nested session.

Blackbox’s wallpaper runs inside Plasma Shell, so a fault there can take the panel or desktop with it. Use `qml6 Demo/Demo.qml` for a game process that is independent of Plasma Shell. Graphics driver or compositor failures can still affect the desktop session.

## Verification and limits

The 0.4.12 packages loaded in visible nested Plasma 6.8.3 / KWin 6.8.3 with Qt 6.12.0. Checks covered countdown cancellation, Esc outside the Shrine, native drag selection, the clipboard, the same Ultra Wave 20 checkpoint in both Play hosts, and the live recovery route. The offline recovery tests used a temporary KDE configuration. See the issue ledger for remaining checks. [Issue ledger](../Dev/ISSUES.md)

Multi-monitor hotplug, lock/unlock, other Qt/Plasma versions, physical controllers and long sessions on your actual graphics driver still need day-to-day verification. Auto quality uses up to 2160p in Ultra and lowers the render size when sustained frame rate drops. A short isolated Wave 1 run rendered a 3840 × 2160 field and reported a median of 58 FPS after initial loading. A short 21-enemy Abyssal Takeover test with Auto resolution reported a 42 FPS median at 1440p internal rendering in the same output window. Longer runs and other graphics drivers still need measurement.

### 0.4.13 verification

The private Plasma preview confirmed the 3D cube, KDE Peek and return, background turns via the registered KWin action with Konsole still focused, the visible pet overlay, Konsole launch, and the sixth linked desktop. The standalone demo launched successfully, and 191 Qt checks and three recovery tests passed. The Qt suite covers the Idle-only rear routes, pet motion and 16:9 composition. KDE settings, installed packages and user files on the primary desktop were left in place.
