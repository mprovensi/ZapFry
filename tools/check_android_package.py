"""Confere dados e texturas realmente presentes no APK exportado."""

import argparse
from pathlib import Path
import re
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
CRITICAL_TEXTURES = [f"assets/art/concept_v3/{name}.png" for name in
                     ["portrait_idle", "portrait_zap", "portrait_recover", "menu_chair_wires",
                      "engineer", "engineer_middle", "engineer_down"]]
CRITICAL_TEXTURES.append("assets/characters/body_mask.svg")


def check_package(apk, project_root=ROOT):
    with ZipFile(apk) as archive:
        names = set(archive.namelist())
        forbidden = ("assets/tests/", "assets/tools/", "assets/builds/", "assets/docs/", "assets/test_sprites/")
        if any(name.startswith(forbidden) for name in names):
            raise RuntimeError("APK contém arquivos de teste, ferramentas ou rascunhos.")
        for source in sorted((project_root / "levels").glob("level_*.json")):
            name = "assets/levels/" + source.name
            if name not in names or archive.read(name) != source.read_bytes():
                raise RuntimeError("Fase ausente ou diferente no APK: " + source.name)
        character_textures = [path.relative_to(project_root).as_posix() for path in (project_root / "assets/characters").rglob("*.png")]
        for texture in CRITICAL_TEXTURES + character_textures:
            remap = "assets/" + texture + ".import"
            if remap not in names:
                raise RuntimeError("Textura crítica ausente no APK: " + texture)
        # A presença do .import não basta: o arquivo compilado precisa existir.
        remaps = [name for name in names if name.endswith((".png.import", ".svg.import"))]
        for remap in remaps:
            text = archive.read(remap).decode(errors="replace")
            target = re.search(r'path="res://([^\"]+)"', text)
            if not target or "assets/" + target[1] not in names or not archive.getinfo("assets/" + target[1]).file_size:
                raise RuntimeError("Textura compilada ausente no APK: " + remap)
        return len(remaps)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path)
    args = parser.parse_args()
    count = check_package(args.apk)
    print(f"APK: fases idênticas às fontes e {count} texturas importadas conferidas.")
