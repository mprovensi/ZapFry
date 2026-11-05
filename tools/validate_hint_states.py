"""Gera estados variados e audita as dicas realmente aplicadas pela engine."""

import argparse
import copy
import json
import random
from collections import Counter
from pathlib import Path

from validate_levels import MASKS, find_solution, is_solved, movable, rotate

ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "builds/hint-states-input.json"
OUTPUT = ROOT / "builds/hint-states-output.json"


def prepare():
    cases = []

    def add(name, state, valid_tee=-1):
        if is_solved(state):
            return
        solution = find_solution(state)
        cases.append({"name": name, "level": state["id"], "state": state,
                      "minimum_before": -1 if solution is None else solution["minimum_taps"],
                      "valid_tee": valid_tee})

    for file in sorted((ROOT / "levels").glob("level_*.json")):
        level = json.loads(file.read_text(encoding="utf-8"))
        number = level["id"]
        add(f"{number}-initial", copy.deepcopy(level))
        if number == 11:
            state = copy.deepcopy(level)
            state.pop("reference_path")
            state.pop("reference_taps")
            for cell in state["cells"]:
                cell.pop("solution")
            add("11-no-authored-reference", state)
        solution = find_solution(level)
        for order, moves in (("source", solution["moves"]), ("target", solution["moves"][::-1])):
            for fraction in (0.25, 0.5, 0.75):
                state = copy.deepcopy(level)
                for index in moves[:int(len(moves) * fraction)]:
                    state["cells"][index]["rotation"] = (state["cells"][index]["rotation"] + 1) % 4
                add(f"{number}-partial-{order}-{fraction}", state)
        for seed in range(32 if number >= 11 else 8):
            state = copy.deepcopy(level)
            rng = random.Random(number * 1000 + seed)
            for cell in state["cells"]:
                if movable(cell):
                    cell["rotation"] = rng.randrange(4)
            add(f"{number}-mistakes-{seed}", state)
        # Regressão: T em outra orientação que já une entrada e saída da rota.
        path, width = level["reference_path"], level["size"]
        for position, index in enumerate(path[1:-1], 1):
            if level["cells"][index]["kind"] != "tee":
                continue
            required = 0
            for neighbor in (path[position - 1], path[position + 1]):
                delta = neighbor // width - index // width, neighbor % width - index % width
                required |= {(-1, 0): 1, (0, 1): 2, (1, 0): 4, (0, -1): 8}[delta]
            for orientation in range(4):
                if orientation == level["cells"][index]["solution"] or rotate(MASKS["tee"], orientation) & required != required:
                    continue
                reference = [cell["solution"] for cell in level["cells"]]
                reference[index] = orientation
                if not is_solved(level, reference):
                    continue  # Servir ao caminho OUT não basta se o ramo alimenta uma lâmpada.
                state = copy.deepcopy(level)
                for previous in path[:position]:
                    state["cells"][previous]["rotation"] = state["cells"][previous]["solution"]
                state["cells"][index]["rotation"] = orientation
                add(f"{number}-valid-tee-{index}", state, index)
    # Sem referência autoral; inclui curvas, T, simetrias e estados impossíveis.
    for kind in ("curve", "tee", "straight"):
        for rotation in range(4):
            state = {"id": 0, "size": 2, "time_limit": 0, "source_index": 0, "source_port": 8,
                     "target_index": 3, "target_port": 4, "cells": [
                         {"kind": "curve", "rotation": 2, "fixed": True},
                         {"kind": "empty", "rotation": 0},
                         {"kind": kind, "rotation": rotation},
                         {"kind": "curve", "rotation": 3}]}
            add(f"small-{kind}-{rotation}", state)
    # Oráculos pequenos incluem redes ramificadas e duas lâmpadas, sem autoria.
    for kind in ("curve", "tee", "straight"):
        for lamps in ([2], [2, 3]):
            for fixed in (True, False):
                for seed in range(4):
                    state = {"id": 0, "size": 2, "time_limit": 90, "source_index": 0, "source_port": 8,
                             "target_index": 1, "target_port": 2, "required_nodes": lamps,
                             "cells": [{"kind": "tee", "rotation": 2, "fixed": fixed},
                                       {"kind": "straight", "rotation": 1, "fixed": True},
                                       {"kind": kind, "rotation": seed},
                                       {"kind": "curve", "rotation": (seed + 1) % 4}]}
                    add(f"lamp-{kind}-{len(lamps)}-{fixed}-{seed}", state)
    INPUT.write_text(json.dumps({"cases": cases}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Estados de dica preparados: {len(cases)}.")


def verify():
    cases = json.loads(INPUT.read_text(encoding="utf-8"))["cases"]
    # Godot pode serializar os inteiros lidos de JSON como 11.0.
    outputs = json.loads(OUTPUT.read_text(encoding="utf-8"),
                         parse_float=lambda value: int(float(value)) if float(value).is_integer() else float(value))["cases"]
    assert [c["name"] for c in cases] == [c["name"] for c in outputs], "Casos ausentes ou fora de ordem."
    counts, regressions, max_ms = Counter(), 0, 0
    for case, output in zip(cases, outputs):
        before = find_solution(case["state"])
        after = find_solution(output["state_after_hint"])
        if before is None:
            assert output["index"] == -1 and after is None, case["name"]
            continue
        assert after is not None, f"Dica tornou impossível: {case['name']}"
        assert after["minimum_taps"] < before["minimum_taps"], f"Dica sem benefício: {case['name']}"
        assert output["minimum_after_native"] == after["minimum_taps"], case["name"]
        assert output["completed"] and output["in_time"], case["name"]
        assert output["unchanged_others"], case["name"]
        if case["valid_tee"] >= 0:
            assert output["index"] != case["valid_tee"], f"T já conectado alterado: {case['name']}"
            regressions += 1
        counts[case["level"]] += 1
        max_ms = max(max_ms, output["solve_ms"])
    summary = {"total": len(cases), "passed": len(cases), "per_level": dict(counts),
               "valid_tee_regressions": regressions, "maximum_native_solve_ms": max_ms}
    (ROOT / "builds/hint-stress-results.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    lines = ["\n## Dicas em partidas parciais e com erros", "",
             f"**{len(cases)} estados aprovados**, com conferência independente em Python antes e depois da dica realmente aplicada pelo Godot.",
             f"Inclui {regressions} regressões com T já conectado, rota montada a partir da entrada/saída, rotações incorretas, simetrias e tabuleiros impossíveis.",
             "Toda dica concedida reduz os giros mínimos restantes e permite concluir pela engine; a simulação parte do estado de teste com o cronômetro integral e usa dois segundos por giro restante.", "",
             "| Fase | Estados com dica útil e conclusão |", "| --- | --- |"]
    lines += [f"| {n} | {counts[n]} |" for n in range(11, 25)]
    with (ROOT / "docs/TESTES_FASES.md").open("a", encoding="utf-8") as report:
        report.write("\n".join(lines) + "\n")
    print(f"Dicas: {len(cases)} estados aprovados; {regressions} T já conectados preservados; solução nativa máxima {max_ms:.2f} ms neste computador.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("prepare", "verify"))
    args = parser.parse_args()
    prepare() if args.action == "prepare" else verify()
