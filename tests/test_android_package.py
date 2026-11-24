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

    def check(self, bundle=False, module="base"):
        apk = self.root / ("game.aab" if bundle else "game.apk")
        with ZipFile(apk, "w") as archive:
            for name, data in self.entries.items():
                archive.writestr((module + "/" if bundle else "") + name, data)
        return checker.check_package(apk, self.root)

    def test_valid_package(self):
        self.assertEqual(self.check(), len(checker.CRITICAL_TEXTURES))

    def test_bundle_resources_use_the_same_audit(self):
        self.assertEqual(self.check(bundle=True), len(checker.CRITICAL_TEXTURES))
        self.assertEqual(self.check(bundle=True, module="assetPackInstallTime"), len(checker.CRITICAL_TEXTURES))
        del self.entries["assets/.godot/imported/texture_1.ctex"]
        with self.assertRaisesRegex(RuntimeError, "compilada ausente"):
            self.check(bundle=True)

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
        folder = self.root / "assets/characters/presidiario"
        folder.mkdir(parents=True)
        for pose in ["idle", "zap", "recover"]:
            (folder / (pose + ".png")).write_bytes(b"new sprite source")
            remap = f"assets/assets/characters/presidiario/{pose}.png.import"
            compiled = f"assets/.godot/imported/presidiario_{pose}.ctex"
            for bundle in [False, True]:
                with self.subTest(pose=pose, bundle=bundle):
                    with self.assertRaisesRegex(RuntimeError, "Textura crítica ausente"):
                        self.check(bundle=bundle)
            self.entries[remap] = f'[remap]\npath="res://.godot/imported/presidiario_{pose}.ctex"'.encode()
            for bundle in [False, True]:
                with self.subTest(pose=pose, bundle=bundle, compiled=False):
                    with self.assertRaisesRegex(RuntimeError, "compilada ausente"):
                        self.check(bundle=bundle)
            self.entries[compiled] = b"compiled prisoner pose"
        for bundle in [False, True]:
            self.assertEqual(self.check(bundle=bundle), len(checker.CRITICAL_TEXTURES) + 3)

    def test_narrative_bytes_are_required_in_apk_and_bundle(self):
        folder = self.root / "assets/narrative"
        folder.mkdir(parents=True)
        source = folder / "campaign.json"
        source.write_bytes(b'{"phases":[]}')
        for bundle in [False, True]:
            with self.subTest(bundle=bundle):
                self.entries.pop("assets/assets/narrative/campaign.json", None)
                with self.assertRaisesRegex(RuntimeError, "Narrativa ausente"):
                    self.check(bundle=bundle)
                self.entries["assets/assets/narrative/campaign.json"] = b'{"wrong":true}'
                with self.assertRaisesRegex(RuntimeError, "Narrativa ausente"):
                    self.check(bundle=bundle)
                self.entries["assets/assets/narrative/campaign.json"] = source.read_bytes()
                self.check(bundle=bundle)
