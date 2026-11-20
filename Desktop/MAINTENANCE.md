# Keeping Blackbox maintainable

The chosen route is a small set of user-installed Plasma extensions, with the game kept separate. It offers a desktop wallpaper and panel experience without owning your entire desktop session.

| Approach | Benefit | Maintenance cost | Decision |
| --- | --- | --- | --- |
| Standalone Qt game only | Easiest to debug and run across desktops | No native panel/wallpaper integration | Retained as the reference and recovery route. |
| Wallpaper + widget + helper + optional style | Uses Plasma's existing extension boundaries; each piece can be removed independently | Test QML/scripting APIs after KDE updates; rebuild Qt bridge when needed | Implemented. |
| Optional declarative KWin effect | KWin owns the full-screen view and input, hot corners and shortcuts | Exercise the QML effect and input ownership after KWin updates | Used for Blackbox Cube. The standard KDE containment remains in place. |
| Fork or replace plasmashell/KWin | Complete control | Ongoing rebasing, distribution/security integration and upgrade conflicts | Unnecessary for this version. |

## One-install and one-plugin options

**One install with all features.** Put the wallpaper, BX widget, visibility script, optional cube effect, optional Plasma style and shared runtime in one Arch package or release archive. KDE still loads each piece through its own extension point. This keeps normal tray widgets, native linked desktops, and independent upgrades and rollback. The current `manage.py install` already installs all the pieces in one command for the current user. An Arch package can add Qt dependency tracking and the usual package-version upgrades.

**One wallpaper plugin.** Package the shared game, images and the best available local focus handling inside the wallpaper package. It could provide Play, scenery, Idle companions, the Grimoire and the wallpaper's context menu under one KDE installation. Native BX panel controls and guaranteed workspace or lock integration would require installing their individual Plasma and KWin extensions. Prototype this against the existing windowed and nested tests, run it without the native bridge, and verify focus and lock behavior before offering it as a lighter installation.

Use the current modular release for the full desktop experience. Keep the wallpaper-only profile as an optional experiment, with separate tests for Folder View, multiple screens, recovery and upgrades. Both profiles should load the same `PlayScene.qml`, balance data and model assets.

KDE's extension categories and packaging locations provide the basis for this separation. The widget declares the Plasma6 minimum API version, and the optional style follows KDE's style metadata format. [KDE extension overview](https://develop.kde.org/docs/plasma/), [Plasma6 widget setup](https://develop.kde.org/docs/plasma/widget/setup/), [style structure](https://develop.kde.org/docs/plasma/theme/theme-details/)

## Dependency boundaries

`Demo/game/Rules.js` is the simulation; it has no KDE imports. The wallpaper uses a host around `PlayScene.qml`. `Desktop/native/bridge.cpp` samples system counters, analyses optional speaker output and carries local state/commands. The KWin helper reports exposure and window geometry. The cube effect owns its rendering and input. It shares the room view with the wallpaper picker and uses asynchronous session-bus calls for scene data and room selection. The game suspends combat while the effect is open, and a short timeout releases that state if the effect unloads unexpectedly. The panel consumes snapshots at four updates per second rather than re-running the game. One shared backend serves separate QML-engine facades, avoiding duplicate sensor processes when Plasma uses multiple engines.

Enemy damage remains virtual game state. CPU and GPU bindings read counters. Music input captures an explicitly enabled output stream and keeps the samples in memory. Pet tasks use public Qt and KDE interfaces and the documented `wpctl` command. KWin supplies the last focused normal window’s ID. The bridge issues a short-lived close request for that exact ID after the user approves it.

## Update procedure

1. Export game progress. Keep the repository, the two Blackbox configuration files and your usual desktop configuration backup.
2. Perform a normal supported full Arch upgrade.
3. Open `Desktop/preview.sh`. Check wallpaper and panel loading, input, one wave, focus-loss pause, sound and Continue. Open the cube over windowed and fullscreen apps, use the assigned hot corner, close it with Escape, select a linked room, and disable the effect to exercise the wallpaper fallback. Open Pure Code in Folder View, enter a command, and drag a terminal divider. Check shell exit, copy/paste, recall, and the roaming pet on a real window.
4. If the native library needs rebuilding, run `python Desktop/manage.py install`. Log out/in to unload the old library.
5. If a new Plasma API breaks a component, use your ordinary wallpaper while fixing that package. The standalone game remains available.

Public APIs reduce coupling; they do not eliminate maintenance. The focus test already caught one incorrect signal assumption during development and led to a correction before release. Treat a successful build and a successful nested test as separate checks.

Use `python -m unittest discover -s Desktop/tests` to test recovery and package rollback against temporary installations and layouts. The live route uses Plasma’s scripting interface. The restart route targets Plasma Shell’s systemd user service and uses KDE’s settings writer only after the shell has stopped. Its unit tests replace the service commands with mocks. For a graphics regression, use Safe rendering or the standalone demo while testing the wallpaper in nested Plasma. [Recovery commands](README.md#recover-from-a-freeze)

## Install ownership and rollback

The installer owns the six paths listed in `manage.py`. Uninstall can also unwind the previous five-path manifest. It stores build metadata, installed-file hashes and prior Blackbox versions in its history. It never silently enables the helper, edits an existing panel, selects a theme or adds a login service. Removal preserves edited package contents and leaves save files intact.

Do not add automatic `pacman` hooks or edit files supplied by KDE to work around a plugin problem. A packaged Arch release could eventually let the package manager own system-wide Blackbox files. It should still preserve this separation and keep optional components optional.

## Future release checks

Test current Arch and at least one older supported Plasma/Qt combination. Include upgrade from the previous Blackbox save version, a missing native library, unavailable telemetry, PipeWire restart, desktop/folder input, multiple screens and lock/unlock. Keep a small benchmark scene for regular combat, hallucinations and Void incursions. Document measured frame times and renderer, not an unconditional performance promise.

## Pure Code terminal

The wallpaper hosts a lightweight Qt Quick terminal view. Each editable pane owns a Linux pseudo-terminal and launches the user’s shell. libvterm handles escape sequences. Read-only output panes share the selected shell’s terminal state. There is no browser or network service involved. The build prefers a system libvterm with a pinned, licensed source fallback. The nested preview uses a temporary shell home as well as a temporary Plasma profile. [libvterm upstream](https://www.leonerd.org.uk/code/libvterm/)

The pet console and `box pet` use `runtime/PetCatalog.js` for command names, argument help and operations. Pet admin means permission to use pet commands. Linux permissions still apply. Files and processes are accessed as the signed-in user. Shell drafts use bracketed paste into an available foreground shell and require the user to press Enter. A pet terminal opened on a scenic wallpaper retains its shells across room changes until its panel closes. Test Ctrl+P, a mode change, file approval, a draft in both kinds of terminal, a graceful window close, quiet and local song playback when changing the terminal or KWin bridge.
