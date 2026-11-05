"""Prova do bloqueio de entrega, sem compilar nem acessar um celular."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SHELL = shutil.which("pwsh") or shutil.which("powershell")


@unittest.skipUnless(sys.platform == "win32" and SHELL, "Fluxo PowerShell do host Windows")
class DeploymentPipelineTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="zapfry pipeline ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "tools").mkdir()
        (self.root / "bin").mkdir()
        (self.root / "scripts").mkdir()
        (self.root / "scripts/runtime.gd").write_text("extends Node\n", encoding="utf-8")
        shutil.copy2(ROOT / "tools/dev.ps1", self.root / "tools/dev.ps1")
        self.log = self.root / "calls.jsonl"
        self.env = dict(os.environ, ZAP_TEST_LOG=str(self.log), ZAP_TEST_FAIL="")
        self.env["PATH"] = str(self.root / "bin") + os.pathsep + self.env["PATH"]
        runner = self.root / "bin/fake_python.py"
        runner.write_text(
            "import json,os,sys\n"
            "with open(os.environ['ZAP_TEST_LOG'],'a',encoding='utf-8') as f: f.write(json.dumps(sys.argv[1:])+'\\n')\n"
            "failed=os.environ.get('ZAP_TEST_FAIL','')\n"
            "sys.exit(7 if failed and failed in ' '.join(sys.argv[1:]) else 0)\n", encoding="utf-8")
        (self.root / "bin/python.cmd").write_text(f'@"{sys.executable}" "{runner}" %*\n', encoding="utf-8")
        self.godot = self.root / "bin/fake_godot.ps1"
        self.godot.write_text(
            "$line = ConvertTo-Json -Compress -InputObject @($args)\n"
            "Add-Content -LiteralPath $env:ZAP_TEST_LOG -Value $line -Encoding utf8\n"
            "if ($env:ZAP_TEST_FAIL -and ([string]::Join(' ', $args)).Contains($env:ZAP_TEST_FAIL)) { exit 7 }\n"
            "if ($env:ZAP_TEST_MUTATE -and ((-not $env:ZAP_TEST_MUTATE_EXPORT_ONLY -and ($args -contains 'res://tests/run_audio_tests.gd')) -or ($args -contains '--export-debug'))) { Add-Content -LiteralPath $env:ZAP_TEST_MUTATE -Value '# changed' }\n"
            "if ($args -contains '--export-debug') { Set-Content -LiteralPath $args[-1] -Value 'fake package' }\n"
            "exit 0\n", encoding="utf-8-sig")

    def run_pipeline(self, action, fail=""):
        self.env["ZAP_TEST_FAIL"] = fail
        result = subprocess.run([SHELL, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                                 str(self.root / "tools/dev.ps1"), "-Action", action,
                                 "-GodotPath", str(self.godot)], cwd=self.root, env=self.env,
                                capture_output=True, timeout=45)
        calls = [json.loads(line.lstrip("\ufeff")) for line in self.log.read_text(encoding="utf-8-sig").splitlines()] if self.log.exists() else []
        return result, [" ".join(call) for call in calls]

    def test_required_suites_precede_export_and_install(self):
        result, calls = self.run_pipeline("install")
        self.assertEqual(result.returncode, 0, result.stderr.decode(errors="replace"))
        indices = [next(i for i, call in enumerate(calls) if marker in call) for marker in
                   ["run_tests.gd", "validate_hint_states.py verify", "run_effect_tests.gd", "run_audio_tests.gd", "--export-debug", "install_android.py"]]
        self.assertEqual(indices, sorted(indices))
        report = json.loads((self.root / "builds/verification.json").read_text(encoding="utf-8-sig"))
        self.assertEqual(report["status"], "passed")
        self.assertEqual(report["suites"], ["test", "effects-test", "audio-test"])

    def test_each_failed_suite_blocks_export_and_install(self):
        for marker in ["unittest", "run_tests.gd", "validate_hint_states.py verify", "run_effect_tests.gd", "run_audio_tests.gd"]:
            with self.subTest(stage=marker):
                self.log.write_text("", encoding="utf-8")
                result, calls = self.run_pipeline("install", marker)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(any("--export-debug" in call or "install_android.py" in call for call in calls))
                report = json.loads((self.root / "builds/verification.json").read_text(encoding="utf-8-sig"))
                self.assertEqual(report["status"], "failed")

    def test_export_failure_never_installs_old_apk(self):
        (self.root / "builds").mkdir()
        old = self.root / "builds/zap-fry-prototype.apk"
        old.write_bytes(b"old apk")
        result, calls = self.run_pipeline("install", "--export-debug")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any("install_android.py" in call for call in calls))
        self.assertEqual(old.read_bytes(), b"old apk")

    def test_windows_export_is_also_blocked_on_test_failure(self):
        result, calls = self.run_pipeline("windows", "run_effect_tests.gd")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any("--export-debug" in call for call in calls))

    def test_verify_runs_all_suites_without_exporting(self):
        result, calls = self.run_pipeline("verify")
        self.assertEqual(result.returncode, 0, result.stderr.decode(errors="replace"))
        self.assertTrue(any("run_audio_tests.gd" in call for call in calls))
        self.assertFalse(any("--export-debug" in call or "install_android.py" in call for call in calls))

    def test_concurrent_delivery_is_blocked_before_any_suite(self):
        (self.root / "builds").mkdir()
        wrapper = self.root / "locked.ps1"
        wrapper.write_text(
            "$lock=[IO.File]::Open((Join-Path $PSScriptRoot 'builds/deploy.lock'),'OpenOrCreate','ReadWrite','None')\n"
            "try { & (Join-Path $PSScriptRoot 'tools/dev.ps1') -Action android -GodotPath (Join-Path $PSScriptRoot 'bin/fake_godot.ps1') }\n"
            "finally { $lock.Dispose() }\n", encoding="utf-8-sig")
        result = subprocess.run([SHELL, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(wrapper)],
                                cwd=self.root, env=self.env, capture_output=True, timeout=30)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_edit_during_verification_blocks_export(self):
        self.env["ZAP_TEST_MUTATE"] = str(self.root / "scripts/runtime.gd")
        result, calls = self.run_pipeline("android")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any("--export-debug" in call for call in calls))

    def test_edit_during_export_blocks_install(self):
        self.env["ZAP_TEST_MUTATE"] = str(self.root / "scripts/runtime.gd")
        self.env["ZAP_TEST_MUTATE_EXPORT_ONLY"] = "1"
        result, calls = self.run_pipeline("install")
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(any("--export-debug" in call for call in calls))
        self.assertFalse(any("install_android.py" in call for call in calls))

    def test_invalid_exported_package_blocks_install(self):
        result, calls = self.run_pipeline("install", "check_android_package.py")
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(any("--export-debug" in call for call in calls))
        self.assertFalse(any("install_android.py" in call for call in calls))


if __name__ == "__main__":
    unittest.main()
