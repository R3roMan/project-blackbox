#!/usr/bin/env python3
"""Run Blackbox's automated regressions and retain any failures for triage."""
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


root = Path(__file__).resolve().parent.parent
state = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
logs = state / "project-blackbox/checks"
runner = shutil.which("qmltestrunner") or "/usr/lib/qt6/bin/qmltestrunner"
checks = {
    "shared-game": [runner, "-input", str(root / "Demo/tests")],
    "desktop-recovery-and-packaging": [sys.executable, "-m", "unittest", "discover", "-s", str(root / "Desktop/tests"), "-p", "test_*.py"],
}

with tempfile.TemporaryDirectory(prefix="blackbox-check-") as config:
    env = dict(os.environ, XDG_CONFIG_HOME=config, QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software")
    failed = False
    for name, command in checks.items():
        try:
            result = subprocess.run(command, env=env, cwd=root, text=True, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, timeout=85)
            output, status = result.stdout, result.returncode
            if name == "shared-game" and any(warning in output for warning in ("TypeError:", "ReferenceError:", "Unable to assign", "Binding loop")):
                status = status or 1
        except (OSError, subprocess.TimeoutExpired) as error:
            output, status = str(error), 1
        print(output, end="\n" if not output.endswith("\n") else "")
        if status:
            failed = True
            stamp = datetime.now(timezone.utc)
            logs.mkdir(parents=True, exist_ok=True)
            path = logs / (stamp.strftime("%Y%m%dT%H%M%S%fZ") + "-" + name + ".log")
            path.write_text(output, encoding="utf-8")
            entry = {"time": stamp.isoformat(), "check": name, "status": status, "log": str(path)}
            with (logs.parent / "regressions.jsonl").open("a", encoding="utf-8") as ledger:
                ledger.write(json.dumps(entry) + "\n")
            print(f"Recorded {name} failure in {path}")
sys.exit(failed)
