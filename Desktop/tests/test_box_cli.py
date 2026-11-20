from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


box = Path(__file__).resolve().parents[1] / "runtime/terminal/box"


class BoxCliTests(unittest.TestCase):
    def run_box(self, *args):
        return subprocess.run([sys.executable, str(box), *args], capture_output=True, text=True, check=True)

    def test_expand_help_and_print_reference_without_plasma(self):
        root = self.run_box("help").stdout
        self.assertIn("box help -options =graphics", root)
        self.assertIn(box.with_name("COMMANDS.md").as_uri(), root)
        self.assertIn("backgroundIdle", self.run_box("help", "-options", "=idle").stdout)
        self.assertIn("16:9", self.run_box("help", "-options", "=graphics", "=framing").stdout)
        self.assertIn("WEAPON_ID", self.run_box("help", "debug", "weapon").stdout)
        self.assertIn("Ctrl+Shift+C", self.run_box("manual").stdout)

    def test_pet_catalog_and_short_errors_work_without_plasma(self):
        import json
        catalog = json.loads((box.parent.parent / "PetCatalog.js").read_text().split("var groups = ", 1)[1])
        command_names = [command["name"] for group in catalog.values() for command in group]
        self.assertGreaterEqual(len(set(command_names)), 50)
        self.assertIn("pet write", self.run_box("help", "-pet", "=commands", ".write").stdout)
        group = self.run_box("help", "-pet", "=commands", ".care", "+show").stdout
        self.assertIn("treat", group)
        self.assertIn("vine", group)
        self.assertIn(box.with_name("PET.md").as_uri(), group)
        invalid = subprocess.run([sys.executable, str(box), "not-a-command"], capture_output=True, text=True)
        self.assertEqual(invalid.returncode, 2)
        self.assertEqual(invalid.stderr.splitlines(), ["box: Invalid command or value. Try box help."])
        self.assertTrue(all("pet "+name in box.with_name("PET.md").read_text() for name in command_names))

    def test_folder_with_spaces_resolves_for_a_shell_pipeline(self):
        with tempfile.TemporaryDirectory() as temp:
            folder = Path(temp) / "Archive files"
            folder.mkdir()
            (folder / "notes.txt").write_text("notes")
            self.assertEqual(self.run_box("location", str(folder)).stdout.strip(), str(folder))
            self.assertIn("notes.txt", self.run_box("files", str(folder)).stdout)

    def test_redirected_ascii_art_keeps_the_transcript_plain(self):
        text = self.run_box("me").stdout
        self.assertIn("(####)", text)
        self.assertGreater(len(text.splitlines()), 10)
        self.assertNotIn("\x1b", text)
