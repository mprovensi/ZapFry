"""Regressões de recursos ausentes no APK, sem SDK ou compilação."""

from pathlib import Path
import sys
import tempfile
import unittest
from zipfile import ZipFile

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import check_android_package as checker


class AndroidPackageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "levels").mkdir()
        (self.root / "levels/level_01.json").write_bytes(b'{"id":1}')
        self.entries = {"assets/levels/level_01.json": b'{"id":1}'}
        for index, texture in enumerate(checker.CRITICAL_TEXTURES):
            target = f".godot/imported/texture_{index}.ctex"
            self.entries["assets/" + texture + ".import"] = f'[remap]\npath="res://{target}"'.encode()
            self.entries["assets/" + target] = b"compiled texture"

    def check(self):
        apk = self.root / "game.apk"
        with ZipFile(apk, "w") as archive:
            for name, data in self.entries.items():
                archive.writestr(name, data)
        return checker.check_package(apk, self.root)

    def test_valid_package(self):
        self.assertEqual(self.check(), len(checker.CRITICAL_TEXTURES))

    def test_missing_level_is_blocked(self):
        del self.entries["assets/levels/level_01.json"]
        with self.assertRaisesRegex(RuntimeError, "Fase ausente"):
            self.check()

    def test_different_level_is_blocked(self):
        self.entries["assets/levels/level_01.json"] = b'{"id":99}'
        with self.assertRaisesRegex(RuntimeError, "Fase ausente"):
            self.check()

    def test_missing_compiled_skeleton_is_blocked(self):
        del self.entries["assets/.godot/imported/texture_1.ctex"]
        with self.assertRaisesRegex(RuntimeError, "compilada ausente"):
            self.check()

    def test_test_sources_are_not_exported(self):
        self.entries["assets/tests/runner.gd"] = b"test source"
        with self.assertRaisesRegex(RuntimeError, "arquivos de teste"):
            self.check()

    def test_new_character_texture_is_required_in_apk(self):
        folder = self.root / "assets/characters/new_character"
        folder.mkdir(parents=True)
        (folder / "zap.png").write_bytes(b"new sprite source")
        with self.assertRaisesRegex(RuntimeError, "Textura crítica ausente"):
            self.check()
