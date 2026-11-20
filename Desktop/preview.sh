#!/bin/sh
# Run from any directory. All mutable state stays in a new temporary profile.
set -eu
blackbox_source=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
case "${1:-}" in
    '') export BLACKBOX_PREVIEW_RENDER=3d ;;
    --software) export BLACKBOX_PREVIEW_RENDER=software ;;
    *) printf '%s\n' "Usage: $0 [--software]" >&2; exit 2 ;;
esac
blackbox_preview=$(mktemp -d /tmp/project-blackbox-preview.XXXXXX)
case ${WAYLAND_DISPLAY:-} in
    /*) blackbox_parent=$WAYLAND_DISPLAY ;;
    '') printf '%s\n' 'This preview needs a running Wayland desktop.' >&2; exit 1 ;;
    *) blackbox_parent=${XDG_RUNTIME_DIR:?}/$WAYLAND_DISPLAY ;;
esac
# Preserve the audio connection when the preview gets its own runtime directory.
if [ -z "${PULSE_SERVER:-}" ] && [ -S "${XDG_RUNTIME_DIR:?}/pulse/native" ]; then
    export PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native"
fi
if [ -z "${PIPEWIRE_RUNTIME_DIR:-}" ] && [ -S "${XDG_RUNTIME_DIR:?}/pipewire-0" ]; then
    export PIPEWIRE_RUNTIME_DIR="$XDG_RUNTIME_DIR"
fi
mkdir -p "$blackbox_preview/runtime" "$blackbox_preview/config" "$blackbox_preview/cache" "$blackbox_preview/state" "$blackbox_preview/desktop"
chmod 700 "$blackbox_preview/runtime"
printf 'XDG_DESKTOP_DIR="%s"\n' "$blackbox_preview/desktop" > "$blackbox_preview/config/user-dirs.dirs"
python "$blackbox_source/manage.py" stage --destination "$blackbox_preview/share"
blackbox_activity=$(cat /proc/sys/kernel/random/uuid)
printf '[activities]\n%s=Blackbox preview\n' "$blackbox_activity" > "$blackbox_preview/config/kactivitymanagerdrc"
cat > "$blackbox_preview/config/plasma-org.kde.plasma.desktop-appletsrc" <<CONFIG
[Containments][1]
activityId=$blackbox_activity
formfactor=0
lastScreen=0
location=0
plugin=org.kde.plasma.folder
wallpaperplugin=org.projectblackbox.wallpaper

[Containments][2]
activityId=
formfactor=2
lastScreen=0
location=4
plugin=org.kde.panel

[Containments][2][General]
AppletOrder=4;5;7;3;6

[Containments][2][Applets][3]
plugin=org.projectblackbox.controls

[Containments][2][Applets][4]
plugin=org.kde.plasma.kickoff

[Containments][2][Applets][5]
plugin=org.kde.plasma.icontasks

[Containments][2][Applets][6]
plugin=org.kde.plasma.digitalclock

[Containments][2][Applets][7]
plugin=org.kde.plasma.systemtray

[Containments][2][Applets][7][General]
shownItems=org.kde.plasma.bluetooth,org.kde.plasma.devicenotifier,org.kde.plasma.clipboard
CONFIG
printf '[General]\nmode=%s\naudioMaster=%s\n' "${BLACKBOX_PREVIEW_MODE:-idle}" "${BLACKBOX_PREVIEW_AUDIO:-1}" \
    > "$blackbox_preview/config/project-blackbox-desktop.ini"
cat > "$blackbox_preview/config/kwinrc" <<CONFIG
[Plugins]
org.projectblackbox.visibilityEnabled=true
org.projectblackbox.cubeEnabled=${BLACKBOX_PREVIEW_CUBE:-true}
CONFIG
cat > "$blackbox_preview/start.sh" <<'SESSION'
#!/bin/sh
printf '%s\n' "$DBUS_SESSION_BUS_ADDRESS" > "$XDG_RUNTIME_DIR/dbus-address"
# Prefer Quick3D even if the outer session uses Qt's 2D software scene graph.
# Apply the choice to the preview shell only so KWin can choose its compositor.
if [ "$BLACKBOX_PREVIEW_RENDER" = software ]; then
    export QT_QUICK_BACKEND=software
else
    export QT_QUICK_BACKEND=rhi
    export QSG_RHI_BACKEND="${BLACKBOX_PREVIEW_RHI:-opengl}"
fi
# Plasma creates the first activity after startup. Apply the wallpaper to
# its actual containment once it exists, inside this private session bus.
(
    for attempt in $(seq 1 80); do
        if qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript             'var ds=desktops(); for (var i=0;i<ds.length;i++) ds[i].wallpaperPlugin="org.projectblackbox.wallpaper"; var ps=panels(); for (var i=0;i<ps.length;i++) { ps[i].height=48; ps[i].floating=false; } print(ds.length);' 2>/dev/null | grep -Eq '[1-9]'; then
            break
        fi
        sleep .25
    done
) &
exec plasmashell --no-respawn
SESSION
chmod +x "$blackbox_preview/start.sh"
printf '%s\n' "Opening a Plasma desktop preview ($BLACKBOX_PREVIEW_RENDER). Close its window to end it." "Temporary settings and logs: $blackbox_preview"
export XDG_RUNTIME_DIR="$blackbox_preview/runtime"
export XDG_CONFIG_HOME="$blackbox_preview/config"
export XDG_CACHE_HOME="$blackbox_preview/cache"
export XDG_STATE_HOME="$blackbox_preview/state"
export XDG_DATA_HOME="$blackbox_preview/share"
export BLACKBOX_DESKTOP_DIR="$blackbox_preview/desktop"
export BLACKBOX_PREVIEW=1
# Native shortcut checks can opt in inside this private compositor.
set -- --no-global-shortcuts
if [ "${BLACKBOX_PREVIEW_SHORTCUTS:-0}" = 1 ]; then set --; fi
exec dbus-run-session -- kwin_wayland --wayland-display "$blackbox_parent" \
    --width 1400 --height 900 --socket blackbox-preview --no-lockscreen \
    "$@" --no-kactivities --exit-with-session "$blackbox_preview/start.sh" \
    > "$blackbox_preview/session.log" 2>&1
