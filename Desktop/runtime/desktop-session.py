#!/usr/bin/env python3
"""Switch only Blackbox's Plasma wallpaper and provide a reversible desktop launcher."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time

HERE = Path(__file__).resolve().parent
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
STATE = CONFIG / "project-blackbox-wallpapers.json"
ID = "org.projectblackbox.wallpaper"
DEFAULT = "org.kde.image"
PLASMA = ["qdbus6", "org.kde.plasmashell", "/PlasmaShell", "org.kde.PlasmaShell.evaluateScript"]
BRIDGE = ["qdbus6", "org.projectblackbox.Desktop", "/Blackbox", "org.projectblackbox.Desktop."]
SHELL = ["systemctl", "--user"]
SERVICE = "plasma-plasmashell.service"


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
    command = f"{field(sys.executable)} {field(str(HERE / 'desktop-session.py'))}"
    target.write_text(
        "[Desktop Entry]\nType=Application\nName=Project Blackbox\n"
        f"Exec={command} play\nIcon={HERE / 'blackbox-desktop.svg'}\nTerminal=false\n"
        "Actions=Recovery;\nX-Project-Blackbox=true\n\n[Desktop Action Recovery]\nName=Recover KDE wallpaper\n"
        f"Exec={command} recover\n",
        encoding="utf-8",
    )
    target.chmod(0o755)


def active_desktops():
    return json.loads(desktop_script(
        "print(JSON.stringify(desktopsForActivity(currentActivity()).map(d=>"
        "({id:String(d.id),screen:d.screen,plugin:d.wallpaperPlugin}))))"
    ))


def activate(state):
    desktops = active_desktops()
    if not desktops:
        raise SystemExit("Plasma has no desktop on the current Activity.")
    if not any(d["plugin"] == ID for d in desktops):
        target = next((d for d in desktops if d["id"] == state.get("_launchTarget")), None)
        if target is None:
            target = next((d for d in desktops if d.get("screen") == 0), desktops[0])
        key = target["id"]
        if target["plugin"]:
            state[key] = target["plugin"]
        state["_launchTarget"] = key
        remember(state)
        desktop_script(
            f"var target=desktopsForActivity(currentActivity()).find(d=>String(d.id)==={json.dumps(key)});"
            f"if(target) target.wallpaperPlugin={json.dumps(ID)};"
        )
    for _ in range(20):
        response = subprocess.run(BRIDGE[:-1] + [BRIDGE[-1] + "Configure", "mode", '"idle"'],
                                  capture_output=True, timeout=2)
        if response.returncode == 0:
            subprocess.run(BRIDGE[:-1] + [BRIDGE[-1] + "Workspace", "front"], capture_output=True, timeout=2)
            return
        time.sleep(.2)


def restore_wallpapers(state, all_activities=False):
    desktops = "desktops()" if all_activities else "desktopsForActivity(currentActivity())"
    desktop_script(
        f"var before={json.dumps(state)};{desktops}.forEach(d=>{{if(d.wallpaperPlugin==={json.dumps(ID)})"
        f"{{d.wallpaperPlugin=before[String(d.id)]||{json.dumps(DEFAULT)}}}}})"
    )


def installed_wallpapers(layout):
    """Return the top-level containments explicitly using the Blackbox wallpaper."""
    groups = re.split(r"(?m)^(\[[^\n]+\])\s*$", layout.read_text(encoding="utf-8"))
    for section, contents in zip(groups[1::2], groups[2::2]):
        match = re.fullmatch(r"\[Containments\]\[(\d+)\]", section)
        if match and any(line.strip() == f"wallpaperplugin={ID}" for line in contents.splitlines()):
            yield match[1]


def stop_shell():
    def wait_stopped(seconds):
        end = time.monotonic() + seconds
        while time.monotonic() < end:
            status = subprocess.check_output(SHELL + ["show", SERVICE, "-p", "ActiveState", "-p", "MainPID"],
                                             text=True, timeout=4).splitlines()
            if "MainPID=0" in status and any(item in status for item in ("ActiveState=inactive", "ActiveState=failed")):
                return True
            time.sleep(.25)
        return False

    subprocess.run(SHELL + ["stop", "--no-block", SERVICE], check=True, timeout=5)
    if not wait_stopped(8):
        subprocess.run(SHELL + ["kill", "--kill-whom=main", "--signal=KILL", SERVICE], check=True, timeout=5)
        if not wait_stopped(8):
            raise SystemExit("Plasma Shell is still running. Recovery has made no layout changes.")


def recover(state, restart_shell):
    try:
        restore_wallpapers(state, all_activities=True)
        print("Restored the KDE wallpaper. Blackbox saves and application windows were kept.")
        return
    except (subprocess.SubprocessError, OSError):
        if not restart_shell:
            raise SystemExit("Plasma Shell did not answer. Run recovery again with --restart-shell from a terminal.") from None
    if os.environ.get("BLACKBOX_PREVIEW") or str(CONFIG).startswith("/tmp/project-blackbox-preview."):
        raise SystemExit("Close the nested Plasma preview window to recover it.")
    loaded = subprocess.check_output(SHELL + ["show", SERVICE, "-p", "LoadState", "--value"], text=True, timeout=5).strip()
    if loaded != "loaded":
        raise SystemExit("Recovery requires the systemd-managed Plasma Shell service for this session.")
    layout = CONFIG / "plasma-org.kde.plasma.desktop-appletsrc"
    if not layout.is_file() or layout.is_symlink() or not shutil.which("kwriteconfig6"):
        raise SystemExit("Recovery could not open the usual Plasma layout or find KDE's settings writer.")
    stop_shell()
    targets = list(installed_wallpapers(layout))
    if targets:
        with tempfile.NamedTemporaryFile(prefix="project-blackbox-recovery-", suffix=".appletsrc", dir=CONFIG, delete=False) as backup:
            shutil.copyfile(layout, backup.name)
        print(f"Saved the original Plasma layout to {backup.name}", flush=True)
        for target in targets:
            previous = state.get(target)
            wallpaper = previous if isinstance(previous, str) and previous and previous != ID else DEFAULT
            subprocess.run(["kwriteconfig6", "--file", str(layout), "--group", "Containments", "--group", target,
                            "--key", "wallpaperplugin", wallpaper], check=True, timeout=7)
        if list(installed_wallpapers(layout)):
            raise SystemExit("Blackbox is still active in the configuration. Review the saved layout before starting Plasma Shell.")
    subprocess.run(SHELL + ["start", "--no-block", SERVICE], check=True, timeout=5)
    print("Started Plasma Shell with the restored wallpaper. Application windows and Blackbox saves were kept.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("play", "revert", "shortcut", "recover"))
    parser.add_argument("--restart-shell", action="store_true", help="Restart only Plasma Shell if live recovery is unavailable.")
    args = parser.parse_args()
    state = json.loads(STATE.read_text(encoding="utf-8")) if STATE.exists() else {}
    if args.mode == "shortcut":
        launcher()
    elif args.mode == "play":
        activate(state)
    elif args.mode == "recover":
        recover(state, args.restart_shell)
    else:
        launcher()
        restore_wallpapers(state)


if __name__ == "__main__":
    main()
