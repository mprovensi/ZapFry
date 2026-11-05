"""Autoria determinística do segundo setor. Não há geração procedural no jogo.

As rotas, custos e obstáculos são explícitos. Cada fase é auditada antes de
gravar; arquivos existentes só são substituídos com --overwrite.
"""

import argparse
import json
from pathlib import Path

from validate_levels import MASKS, audit_level, rotate

ROOT = Path(__file__).resolve().parents[1]
WIDTH = 5
SPECS = [{'id': 9,
  'name': 'Painel maior, sem pressa',
  'time': 0,
  'guided': True,
  'path': [0, 1, 2, 3, 4, 9, 14, 19, 24],
  'costs': {1: 1, 2: 1, 3: 1, 4: 1, 9: 1, 14: 1},
  'fixed': [0, 19, 24],
  'instruction': 'A grade cresceu. Siga a seta e jogue sem pressa.',
  'tips': ['Agora a grade tem 5 × 5 casas.', 'Mesma regra, sem limite de tempo.']},
 {'id': 10,
  'name': 'Uma luz antes do choque',
  'required_nodes': [12],
  'time': 150,
  'path': [0, 1, 6, 11, 12, 13, 14, 19, 24],
  'costs': {1: 2, 6: 1, 11: 3, 12: 1, 13: 1, 14: 3, 19: 1},
  'instruction': 'Ligue IN a OUT e acenda a lâmpada marcada.',
  'tips': ['A lâmpada também precisa de energia.', 'Só então a cadeira dispara.'],
  'guided': False,
  'distractors': {2: ('curve', 3),
                  3: ('curve', 1),
                  4: ('curve', 0),
                  5: ('straight', 1),
                  7: ('straight', 1),
                  8: ('curve', 0),
                  9: ('curve', 0),
                  10: ('curve', 2),
                  15: ('curve', 1),
                  16: ('straight', 0),
                  17: ('curve', 1),
                  18: ('curve', 0),
                  20: ('curve', 3),
                  21: ('straight', 3),
                  22: ('curve', 1),
                  23: ('curve', 3)},
  'tees': {},
  'minimum_taps': 12},
 {'id': 11,
  'name': 'O T também acende a luz',
  'required_nodes': [6],
  'lamp_solutions': {6: 0},
  'time': 180,
  'path': [0, 5, 10, 11, 12, 7, 8, 9, 14, 19, 24],
  'costs': {5: 1, 10: 3, 11: 1, 12: 1, 7: 3, 8: 1, 9: 1, 14: 1, 19: 1},
  'tees': {11: 0},
  'instruction': 'Use um ramo do T para acender a lâmpada e ligue OUT.',
  'tips': ['A lâmpada pode ficar num ramo do T.', 'Cadeira e lâmpada ligadas juntas.'],
  'guided': False,
  'distractors': {1: ('curve', 1),
                  2: ('straight', 3),
                  3: ('straight', 3),
                  4: ('curve', 3),
                  6: ('straight', 1),
                  13: ('straight', 0)},
  'minimum_taps': 14},
 {'id': 12,
  'name': 'Fusível no atalho',
  'time': 180,
  'path': [0, 5, 10, 15, 16, 17, 12, 13, 14, 19, 24],
  'costs': {5: 1, 10: 1, 15: 2, 16: 1, 17: 3, 12: 3, 13: 1, 14: 3, 19: 1},
  'blockers': [11],
  'instruction': 'Ligue IN a OUT. Há fios que não levam ao destino.',
  'tips': ['Fusíveis cortam possíveis atalhos.', 'Escolha bem por onde passar.'],
  'guided': False,
  'distractors': {1: ('curve', 0),
                  2: ('curve', 3),
                  3: ('curve', 2),
                  4: ('curve', 3),
                  6: ('curve', 2),
                  7: ('straight', 1)},
  'tees': {},
  'minimum_taps': 16},
 {'id': 13,
  'name': 'Corrente dividida',
  'time': 180,
  'path': [0, 1, 6, 5, 10, 15, 16, 11, 12, 7, 8, 9, 14, 19, 24],
  'costs': {1: 3, 6: 2, 5: 2, 10: 1, 15: 2, 16: 1, 11: 1, 12: 1, 7: 1, 8: 1, 9: 1, 14: 1, 19: 1},
  'tees': {12: 3},
  'blockers': [2, 17],
  'instruction': 'Ligue IN a OUT. Há fios que não levam ao destino.',
  'tips': ['O T oferece mais de um caminho.', 'Nem todo ramo chega à saída.'],
  'guided': False,
  'distractors': {3: ('straight', 3),
                  4: ('straight', 0),
                  13: ('curve', 1),
                  18: ('straight', 2),
                  20: ('curve', 0),
                  21: ('straight', 3)},
  'minimum_taps': 18},
 {'id': 14,
  'name': 'Contorno duplo',
  'time': 180,
  'path': [0, 5, 6, 7, 2, 3, 4, 9, 14, 13, 18, 23, 24],
  'costs': {5: 3, 6: 1, 7: 3, 2: 2, 3: 1, 4: 2, 9: 1, 14: 1, 13: 2, 18: 1, 23: 3},
  'tees': {6: 0, 14: 3},
  'blockers': [1, 8],
  'instruction': 'Ligue IN a OUT. Há fios que não levam ao destino.',
  'tips': ['O T oferece mais de um caminho.', 'Nem todo ramo chega à saída.'],
  'guided': False,
  'distractors': {10: ('curve', 1),
                  11: ('straight', 0),
                  12: ('straight', 0),
                  15: ('straight', 3),
                  16: ('curve', 3),
                  17: ('curve', 0)},
  'minimum_taps': 20},
 {'id': 15,
  'name': 'Fios e distrações',
  'time': 180,
  'path': [0, 1, 6, 5, 10, 15, 16, 17, 18, 13, 14, 19, 24],
  'costs': {1: 3, 6: 2, 5: 3, 10: 1, 15: 3, 16: 1, 17: 1, 18: 2, 13: 2, 14: 3, 19: 1},
  'tees': {16: 2, 13: 1},
  'blockers': [11, 8],
  'instruction': 'Ligue IN a OUT. Há fios que não levam ao destino.',
  'tips': ['O T oferece mais de um caminho.', 'Nem todo ramo chega à saída.'],
  'guided': False,
  'distractors': {2: ('curve', 2),
                  3: ('curve', 3),
                  4: ('curve', 3),
                  7: ('straight', 2),
                  9: ('straight', 1),
                  12: ('straight', 1)},
  'minimum_taps': 22},
 {'id': 16,
  'name': 'Engenheiro do setor',
  'time': 180,
  'path': [0, 5, 10, 11, 12, 7, 8, 9, 14, 13, 18, 17, 22, 23, 24],
  'costs': {5: 1, 10: 3, 11: 1, 12: 3, 7: 2, 8: 1, 9: 1, 14: 2, 13: 1, 18: 3, 17: 3, 22: 2, 23: 1},
  'tees': {11: 2, 14: 3},
  'blockers': [6, 16],
  'instruction': 'Ligue IN a OUT. Há fios que não levam ao destino.',
  'tips': ['O T oferece mais de um caminho.', 'Nem todo ramo chega à saída.'],
  'guided': False,
  'distractors': {1: ('curve', 1),
                  2: ('straight', 1),
                  3: ('curve', 0),
                  4: ('straight', 0),
                  15: ('straight', 1),
                  19: ('straight', 3)},
  'minimum_taps': 24}]


def port_between(left: int, right: int, width: int = WIDTH) -> int:
    delta = right // width - left // width, right % width - left % width
    return {(-1, 0): 1, (0, 1): 2, (1, 0): 4, (0, -1): 8}[delta]


def make_level(spec: dict, width: int = WIDTH) -> dict:
    path = spec["path"]
    cells = [{"kind": "empty", "rotation": 0, "solution": 0} for _ in range(width * width)]
    fixed = spec.get("fixed", [path[0], path[-1]])
    for position, index in enumerate(path):
        incoming = port_between(index, path[position - 1], width) if position else 8
        outgoing = port_between(index, path[position + 1], width) if position + 1 < len(path) else 2
        required = incoming | outgoing
        if index in spec.get("tees", {}):
            kind, goal = "tee", spec["tees"][index]
            if rotate(MASKS[kind], goal) & required != required:
                raise ValueError(f"T incompatível: fase {spec['id']}, célula {index}.")
        else:
            kind = "straight" if required in (5, 10) else "curve"
            goal = next(r for r in range(4) if rotate(MASKS[kind], r) == required)
        turns = spec["costs"].get(index, 0)
        initial = (goal - turns) % 4
        if index in fixed and turns:
            raise ValueError("Peça fixa não pode estar embaralhada.")
        cells[index] = {"kind": kind, "rotation": initial, "solution": goal}
        if index in fixed:
            cells[index]["fixed"] = True
    for index in spec.get("blockers", []):
        if index in path:
            raise ValueError("Fusível bloqueia a rota autoral.")
        cells[index] = {"kind": "blocker", "rotation": 0, "solution": 0, "fixed": True}
    for index, (kind, rotation) in spec.get("distractors", {}).items():
        if cells[index]["kind"] != "empty":
            raise ValueError("Distração sobrescreve outro componente.")
        cells[index] = {"kind": kind, "rotation": rotation, "solution": rotation}
    branch_taps = 0
    for index, goal in spec.get("lamp_solutions", {}).items():
        cell = cells[index]
        cell["solution"] = goal
        branch_taps += next(t for t in range(4) if rotate(MASKS[cell["kind"]], cell["rotation"] + t)
                           == rotate(MASKS[cell["kind"]], goal))
    result = {"id": spec["id"], "name": spec["name"], "size": width, "time_limit": spec["time"],
              "source_index": path[0], "source_port": 8, "target_index": path[-1], "target_port": 2,
              "reference_path": path, "guided": spec.get("guided", False),
              "reference_taps": sum(spec["costs"].values()) + branch_taps, "lesson": "five_by_five" if width == 5 else "six_by_six",
              "instruction": spec["instruction"], "tip_lines": spec["tips"], "cells": cells}
    if spec.get("required_nodes"):
        result.update(required_nodes=spec["required_nodes"], rules_revision=2)
    report = audit_level(result)
    expected_minimum = spec.get("minimum_taps", result["reference_taps"])
    if report["minimum_taps"] != expected_minimum:
        raise ValueError(f"Fase {spec['id']}: esperado {expected_minimum}, mínimo encontrado {report['minimum_taps']}.")
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--overwrite", action="store_true")
    args = parser.parse_args()
    levels = [make_level(spec) for spec in SPECS]
    files = [ROOT / "levels" / f"level_{level['id']:02d}.json" for level in levels]
    if not args.overwrite and any(file.exists() for file in files):
        parser.error("Fases já existem. Use --overwrite apenas para regenerar os dados autorais.")
    for file, level in zip(files, levels):
        file.write_text(json.dumps(level, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"{file.name}: 5x5; {level['reference_taps']} toques; auditada.")


if __name__ == "__main__":
    main()
