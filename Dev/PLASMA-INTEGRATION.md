# Plasma integration

The plugin implementation now lives in [Desktop](../Desktop/README.md). Start with its visible nested preview; do not replace system KDE files to test the game.

The chosen design has a wallpaper, panel widget, visibility helper and optional Plasma Style, backed by a shared Qt bridge. It retains the standalone demo as the reference and recovery route. [Maintenance and alternatives](../Desktop/MAINTENANCE.md) compares this route with a custom containment and with replacing Plasma components, and explains upgrades and rollback.

## Code to follow

1. `Desktop/wallpaper/contents/ui/main.qml` is Plasma's `WallpaperItem`. It loads the shared `runtime/Host.qml` and retains a static fallback if the native bridge cannot load.
2. `Host.qml` embeds the same `Demo/game/PlayScene.qml` used by the demo. It passes custom backgrounds, graphics options and exposure state. Save/progress access is shared with the standalone Codex settings.
3. `Desktop/applet/contents/ui/main.qml` is a `PlasmoidItem`. It consumes snapshots and sends local commands rather than running another simulation.
4. `Desktop/visibility/contents/code/main.js` observes the public active-window/workspace signals. The Qt bridge also observes Show Desktop over D-Bus. Returning to Home leaves the game paused until Resume.
5. `Desktop/native/bridge.cpp` implements Qt-engine facades over one backend, read-only CPU/GPU samples, optional local speaker-output analysis, saved settings and the local command interface.
6. `Desktop/manage.py` builds and stages the runtime, records package ownership, installs user packages and preserves earlier versions for rollback.

This follows KDE's documented boundaries for wallpaper items, Plasma6 widgets and KWin scripts. [WallpaperItem](https://api.kde.org/qml-org-kde-plasma-plasmoid-wallpaperitem.html), [widget setup](https://develop.kde.org/docs/plasma/widget/setup/), [KWin API](https://develop.kde.org/docs/plasma/kwin/api/)

## Teaching exercise

Run the nested preview. Change one background through its file picker. Trace panel Q → `commandRequested` → `Rules.useAbility` → cooldown/visual event → panel snapshot. Then open another app inside that nested desktop and explain why gameplay pauses. Rebuild after changing a display label, and compare that with changing a rule in JavaScript.

Before daily use, complete the remaining physical setup checks: chosen screen, display scaling, file/folder input, lock/unlock, hotplug, sound device restart and a longer session. These are explicit compatibility checks, not reasons to fork KDE.
