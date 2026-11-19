#!/usr/bin/env python3
"""Switch only Blackbox's Plasma wallpaper and provide a reversible desktop launcher."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
STATE = CONFIG / "project-blackbox-wallpapers.json"
ID = "org.projectblackbox.wallpaper"
DEFAULT = "org.kde.image"
PLASMA = ["qdbus6", "org.kde.plasmashell", "/PlasmaShell", "org.kde.PlasmaShell.evaluateScript"]
BRIDGE = ["qdbus6", "org.projectblackbox.Desktop", "/Blackbox", "org.projectblackbox.Desktop."]


def desktop_script(script):
    return subprocess.check_output(PLASMA + [script], text=True, timeout=7).strip()


def remember(state):
    CONFIG.mkdir(parents=True, exist_ok=True)
    temporary = STATE.with_suffix(".tmp")
    temporary.write_text(json.dumps(state, indent=2), encoding="utf-8")
    temporary.replace(STATE)


def launcher():
    desktop = os.environ.get("BLACKBOX_DESKTOP_DIR")
    if not desktop:
        desktop = subprocess.check_output(["xdg-user-dir", "DESKTOP"], text=True, timeout=4).strip() if shutil.which("xdg-user-dir") else str(Path.home() / "Desktop")
    directory = Path(desktop).expanduser()
    if not directory.is_absolute() or directory == Path.home():
        directory = Path.home() / "Desktop"
    directory.mkdir(parents=True, exist_ok=True)
    target = directory / "Project Blackbox.desktop"
    if target.is_symlink() or target.exists() and "X-Project-Blackbox=true" not in target.read_text(errors="replace"):
        target = directory / "Blackbox Wallpaper.desktop"
    if target.is_symlink() or target.exists() and "X-Project-Blackbox=true" not in target.read_text(errors="replace"):
        raise SystemExit("A desktop shortcut with that name already exists.")
    # Desktop Entry Exec quoting is independent of shell parsing.
    def field(value):
        escaped = value.replace("\\", "\\\\").replace('"', '\\"').replace("$", "\\$").replace("`", "\\`").replace("%", "%%")
        return '"' + escaped + '"'
    target.write_text(
        "[Desktop Entry]\nType=Application\nName=Project Blackbox\n"
        f"Exec={field(sys.executable)} {field(str(HERE / 'desktop-session.py'))} play\n"
        f"Icon={HERE / 'blackbox-desktop.svg'}\nTerminal=false\nX-Project-Blackbox=true\n",
        encoding="utf-8",
    )
    target.chmod(0o755)


def activate(state):
    desktops = json.loads(desktop_script("print(JSON.stringify(desktops().map(d=>[String(d.id),d.wallpaperPlugin])))"))
    for key, plugin in desktops:
        if plugin and plugin != ID:
            state[key] = plugin
    remember(state)
    desktop_script(f"desktops().forEach(d=>{{d.wallpaperPlugin={json.dumps(ID)}}})")
    for _ in range(20):
        response = subprocess.run(BRIDGE[:-1] + [BRIDGE[-1] + "Configure", "mode", '"play"'],
                                  capture_output=True, timeout=2)
        if response.returncode == 0:
            subprocess.run(BRIDGE[:-1] + [BRIDGE[-1] + "Workspace", "front"], capture_output=True, timeout=2)
            return
        time.sleep(.2)


def revert(state):
    launcher()
    desktop_script(
        f"var before={json.dumps(state)};desktops().forEach(d=>{{if(d.wallpaperPlugin==={json.dumps(ID)})"
        f"{{d.wallpaperPlugin=before[String(d.id)]||{json.dumps(DEFAULT)}}}}})"
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("play", "revert", "shortcut"))
    args = parser.parse_args()
    state = json.loads(STATE.read_text(encoding="utf-8")) if STATE.exists() else {}
    if args.mode == "shortcut":
        launcher()
    elif args.mode == "play":
        activate(state)
    else:
        revert(state)


if __name__ == "__main__":
    main()
