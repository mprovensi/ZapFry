"""Valida fases e procura a solução com menos toques, sem ler a solução autoral.

Cada vitória contém um caminho simples entre os terminais. O Dijkstra explora
caminhos sem repetir células e escolhe, em cada peça, a rotação mais barata que
aceita a entrada e a saída. Portas extras do T são permitidas. Isso dispensa
enumerar todas as orientações do tabuleiro e mantém o auditor independente do
resolvedor em GDScript. Somente a validação da referência lê solution/path.
"""

import argparse
import copy
from functools import cache
import heapq
import itertools
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MASKS = {"straight": 5, "diode": 5, "switch": 3, "curve": 3, "tee": 11, "empty": 0, "blocker": 0}
# Porta, variação de linha, variação de coluna, porta oposta.
DIRECTIONS = ((1, -1, 0, 4), (2, 0, 1, 8), (4, 1, 0, 1), (8, 0, -1, 2))
SECONDS_PER_TAP = 2.0  # Hipótese de teste; não é uma medição de jogador humano.


def rotate(mask: int, turns: int) -> int:
    turns %= 4
    return ((mask << turns) | (mask >> (4 - turns))) & 15


def movable(cell: dict) -> bool:
    return cell["kind"] not in ("empty", "blocker") and not cell.get("fixed", False)


def ports(cell: dict, rotation: int) -> tuple[int, int]:
    if cell["kind"] == "switch":
        mask = cell["switch_masks"][rotation % 2]
        return mask, mask
    if cell["kind"] == "diode":
        outgoing = 1 << (rotation % 4)
        return ((outgoing << 2) | (outgoing >> 2)) & 15, outgoing
    mask = rotate(MASKS[cell["kind"]], rotation)
    return mask, mask


def action_period(level: dict, index: int) -> int:
    return 2 if level["cells"][index]["kind"] == "switch" else 4


def action_members(level: dict, index: int) -> list[int]:
    return next((group for group in level.get("linked_groups", []) if index in group), [index])


def action_indices(level: dict) -> list[int]:
    return [i for i, cell in enumerate(level["cells"]) if movable(cell)
            and action_members(level, i)[0] == i
            and all(movable(level["cells"][j]) for j in action_members(level, i))]


def apply_action(level: dict, rotations: list[int], index: int) -> None:
    for member in action_members(level, index):
        rotations[member] = (rotations[member] + 1) % action_period(level, member)


def required_ports(level: dict) -> dict[int, int]:
    return {item["index"]: item["port"] for item in level.get("required_outputs", [])}


def required_goals(level: dict) -> list[int]:
    return [*level.get("required_nodes", []), *required_ports(level)]


def energy_parents(level: dict, rotations: list[int] | None = None) -> dict[int, int]:
    cells, width = level["cells"], level["size"]
    rotations = rotations if rotations is not None else [c["rotation"] for c in cells]
    connections = [ports(c, r) for c, r in zip(cells, rotations)]
    source, target = level["source_index"], level["target_index"]
    if not connections[source][0] & level["source_port"]:
        return {}
    seen, frontier = {source: -1}, [source]
    while frontier:
        index = frontier.pop()
        row, column = divmod(index, width)
        for port, dr, dc, opposite in DIRECTIONS:
            nr, nc = row + dr, column + dc
            if not connections[index][1] & port or not (0 <= nr < width and 0 <= nc < width):
                continue
            neighbor = nr * width + nc
            if neighbor not in seen and connections[neighbor][0] & opposite:
                seen[neighbor] = index
                frontier.append(neighbor)
    return seen


def positive_solved(level: dict, rotations: list[int] | None = None) -> bool:
    cells = level["cells"]
    rotations = rotations if rotations is not None else [c["rotation"] for c in cells]
    seen = energy_parents(level, rotations)
    target = level["target_index"]
    return (target in seen and bool(ports(cells[target], rotations[target])[1] & level["target_port"])
            and all(i in seen for i in required_goals(level))
            and all(ports(cells[i], rotations[i])[1] & port for i, port in required_ports(level).items()))


def is_solved(level: dict, rotations: list[int] | None = None) -> bool:
    return positive_solved(level, rotations) and not any(i in energy_parents(level, rotations)
                                                       for i in level.get("forbidden_nodes", []))


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
            require(type(cell.get(key)) is int and 0 <= cell[key] < action_period(level, index), f"{key} inválida na célula {index}.")
        require(type(cell.get("fixed", False)) is bool, f"Trava inválida na célula {index}.")
        if cell["kind"] == "blocker":
            require(cell.get("fixed", False), f"Fusível precisa ser fixo: {index}.")
        if cell["kind"] == "switch":
            switches = cell.get("switch_masks")
            require(isinstance(switches, list) and len(switches) == 2 and all(type(m) is int and m in (3, 5, 6, 9, 10, 12) for m in switches), "Contatos de interruptor inválidos.")
            require(switches[0] != switches[1] and bool(switches[0] & switches[1]), "Interruptor precisa de duas conexões distintas com contato comum.")
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
    nodes = level.get("required_nodes", [])
    require(isinstance(nodes, list), "Objetivos precisam ser uma lista.")
    require(all(type(i) is int and 0 <= i < len(cells) for i in nodes), "Índice de objetivo inválido.")
    require(len(set(nodes)) == len(nodes), "Objetivos duplicados.")
    require(all(i not in (level["source_index"], level["target_index"])
                and cells[i]["kind"] not in ("empty", "blocker") for i in nodes), "Objetivo bloqueado ou redundante.")
    outputs = level.get("required_outputs", [])
    require(isinstance(outputs, list), "Equipamentos precisam ser uma lista.")
    positive_nodes = set(nodes)
    for output in outputs:
        require(isinstance(output, dict), "Equipamento inválido.")
        index, port = output.get("index"), output.get("port")
        require(type(index) is int and 0 <= index < len(cells) and index not in positive_nodes
                and index not in (level["source_index"], level["target_index"])
                and cells[index]["kind"] not in ("empty", "blocker"), "Índice de equipamento inválido.")
        require(type(port) is int and port in (1, 2, 4, 8), "Porta de equipamento inválida.")
        row, col = divmod(index, width)
        require({1: row == 0, 2: col == width - 1, 4: row == width - 1, 8: col == 0}[port], "Equipamento precisa de porta externa.")
        positive_nodes.add(index)
    alarms = level.get("forbidden_nodes", [])
    require(isinstance(alarms, list) and all(type(i) is int and 0 <= i < len(cells) for i in alarms), "Índice de alarme inválido.")
    require(len(set(alarms)) == len(alarms) and all(i not in positive_nodes and i not in (level["source_index"], level["target_index"])
            and cells[i]["kind"] not in ("empty", "blocker") for i in alarms), "Alarme duplicado, bloqueado ou incompatível.")
    groups = level.get("linked_groups", [])
    require(isinstance(groups, list), "Duplas precisam ser uma lista.")
    grouped = set()
    for group in groups:
        require(isinstance(group, list) and len(group) == 2 and all(type(i) is int and 0 <= i < len(cells) for i in group), "Dupla inválida.")
        require(len(set(group)) == 2 and not grouped.intersection(group) and all(movable(cells[i]) and cells[i]["kind"] != "switch" for i in group), "Dupla sobreposta, fixa ou incompatível.")
        grouped.update(group)
    require(type(level.get("rules_revision", 1)) is int and level.get("rules_revision", 1) >= 1,
            "Revisão das regras inválida.")


def find_solution(level: dict) -> dict | None:
    """Pesquisa apenas kind/rotation/fixed, terminais e grade. Retorna mínimo global."""
    if level.get("forbidden_nodes") or level.get("linked_groups"):
        return _find_constrained(level)
    return _find_positive(level)


def _find_positive(level: dict, allowed: dict | None = None) -> dict | None:
    classic = _find_path(level, allowed)
    if not required_goals(level) or classic is None:
        return classic
    try:
        from .required_nodes_solver import solve_required
    except ImportError:
        from required_nodes_solver import solve_required
    return solve_required(level, classic, DIRECTIONS, movable, positive_solved, ports, allowed or {})


def _find_path(level: dict, allowed: dict | None = None) -> dict | None:
    cells, width = level["cells"], level["size"]
    source, target = level["source_index"], level["target_index"]

    @cache
    def orientation(index: int, incoming: int, outgoing: int = 0):
        cell = cells[index]
        if not MASKS[cell["kind"]]:
            return None
        for turns in range(action_period(level, index) if movable(cell) else 1):
            rotation = (cell["rotation"] + turns) % action_period(level, index)
            if allowed is not None and rotation not in allowed[index]:
                continue
            entry, exit = ports(cell, rotation)
            required = outgoing | required_ports(level).get(index, 0)
            if entry & incoming == incoming and exit & required == required:
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


def _find_constrained(level: dict) -> dict | None:
    cells = level["cells"]
    groups = level.get("linked_groups", [])
    grouped = {i for group in groups for i in group}
    domains = {}
    for i, cell in enumerate(cells):
        identities, values = set(), []
        for turns in range(action_period(level, i) if movable(cell) else 1):
            rotation = (cell["rotation"] + turns) % action_period(level, i)
            identity = ports(cell, rotation)
            if i in grouped or identity not in identities:
                identities.add(identity)
                values.append(rotation)
        domains[i] = tuple(values)
    serial, heap, seen = itertools.count(), [], set()

    def enqueue(choices, group_cost):
        key = tuple(choices[i] for i in range(len(cells)))
        if key in seen:
            return
        seen.add(key)
        work = copy.deepcopy(level)
        work["linked_groups"], work["forbidden_nodes"] = [], []
        baseline, cost = [], group_cost
        for i, cell in enumerate(work["cells"]):
            cell["rotation"] = choices[i][0]
            baseline.append(cell["rotation"])
            if i in grouped or len(choices[i]) == 1:
                cell["fixed"] = True
            if i not in grouped:
                cost += (cell["rotation"] - cells[i]["rotation"]) % action_period(level, i)
        plan = _find_positive(work, choices)
        if plan is None:
            return
        for i, r in plan["rotations"].items():
            baseline[int(i)] = r
        heapq.heappush(heap, (cost + plan["minimum_taps"], next(serial), choices, group_cost, baseline))

    group_choices = [range(4) if all(movable(cells[i]) for i in group) else (0,) for group in groups]
    for turns in itertools.product(*group_choices):
        choices = domains.copy()
        for group, count in zip(groups, turns):
            for i in group:
                choices[i] = ((cells[i]["rotation"] + count) % 4,)
        enqueue(choices, sum(turns))
    expanded = 0
    while heap:
        cost, _, choices, group_cost, rotations = heapq.heappop(heap)
        expanded += 1
        if is_solved(level, rotations):
            moves = []
            for i in action_indices(level):
                count = next(t for t in range(action_period(level, i))
                             if all(ports(cells[j], cells[j]["rotation"] + t) == ports(cells[j], rotations[j])
                                    for j in action_members(level, i)))
                moves.extend([i] * count)
            return {"minimum_taps": cost, "moves": moves, "path": action_indices(level),
                    "rotations": {str(i): r for i, r in enumerate(rotations)}, "expanded_states": expanded}
        parents = energy_parents(level, rotations)
        alarm = next(i for i in level.get("forbidden_nodes", []) if i in parents)
        while alarm >= 0:
            if alarm not in grouped and movable(cells[alarm]):
                remaining = tuple(r for r in choices[alarm] if ports(cells[alarm], r) != ports(cells[alarm], rotations[alarm]))
                if remaining:
                    child = choices.copy()
                    child[alarm] = remaining
                    enqueue(child, group_cost)
            alarm = parents[alarm]
    return None


def validate_reference(level: dict) -> int:
    cells, path, width = level["cells"], level.get("reference_path"), level["size"]
    if not isinstance(path, list) or not path or any(type(i) is not int or not 0 <= i < len(cells) for i in path):
        raise ValueError("Caminho de referência inválido.")
    if path[0] != level["source_index"] or path[-1] != level["target_index"] or len(set(path)) != len(path):
        raise ValueError("Referência não une os terminais ou repete células.")
    connections = [ports(c, c["solution"]) for c in cells]
    for left, right in zip(path, path[1:]):
        dr, dc = right // width - left // width, right % width - left % width
        edge = next(((p, o) for p, r, c, o in DIRECTIONS if (r, c) == (dr, dc)), None)
        if edge is None or not connections[left][1] & edge[0] or not connections[right][0] & edge[1]:
            raise ValueError(f"Referência tem conexão interrompida entre {left} e {right}.")
    rotations = [c["rotation"] for c in cells]
    taps = 0
    # Uma referência com ramificações também orienta peças fora do caminho OUT.
    for index in action_indices(level):
        cell = cells[index]
        options = range(action_period(level, index))
        turns = next((t for t in options if all(ports(cells[j], rotations[j] + t) == connections[j]
                                               for j in action_members(level, index))), None)
        if turns is None:
            raise ValueError(f"Referência exige girar uma peça fixa: {index}.")
        for _ in range(turns):
            apply_action(level, rotations, index)
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
        if not movable(level["cells"][index]) or not all(movable(level["cells"][j]) for j in action_members(level, index)):
            raise ValueError("Resolvedor tentou girar peça fixa ou vazia.")
        apply_action(level, rotations, index)
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
