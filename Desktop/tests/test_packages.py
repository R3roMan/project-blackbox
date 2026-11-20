import contextlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("desktop_manage", Path(__file__).resolve().parents[1] / "manage.py")
manage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(manage)


class PackageRollbackTests(unittest.TestCase):
    def test_cube_upgrade_reverts_through_the_old_manifest(self):
        with tempfile.TemporaryDirectory() as temp, contextlib.redirect_stdout(io.StringIO()):
            root = Path(temp)
            data = root / "installed"
            stages = [root / "previous-stage", root / "next-stage"]
            old_packages = {key: value for key, value in manage.PACKAGES.items() if key != manage.CUBE_EFFECT}
            for stage, packages in zip(stages, (old_packages, manage.PACKAGES), strict=True):
                for relative in packages:
                    package = stage / relative
                    package.mkdir(parents=True)
                    (package / "version").write_text(stage.name)
            with patch.object(manage, "PACKAGES", old_packages), patch.object(manage, "stage", return_value=stages[0]):
                manage.install(data)
            with patch.object(manage, "stage", return_value=stages[1]):
                manage.install(data)
            self.assertTrue((data / manage.CUBE_EFFECT).is_dir())

            manage.remove(data)
            self.assertFalse((data / manage.CUBE_EFFECT).exists())
            self.assertEqual((data / "project-blackbox/version").read_text(), "previous-stage")
            manage.remove(data)
            self.assertFalse((data / "project-blackbox").exists())

    def test_manifest_cannot_remove_an_unrelated_package(self):
        with tempfile.TemporaryDirectory() as temp:
            data = Path(temp)
            history = data / "project-blackbox-installations"
            history.mkdir()
            manifest = history / "manifest.json"
            manifest.write_text(json.dumps({"dataRoot": str(data), "packages": {"unrelated": {}}}))
            (history / "latest").write_text(str(manifest))
            with self.assertRaisesRegex(SystemExit, "Manifest target check failed"):
                manage.remove(data)
