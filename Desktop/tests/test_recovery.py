import contextlib
import importlib.util
import io
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "desktop_session", Path(__file__).resolve().parents[1] / "runtime/desktop-session.py"
)
desktop = importlib.util.module_from_spec(spec)
spec.loader.exec_module(desktop)


class RecoveryTests(unittest.TestCase):
    def test_live_recovery_uses_every_activity_without_restarting(self):
        with patch.object(desktop, "desktop_script", return_value='{"desktops":3,"remaining":0}') as live:
            with patch.object(desktop, "stop_shell") as stop, contextlib.redirect_stdout(io.StringIO()):
                desktop.recover({"1": "org.kde.color", "2": desktop.ID}, True)
        script = live.call_args.args[0]
        self.assertIn("rooms=desktops()", script)
        self.assertIn('"1": "org.kde.color"', script)
        self.assertNotIn('"2":', script)
        stop.assert_not_called()

    def test_preview_cannot_restart_host_shell(self):
        with patch.object(desktop, "desktop_script", side_effect=subprocess.TimeoutExpired("qdbus6", 7)):
            with patch.dict(os.environ, {"BLACKBOX_PREVIEW": "1"}), patch.object(desktop, "stop_shell") as stop:
                with self.assertRaisesRegex(SystemExit, "Close the nested Plasma preview"):
                    desktop.recover({}, True)
        stop.assert_not_called()

    @unittest.skipUnless(shutil.which("kwriteconfig6"), "Requires KDE’s config writer")
    def test_offline_recovery_changes_only_the_blackbox_wallpaper_keys(self):
        contents = (
            "[Containments][1]\nplugin=org.kde.plasma.folder\nwallpaperplugin=org.projectblackbox.wallpaper\n"
            "[Containments][2]\nplugin=org.kde.panel\n"
            "[Containments][2][General]\nAppletOrder=4;5;7;3;6\n"
            "[Containments][2][Applets][5]\nplugin=org.kde.plasma.icontasks\n"
            "[Containments][2][Applets][5][Configuration][General]\nlaunchers=applications:org.kde.dolphin.desktop\n"
            "[Containments][3]\nplugin=org.kde.desktopcontainment\nwallpaperplugin=org.kde.color\n"
            "[Containments][9]\nplugin=org.kde.desktopcontainment\nwallpaperplugin=org.projectblackbox.wallpaper\n"
        )
        with tempfile.TemporaryDirectory() as temp:
            config = Path(temp)
            layout = config / "plasma-org.kde.plasma.desktop-appletsrc"
            layout.write_text(contents, encoding="utf-8")
            real_run = subprocess.run

            def safe_run(command, **options):
                if command[0] == "systemctl":
                    self.assertEqual(command, desktop.SHELL + ["start", "--no-block", desktop.SERVICE])
                    return subprocess.CompletedProcess(command, 0)
                return real_run(command, **options)

            with patch.object(desktop, "CONFIG", config), patch.dict(os.environ, {"BLACKBOX_PREVIEW": ""}):
                with patch.object(desktop, "desktop_script", side_effect=subprocess.TimeoutExpired("qdbus6", 7)):
                    with patch.object(desktop, "stop_shell") as stop, patch.object(subprocess, "check_output", return_value="loaded\n"):
                        with patch.object(subprocess, "run", side_effect=safe_run), contextlib.redirect_stdout(io.StringIO()):
                            desktop.recover({"1": "org.kde.slideshow"}, True)
            stop.assert_called_once()
            self.assertCountEqual(list(filter(None,layout.read_text().splitlines())), list(contents.replace(
                "wallpaperplugin=org.projectblackbox.wallpaper", "wallpaperplugin=org.kde.slideshow", 1
            ).replace("wallpaperplugin=org.projectblackbox.wallpaper", "wallpaperplugin=org.kde.image").splitlines()))
            self.assertEqual(next(config.glob("project-blackbox-recovery-*.appletsrc")).read_text(), contents)


if __name__ == "__main__":
    unittest.main()
