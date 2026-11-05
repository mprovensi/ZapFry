"""Valida seleção do alvo, integridade e save sem usar ADB real."""

from datetime import datetime, timedelta, timezone
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import install_android as installer


class AndroidInstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.apk = self.root / "game.apk"
        self.apk.write_bytes(b"verified apk")
        self.digest = hashlib.sha256(self.apk.read_bytes()).hexdigest()
        self.save = b"[progress]\nunlocked_level=9\ncurrent_level=1\n"
        self.calls = []
        self.profiles = [self.save, self.save]
        self.remote_digest = self.digest
        self.read_failure = False
        self.package_info = b" versionCode=25 minSdk=24\r\n versionName=0.15.0\r\n android.permission.VIBRATE: granted=true\r\n"
        self.startup_error = b""

    def fake_native(self, args, timeout=60):
        cmd = list(map(str, args[3:]))
        self.calls.append(cmd)
        if cmd[:3] == ["shell", "pm", "path"]:
            return b"package:/data/app/game.apk\n"
        if cmd[:2] == ["exec-out", "run-as"]:
            if self.read_failure:
                raise RuntimeError("run-as indisponível")
            return self.profiles.pop(0)
        if cmd[:2] == ["shell", "sha256sum"]:
            return (self.remote_digest + "  game.apk\n").encode()
        if cmd[:3] == ["shell", "pm", "install"]:
            return b"Success\n"
        if cmd[:3] == ["shell", "dumpsys", "package"]:
            return self.package_info
        if cmd[:2] == ["shell", "pidof"]:
            return b"12345\n"
        if cmd[:1] == ["logcat"]:
            return self.startup_error
        return b""

    def perform_install(self):
        with patch.object(installer, "native", side_effect=self.fake_native):
            return installer.install(self.apk, "adb", "SERIAL", "0.15.0", 25, self.root / "result")

    def test_device_selection_requires_unambiguous_authorized_target(self):
        header = b"List of devices attached\n"
        for output in [header, header + b"A offline\n", header + b"A device\nB device\n"]:
            with self.assertRaises(RuntimeError):
                installer.select_device(output)
        self.assertEqual(installer.select_device(header + b"A device\n"), "A")
        self.assertEqual(installer.select_device(header + b"A device\nB device\n", "B"), "B")
        with self.assertRaises(RuntimeError):
            installer.select_device(header + b"A unauthorized\n", "A")

    def test_install_preserves_profile_and_never_clears_data(self):
        result = self.perform_install()
        self.assertTrue(result["installed"] and result["profile_unchanged"])
        self.assertEqual((self.root / "result/profile-before.cfg").read_bytes(), self.save)
        self.assertEqual((self.root / "result/profile-after.cfg").read_bytes(), self.save)
        self.assertFalse(any("uninstall" in cmd or "clear" in cmd for cmd in self.calls))

    def test_wrong_transfer_hash_blocks_install(self):
        self.remote_digest = "0" * 64
        with self.assertRaisesRegex(RuntimeError, "transferido"):
            self.perform_install()
        self.assertFalse(any(cmd[:3] == ["shell", "pm", "install"] for cmd in self.calls))

    def test_unreadable_profile_blocks_install(self):
        self.read_failure = True
        with self.assertRaisesRegex(RuntimeError, "run-as"):
            self.perform_install()
        self.assertFalse(any(cmd[:3] == ["shell", "pm", "install"] for cmd in self.calls))

    def test_changed_profile_is_reported_and_not_launched(self):
        self.profiles[1] = b"changed profile"
        with self.assertRaisesRegex(RuntimeError, "Perfil mudou"):
            self.perform_install()
        self.assertFalse(any(cmd[:3] == ["shell", "am", "start"] for cmd in self.calls))
        status = json.loads((self.root / "result/status.json").read_text(encoding="utf-8"))
        self.assertTrue(status["package_installed"])
        self.assertFalse(status["installed"])

    def test_stale_apk_or_failed_verification_cannot_be_installed(self):
        report_path = self.root / "verification.json"
        report = dict(status="passed", suites=["test", "effects-test", "audio-test"],
                      finishedUtc=(datetime.now(timezone.utc) - timedelta(seconds=10)).isoformat())
        report_path.write_text(json.dumps(report), encoding="utf-8")
        installer.require_verification(self.apk, report_path)
        report["finishedUtc"] = (datetime.now(timezone.utc) + timedelta(seconds=10)).isoformat()
        report_path.write_text(json.dumps(report), encoding="utf-8")
        with self.assertRaisesRegex(RuntimeError, "APK anterior"):
            installer.require_verification(self.apk, report_path)
        report["status"] = "failed"
        report_path.write_text(json.dumps(report), encoding="utf-8")
        with self.assertRaisesRegex(RuntimeError, "não aprovados"):
            installer.require_verification(self.apk, report_path)

    def test_existing_install_without_save_can_be_updated(self):
        self.profiles = [b"__ZAPFRY_NO_PROFILE__", b"__ZAPFRY_NO_PROFILE__"]
        result = self.perform_install()
        self.assertTrue(result["installed"] and result["profile_unchanged"])

    def test_wrong_installed_version_is_not_launched(self):
        self.package_info = b"versionCode=24 minSdk=24\nversionName=0.14.6\n"
        with self.assertRaisesRegex(RuntimeError, "Versão instalada"):
            self.perform_install()
        self.assertFalse(any(cmd[:3] == ["shell", "am", "start"] for cmd in self.calls))

    def test_startup_error_fails_delivery_and_preserves_diagnostics(self):
        self.startup_error = b"Godot: ERROR: startup failed\n"
        with self.assertRaisesRegex(RuntimeError, "inicialização"):
            self.perform_install()
        self.assertEqual((self.root / "result/startup.log").read_text(encoding="utf-8"), self.startup_error.decode())

    def test_apk_identity_and_vibration_permission_are_required(self):
        identity = "package: name='com.zapfry.prototype' versionCode='25' versionName='0.15.0'\n"
        permission = "uses-permission: name='android.permission.VIBRATE'\n"
        self.assertEqual(installer.apk_identity(identity + permission), (25, "0.15.0"))
        for invalid in [identity, (identity + permission).replace("com.zapfry.prototype", "other.app")]:
            with self.assertRaises(RuntimeError):
                installer.apk_identity(invalid)

    def test_missing_installed_vibration_permission_fails_delivery(self):
        self.package_info = self.package_info.replace(b"granted=true", b"granted=false")
        with self.assertRaisesRegex(RuntimeError, "VIBRATE"):
            self.perform_install()
        self.assertFalse(any(cmd[:3] == ["shell", "am", "start"] for cmd in self.calls))


if __name__ == "__main__":
    unittest.main()
