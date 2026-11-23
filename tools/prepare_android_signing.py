"""Gera uma única chave de upload local; nunca sobrescreve credenciais existentes."""

import argparse
import json
import os
from pathlib import Path
import secrets
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def prepare(java_home):
    folder = ROOT / ".tools/signing"
    folder.mkdir(parents=True, exist_ok=True)
    keystore = folder / "zapfry-upload.jks"
    config = folder / "upload.json"
    if keystore.exists() or config.exists():
        raise RuntimeError("Chave ou configuração já existe; não será substituída.")
    password = secrets.token_hex(24)
    alias = "zapfry-upload"
    env = dict(os.environ, ZAPFRY_UPLOAD_PASSWORD=password)
    keytool = str(java_home / "bin/keytool.exe")
    subprocess.run([keytool, "-genkeypair", "-keystore", str(keystore), "-storetype", "JKS",
                    "-alias", alias, "-keyalg", "RSA", "-keysize", "3072", "-sigalg", "SHA256withRSA",
                    "-validity", "10000", "-dname", "CN=ZapFry Upload, OU=Games, O=mprovensi",
                    "-storepass:env", "ZAPFRY_UPLOAD_PASSWORD", "-keypass:env", "ZAPFRY_UPLOAD_PASSWORD"],
                   env=env, check=True, capture_output=True)
    config.write_text(json.dumps(dict(keystore=str(keystore), alias=alias, password=password,
                                     java_home=str(java_home)), indent=2), encoding="utf-8")
    subprocess.run([keytool, "-exportcert", "-rfc", "-keystore", str(keystore), "-alias", alias,
                    "-storepass:env", "ZAPFRY_UPLOAD_PASSWORD", "-file", str(folder / "upload-certificate.pem")],
                   env=env, check=True, capture_output=True)
    print("Chave de upload e certificado criados em .tools/signing; guarde um backup privado da pasta.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--java-home", type=Path, required=True)
    prepare(parser.parse_args().java_home)
