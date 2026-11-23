"""Audita assinatura, manifesto e bibliotecas de APK/AAB de publicação."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import xml.etree.ElementTree as ET
from zipfile import ZipFile

from install_android import PACKAGE, ROOT, apk_identity

ANDROID = "{http://schemas.android.com/apk/res/android}"


def run(args):
    return subprocess.check_output([str(value) for value in args], stderr=subprocess.STDOUT).decode(errors="replace")


def check_manifest(text, version, code):
    manifest = ET.fromstring(text)
    sdk = manifest.find("uses-sdk")
    app = manifest.find("application")
    if (manifest.get("package") != PACKAGE or manifest.get(ANDROID + "versionName") != version
            or manifest.get(ANDROID + "versionCode") != str(code)):
        raise RuntimeError("Identidade do AAB difere do APK.")
    if sdk is None or int(sdk.get(ANDROID + "targetSdkVersion", "0")) < 36:
        raise RuntimeError("AAB deve usar target API 36 ou superior.")
    if app is None or app.get(ANDROID + "debuggable", "false") != "false":
        raise RuntimeError("AAB de publicação não pode ser depurável.")


def check_elf(data):
    if data[:6] != b"\x7fELF\x02\x01":
        raise RuntimeError("Biblioteca deve ser ELF 64-bit little-endian.")
    offset = struct.unpack_from("<Q", data, 32)[0]
    size, count = struct.unpack_from("<HH", data, 54)
    loads = 0
    for index in range(count):
        kind, _, file_offset, address, _, _, _, alignment = struct.unpack_from("<IIQQQQQQ", data, offset + size * index)
        if kind == 1:
            loads += 1
            if alignment < 16384 or file_offset % 16384 != address % 16384:
                raise RuntimeError("Biblioteca sem alinhamento ELF de 16 KB.")
    if not loads:
        raise RuntimeError("Biblioteca sem segmentos LOAD.")


def check_release(apk, bundle):
    signing = json.loads((ROOT / ".tools/signing/upload.json").read_text(encoding="utf-8"))
    java = Path(signing["java_home"]) / "bin"
    sdk = Path(os.environ.get("ANDROID_SDK_ROOT") or os.environ.get("ANDROID_HOME")
               or str(Path(os.environ["LOCALAPPDATA"]) / "Android/Sdk"))
    build_tools = max((sdk / "build-tools").iterdir(), key=lambda path: path.stat().st_mtime)
    bundletool = max((ROOT / ".tools").glob("bundletool-all-*.jar"), key=lambda path: path.stat().st_mtime)
    info = run([build_tools / "aapt.exe", "dump", "badging", apk])
    code, version = apk_identity(info)
    if "application-debuggable" in info or not re.search(r"targetSdkVersion:'(3[6-9]|[4-9]\d)'", info):
        raise RuntimeError("APK deve ser release com target API 36 ou superior.")
    signature = run([build_tools / "apksigner.bat", "verify", "--verbose", "--print-certs", apk])
    digest = re.search(r"Signer #1 certificate SHA-256 digest: ([0-9a-f]+)", signature)
    if not digest:
        raise RuntimeError("Certificado do APK não encontrado.")
    env = dict(os.environ, ZAPFRY_UPLOAD_PASSWORD=signing["password"])
    certificate = subprocess.check_output([str(java / "keytool.exe"), "-exportcert", "-keystore", signing["keystore"],
                                          "-alias", signing["alias"], "-storepass:env", "ZAPFRY_UPLOAD_PASSWORD"], env=env)
    expected = hashlib.sha256(certificate).hexdigest()
    if digest[1] != expected:
        raise RuntimeError("APK não foi assinado com a chave de upload.")
    verified = run([java / "jarsigner.exe", "-J-Duser.language=en", "-verify", bundle])
    if "jar verified." not in verified:
        raise RuntimeError("Assinatura JAR do AAB não foi validada.")
    bundle_certificate = run([java / "keytool.exe", "-J-Duser.language=en", "-printcert", "-jarfile", bundle])
    if expected not in bundle_certificate.replace(":", "").lower():
        raise RuntimeError("AAB não foi assinado com a mesma chave de upload.")
    run([java / "java.exe", "-jar", bundletool, "validate", "--bundle=" + str(bundle)])
    manifest = run([java / "java.exe", "-jar", bundletool, "dump", "manifest", "--bundle=" + str(bundle)])
    check_manifest(manifest, version, code)
    run([build_tools / "zipalign.exe", "-c", "-P", "16", "4", apk])
    libraries = {}
    for package in (apk, bundle):
        with ZipFile(package) as archive:
            native = [name for name in archive.namelist() if name.endswith(".so")]
            if not native:
                raise RuntimeError("Pacote sem bibliotecas nativas.")
            for name in native:
                check_elf(archive.read(name))
            libraries[package.name] = native
    report = dict(package=PACKAGE, version=version, version_code=code, target_api=36,
                  certificate_sha256=expected, libraries=libraries,
                  artifacts={path.name: dict(bytes=path.stat().st_size,
                                            sha256=hashlib.sha256(path.read_bytes()).hexdigest()) for path in (apk, bundle)})
    (apk.parent / "release-audit.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("Release: APK e AAB assinados, sem debug, API 36, recursos e alinhamento 16 KB aprovados.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path)
    parser.add_argument("bundle", type=Path)
    args = parser.parse_args()
    check_release(args.apk, args.bundle)
