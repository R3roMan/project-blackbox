#!/usr/bin/env bash
set -u
printf 'Desktop: %s\nSession: %s\n' "${XDG_CURRENT_DESKTOP:-unknown}" "${XDG_SESSION_TYPE:-unknown}"
for binary in plasmashell kwin_wayland; do
    if command -v "$binary" >/dev/null; then
        "$binary" --version 2>/dev/null | head -n 1
    fi
done

printf '\nWallpaper packages\n'
local_data=${XDG_DATA_HOME:-"$HOME/.local/share"}
IFS=: read -r -a system_data <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for folder in "$local_data" "${system_data[@]}"; do
    for metadata in "$folder"/plasma/wallpapers/*/metadata.json; do
        if [[ -f "$metadata" ]]; then
            python3 -c 'import json, sys
from pathlib import Path
path = Path(sys.argv[1])
try:
    item = json.loads(path.read_text()).get("KPlugin", {})
    print("{} | {} | {}".format(item.get("Id", path.parent.name), item.get("Version", "version unspecified"), item.get("Name", "name unspecified")))
except (OSError, ValueError):
    print(path.parent.name, "| unreadable metadata")' "$metadata"
        fi
    done
done

printf '\nWallpaper types currently referenced by Plasma\n'
config=${XDG_CONFIG_HOME:-"$HOME/.config"}/plasma-org.kde.plasma.desktop-appletsrc
if [[ -r "$config" ]]; then
    sed -n 's/^wallpaperplugin=//p' "$config" | sort -u
fi
