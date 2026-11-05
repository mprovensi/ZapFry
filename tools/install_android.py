"""Instalação local após tools/dev.ps1 install; nunca apaga os dados do jogo."""

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = "com.zapfry.prototype"


def native(args, timeout=60):
    result = subprocess.run([str(value) for value in args], capture_output=True, timeout=timeout)
    if result.returncode:
        raise RuntimeError(result.stderr.decode(errors="replace") or result.stdout.decode(errors="replace"))
    return result.stdout


def require_verification(apk, report_path):
    report = json.loads(report_path.read_text(encoding="utf-8-sig"))
    if report.get("status") != "passed" or report.get("suites") != ["test", "effects-test", "audio-test"]:
        raise RuntimeError("Testes obrigatórios não aprovados. Execute tools/dev.ps1 install.")
    finished = datetime.fromisoformat(report["finishedUtc"].replace("Z", "+00:00")).timestamp()
    if apk.stat().st_mtime < finished:
        raise RuntimeError("APK anterior aos testes. Exporte e instale com tools/dev.ps1 install.")


def select_device(output, requested=None):
    devices = {}
    for line in output.decode(errors="replace").splitlines()[1:]:
        fields = line.split()
        if len(fields) >= 2:
            devices[fields[0]] = fields[1]
    if requested:
        if devices.get(requested) != "device":
            raise RuntimeError("Celular solicitado indisponível ou não autorizado no ADB.")
        return requested
    ready = [serial for serial, state in devices.items() if state == "device"]
    if len(ready) != 1:
        raise RuntimeError("Conecte um único celular autorizado ou informe -DeviceSerial.")
    return ready[0]


def apk_identity(badging):
    identity = re.search(r"package: name='([^']+)' versionCode='(\d+)' versionName='([^']+)'", badging)
    if not identity or identity[1] != PACKAGE:
        raise RuntimeError("APK não corresponde ao pacote do Zap & Fry.")
    if "uses-permission: name='android.permission.VIBRATE'" not in badging:
        raise RuntimeError("APK sem permissão VIBRATE. Entrega bloqueada.")
    return int(identity[2]), identity[3]


def install(apk, adb, serial, version, version_code, destination):
    destination.mkdir(parents=True, exist_ok=False)
    status = {"serial": serial, "version": version, "version_code": version_code, "installed": False}

    def call(*args, timeout=60):
        return native([adb, "-s", serial, *args], timeout=timeout)

    def profile_bytes():
        value = call("exec-out", "run-as", PACKAGE, "sh", "-c",
                     "if test -f files/prototype.cfg; then cat files/prototype.cfg; else printf __ZAPFRY_NO_PROFILE__; fi")
        return None if value == b"__ZAPFRY_NO_PROFILE__" else value

    try:
        existed = bool(call("shell", "pm", "path", PACKAGE).strip())
        if existed:
            call("shell", "am", "force-stop", PACKAGE)
        # Falha de leitura de um save existente interrompe a atualização.
        before = profile_bytes() if existed else None
        if before is not None:
            (destination / "profile-before.cfg").write_bytes(before)
        digest = hashlib.sha256(apk.read_bytes()).hexdigest()
        remote = "/data/local/tmp/zap-fry-verified.apk"
        call("push", str(apk.resolve()), remote, timeout=120)
        remote_digest = call("shell", "sha256sum", remote).decode().split()[0]
        if remote_digest != digest:
            raise RuntimeError("APK transferido difere do arquivo local. Instalação bloqueada.")
        result = call("shell", "pm", "install", "-r", remote, timeout=120).decode().strip()
        if "Success" not in result:
            raise RuntimeError("Instalação não confirmada: " + result)
        status["package_installed"] = True
        package_info = call("shell", "dumpsys", "package", PACKAGE).decode()
        if not re.search(rf"^\s*versionName={re.escape(version)}\s*$", package_info, re.M) or not re.search(rf"versionCode={version_code}\s", package_info):
            raise RuntimeError("Versão instalada difere do APK verificado.")
        if not re.search(r"android\.permission\.VIBRATE:\s+granted=true", package_info):
            raise RuntimeError("Permissão VIBRATE não concedida ao aplicativo instalado.")
        after = profile_bytes() if existed else None
        if after is not None:
            (destination / "profile-after.cfg").write_bytes(after)
        if before != after:
            raise RuntimeError("Perfil mudou durante a instalação; cópias preservadas para análise.")
        call("shell", "am", "start", "-a", "android.intent.action.MAIN", "-c", "android.intent.category.LAUNCHER", "-p", PACKAGE)
        process_id = ""
        for attempt in range(3):
            try:
                process_id = call("shell", "pidof", PACKAGE).decode().strip()
            except RuntimeError:
                pass
            if process_id:
                break
            time.sleep(0.5)
        if not process_id.isdigit():
            raise RuntimeError("APK instalado, mas processo de inicialização não confirmado.")
        errors = call("logcat", "-d", "--pid=" + process_id, "-s", "godot:E", "AndroidRuntime:E").decode(errors="replace")
        (destination / "startup.log").write_text(errors, encoding="utf-8")
        if errors.strip():
            raise RuntimeError("Erros na inicialização. Consulte startup.log.")
        status.update(installed=True, apk_sha256=digest, profile_unchanged=before == after,
                      existing_install=existed, process_id=int(process_id))
        return status
    except Exception as error:
        status["error"] = str(error)
        raise
    finally:
        (destination / "status.json").write_text(json.dumps(status, indent=2, ensure_ascii=False), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apk", type=Path, required=True)
    parser.add_argument("--serial")
    args = parser.parse_args()
    require_verification(args.apk, ROOT / "builds/verification.json")
    sdk = Path(os.environ.get("ANDROID_SDK_ROOT") or os.environ.get("ANDROID_HOME") or
               str(Path(os.environ["LOCALAPPDATA"]) / "Android/Sdk"))
    adb = sdk / "platform-tools/adb.exe"
    aapts = list((sdk / "build-tools").glob("*/aapt.exe"))
    if not aapts:
        raise RuntimeError("aapt não encontrado no Android SDK.")
    aapt = max(aapts, key=lambda path: path.stat().st_mtime)
    badging = native([aapt, "dump", "badging", args.apk]).decode(errors="replace")
    version_code, version = apk_identity(badging)
    serial = select_device(native([adb, "devices", "-l"]), args.serial)
    folder = ROOT / "builds/android" / datetime.now(timezone.utc).strftime("install-%Y%m%dT%H%M%S%fZ")
    result = install(args.apk, adb, serial, version, version_code, folder)
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
