"""Valida fases e procura a solução com menos toques, sem ler a solução autoral.

Cada vitória contém um caminho simples entre os terminais. O Dijkstra explora
caminhos sem repetir células e escolhe, em cada peça, a rotação mais barata que
aceita a entrada e a saída. Portas extras do T são permitidas. Isso dispensa
enumerar todas as orientações do tabuleiro e mantém o auditor independente do
resolvedor em GDScript. Somente a validação da referência lê solution/path.
"""

import argparse
from functools import cache
import heapq
import itertools
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MASKS = {"straight": 5, "curve": 3, "tee": 11, "empty": 0, "blocker": 0}
# Porta, variação de linha, variação de coluna, porta oposta.
DIRECTIONS = ((1, -1, 0, 4), (2, 0, 1, 8), (4, 1, 0, 1), (8, 0, -1, 2))
SECONDS_PER_TAP = 2.0  # Hipótese de teste; não é uma medição de jogador humano.


def rotate(mask: int, turns: int) -> int:
    turns %= 4
    return ((mask << turns) | (mask >> (4 - turns))) & 15


def movable(cell: dict) -> bool:
    return cell["kind"] not in ("empty", "blocker") and not cell.get("fixed", False)


def is_solved(level: dict, rotations: list[int] | None = None) -> bool:
    cells, width = level["cells"], level["size"]
    rotations = rotations if rotations is not None else [c["rotation"] for c in cells]
    masks = [rotate(MASKS[c["kind"]], r) for c, r in zip(cells, rotations)]
    source, target = level["source_index"], level["target_index"]
    if not masks[source] & level["source_port"]:
        return False
    seen, frontier = {source}, [source]
    while frontier:
        index = frontier.pop()
        row, column = divmod(index, width)
        for port, dr, dc, opposite in DIRECTIONS:
            nr, nc = row + dr, column + dc
            if not masks[index] & port or not (0 <= nr < width and 0 <= nc < width):
                continue
            neighbor = nr * width + nc
            if neighbor not in seen and masks[neighbor] & opposite:
                seen.add(neighbor)
                frontier.append(neighbor)
    return target in seen and bool(masks[target] & level["target_port"])


def validate_structure(level: dict) -> None:
    def require(condition: bool, message: str) -> None:
        if not condition:
            raise ValueError(message)

    width = level.get("size")
    require(type(width) is int and 2 <= width <= 6, "Tamanho de grade inválido.")
    cells = level.get("cells")
    require(isinstance(cells, list) and len(cells) == width * width, "Quantidade de células inválida.")
    require(type(level.get("id")) is int and level["id"] > 0, "ID inválido.")
    time = level.get("time_limit")
    require(type(time) in (int, float) and math.isfinite(time) and time >= 0, "Tempo inválido.")
    for index, cell in enumerate(cells):
        require(isinstance(cell, dict) and cell.get("kind") in MASKS, f"Tipo inválido na célula {index}.")
        for key in ("rotation", "solution"):
            require(type(cell.get(key)) is int and 0 <= cell[key] < 4, f"{key} inválida na célula {index}.")
        require(type(cell.get("fixed", False)) is bool, f"Trava inválida na célula {index}.")
        if cell["kind"] == "blocker":
            require(cell.get("fixed", False), f"Fusível precisa ser fixo: {index}.")
    for endpoint in ("source", "target"):
        index, port = level.get(endpoint + "_index"), level.get(endpoint + "_port")
        require(type(index) is int and 0 <= index < len(cells), f"Terminal {endpoint} inválido.")
        require(type(port) is int and port in (1, 2, 4, 8), f"Porta {endpoint} inválida.")
        row, col = divmod(index, width)
        require({1: row == 0, 2: col == width - 1, 4: row == width - 1, 8: col == 0}[port],
                f"Terminal {endpoint} não está voltado para fora da grade.")
        require(cells[index]["kind"] not in ("empty", "blocker"), f"Terminal {endpoint} bloqueado.")
    require(level["source_index"] != level["target_index"], "Terminais precisam ser distintos.")
    require(isinstance(level.get("name"), str) and bool(level["name"].strip()), "Nome ausente.")
    require(isinstance(level.get("instruction"), str) and bool(level["instruction"].strip()), "Instrução ausente.")
    require(isinstance(level.get("tip_lines"), list) and len(level["tip_lines"]) == 2
            and all(isinstance(t, str) and t.strip() for t in level["tip_lines"]), "Dicas visuais inválidas.")
    require(type(level.get("guided")) is bool, "Flag de orientação inválida.")


def find_solution(level: dict) -> dict | None:
    """Pesquisa apenas kind/rotation/fixed, terminais e grade. Retorna mínimo global."""
    cells, width = level["cells"], level["size"]
    source, target = level["source_index"], level["target_index"]

    @cache
    def orientation(index: int, incoming: int, outgoing: int = 0):
        cell = cells[index]
        if not MASKS[cell["kind"]]:
            return None
        required = incoming | outgoing
        for turns in range(4 if movable(cell) else 1):
            rotation = (cell["rotation"] + turns) % 4
            if rotate(MASKS[cell["kind"]], rotation) & required == required:
                return turns, rotation
        return None

    serial = itertools.count()
    heap = [(0, next(serial), source, level["source_port"], 1 << source, (source,), ())]
    costs, best, expanded = {}, None, 0
    while heap:
        cost, _, index, incoming, visited, path, assignments = heapq.heappop(heap)
        if best is not None and cost >= best[0]:
            break
        key = index, incoming, visited
        if key in costs and cost >= costs[key]:
            continue
        costs[key] = cost
        expanded += 1
        if index == target:
            choice = orientation(index, incoming, level["target_port"])
            if choice is not None:
                total = cost + choice[0]
                if best is None or total < best[0]:
                    best = total, path, assignments + ((index, choice[0], choice[1]),)
            continue
        row, column = divmod(index, width)
        for port, dr, dc, opposite in DIRECTIONS:
            nr, nc = row + dr, column + dc
            if port == incoming or not (0 <= nr < width and 0 <= nc < width):
                continue
            neighbor = nr * width + nc
            if visited & (1 << neighbor) or orientation(neighbor, opposite) is None:
                continue
            choice = orientation(index, incoming, port)
            if choice is None:
                continue
            heapq.heappush(heap, (cost + choice[0], next(serial), neighbor, opposite,
                                 visited | (1 << neighbor), path + (neighbor,),
                                 assignments + ((index, choice[0], choice[1]),)))
    if best is None:
        return None
    moves = [index for index, turns, _ in best[2] for _ in range(turns)]
    return {"minimum_taps": best[0], "moves": moves, "path": list(best[1]),
            "rotations": {str(i): r for i, _, r in best[2]}, "expanded_states": expanded}


def validate_reference(level: dict) -> int:
    cells, path, width = level["cells"], level.get("reference_path"), level["size"]
    if not isinstance(path, list) or not path or any(type(i) is not int or not 0 <= i < len(cells) for i in path):
        raise ValueError("Caminho de referência inválido.")
    if path[0] != level["source_index"] or path[-1] != level["target_index"] or len(set(path)) != len(path):
        raise ValueError("Referência não une os terminais ou repete células.")
    masks = [rotate(MASKS[c["kind"]], c["solution"]) for c in cells]
    for left, right in zip(path, path[1:]):
        dr, dc = right // width - left // width, right % width - left % width
        ports = next(((p, o) for p, r, c, o in DIRECTIONS if (r, c) == (dr, dc)), None)
        if ports is None or not masks[left] & ports[0] or not masks[right] & ports[1]:
            raise ValueError(f"Referência tem conexão interrompida entre {left} e {right}.")
    rotations = [c["rotation"] for c in cells]
    taps = 0
    for index in path:
        cell = cells[index]
        options = range(4) if movable(cell) else range(1)
        turns = next((t for t in options if rotate(MASKS[cell["kind"]], rotations[index] + t) == masks[index]), None)
        if turns is None:
            raise ValueError(f"Referência exige girar uma peça fixa: {index}.")
        rotations[index] = (rotations[index] + turns) % 4
        taps += turns
    if not is_solved(level, rotations) or taps != level.get("reference_taps"):
        raise ValueError("Referência não vence ou tem contagem de toques incorreta.")
    return taps


def audit_level(level: dict) -> dict:
    validate_structure(level)
    if is_solved(level):
        raise ValueError("A fase começa resolvida.")
    solution = find_solution(level)
    if solution is None:
        raise ValueError("Não existe solução jogável por rotações permitidas.")
    reference_taps = validate_reference(level)
    rotations = [c["rotation"] for c in level["cells"]]
    for position, index in enumerate(solution["moves"]):
        if not movable(level["cells"][index]):
            raise ValueError("Resolvedor tentou girar peça fixa ou vazia.")
        rotations[index] = (rotations[index] + 1) % 4
        if is_solved(level, rotations) and position != len(solution["moves"]) - 1:
            raise ValueError("A rota declarada mínima vence antes do último toque.")
    if not is_solved(level, rotations):
        raise ValueError("A sequência descoberta não fecha o circuito.")
    estimate = solution["minimum_taps"] * SECONDS_PER_TAP
    if level["time_limit"] and estimate >= level["time_limit"]:
        raise ValueError("Tempo insuficiente para o cenário simulado de dois segundos por toque.")
    return {"id": level["id"], "name": level["name"], "size": level["size"], "time_limit": level["time_limit"],
            "reference_taps": reference_taps, "simulated_seconds": estimate, **solution}


def audit_campaign(directory: Path = ROOT / "levels") -> list[dict]:
    reports = []
    for file in sorted(directory.glob("level_*.json")):
        try:
            result = audit_level(json.loads(file.read_text(encoding="utf-8")))
        except (ValueError, KeyError, TypeError) as error:
            raise ValueError(f"{file.name}: {error}") from error
        result["resource_path"] = "res://levels/" + file.name
        reports.append(result)
    if not reports or [r["id"] for r in reports] != list(range(1, len(reports) + 1)):
        raise ValueError("A campanha precisa de IDs únicos e consecutivos, começando em 1.")
    return reports


def write_markdown(reports: list[dict], path: Path) -> None:
    lines = ["# Testes de jogabilidade por fase", "",
             "Relatório gerado por `python tools/validate_levels.py`. O resolvedor procura a solução com menos toques sem consultar a referência autoral.", "",
             "| Fase | Nome | Mínimo de toques | Referência | Tempo | Cenário a 2 s/toque |", "| --- | --- | --- | --- | --- | --- |"]
    for report in reports:
        time = f"{int(report['time_limit'])} s" if report["time_limit"] else "Livre"
        lines.append(f"| {report['id']} | {report['name']} | {report['minimum_taps']} | {report['reference_taps']} | {time} | {report['simulated_seconds']:g} s |")
    lines += ["", "O cenário temporal é uma hipótese de teste, não uma garantia de facilidade para todas as pessoas. Os testes na engine executam as sequências descobertas usando cliques e toques reais de entrada; não alteram diretamente a orientação das peças.", "",
              "## Sequências descobertas", "", "Coordenadas em linha/coluna, começando em 1. Coordenadas repetidas significam toques consecutivos na mesma peça.", ""]
    for report in reports:
        width = report["size"]
        sequence = " → ".join(f"L{i // width + 1} C{i % width + 1}" for i in report["moves"])
        lines.append(f"- **Fase {report['id']}:** {sequence}.")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "builds/level-solutions.json")
    parser.add_argument("--report", type=Path, default=ROOT / "docs/TESTES_FASES.md")
    args = parser.parse_args()
    try:
        reports = audit_campaign()
    except ValueError as error:
        parser.exit(1, f"AUDITORIA FALHOU: {error}\n")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps({"seconds_per_tap": SECONDS_PER_TAP, "levels": reports}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    write_markdown(reports, args.report)
    for report in reports:
        print(f"Fase {report['id']}: jogavel; minimo {report['minimum_taps']} toques; {report['expanded_states']} estados pesquisados.")


if __name__ == "__main__":
    main()
