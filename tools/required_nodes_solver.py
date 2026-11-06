"""Busca exata de rede: liga cada objetivo a uma árvore já ligada à fonte.

Enumera todas as orientações compatíveis (inclusive a terceira porta dos T).
Distâncias relaxadas ignoram repetições de células e fornecem apenas limites
inferiores; só a propagação completa aceita uma solução. Não lê a referência.
"""
from functools import cache
import heapq


def solve_required(level, classic, directions, movable, is_solved, ports):
    cells, width = level["cells"], level["size"]
    source, target = level["source_index"], level["target_index"]
    goals = [target, *level["required_nodes"]]
    best = None
    expanded = 0

    @cache
    def options(index, incoming, outgoing):
        cell = cells[index]
        found = {}
        for turns in range(4 if movable(cell) else 1):
            rotation = (cell["rotation"] + turns) % 4
            entry, exit = ports(cell, rotation)
            if (entry | exit) and entry & incoming == incoming and exit & outgoing == outgoing and (entry, exit) not in found:
                found[entry, exit] = (turns, rotation)
        return tuple(found.values())

    neighbors = {}
    reverse = {}
    for index in range(len(cells)):
        row, col = divmod(index, width)
        neighbors[index] = [(p, (row + dr) * width + col + dc, opposite)
                            for p, dr, dc, opposite in directions
                            if 0 <= row + dr < width and 0 <= col + dc < width]
        for incoming in (0, 1, 2, 4, 8):
            for port, neighbor, opposite in neighbors[index]:
                choices = options(index, port, incoming) if port != incoming else ()
                if choices:
                    reverse.setdefault((neighbor, opposite), []).append(
                        ((index, incoming), min(c for c, _ in choices)))

    def record(network, cost):
        nonlocal best
        rotations = [network.get(i, c["rotation"]) for i, c in enumerate(cells)]
        if is_solved(level, rotations) and (best is None or cost < best[0]):
            best = cost, network.copy()
            return True
        return False

    def complete(network, cost):
        nonlocal expanded
        expanded += 1
        if best is not None and cost >= best[0]:
            return
        if record(network, cost):
            return
        goal = next((g for g in goals if g not in network), None)
        if goal is None:
            return
        # Dijkstra inverso: a rede é destino fixo, nunca um atalho alterável.
        distance, heap = {}, []
        for index, rotation in network.items():
            mask = ports(cells[index], rotation)[1]
            for port in (1, 2, 4, 8):
                if mask & port:
                    distance[index, port] = 0
                    heapq.heappush(heap, (0, index, port))
        while heap:
            value, index, incoming = heapq.heappop(heap)
            if distance[index, incoming] != value:
                continue
            for state, weight in reverse.get((index, incoming), ()):
                if state[0] in network:
                    continue
                total = value + weight
                if total < distance.get(state, float("inf")):
                    distance[state] = total
                    heapq.heappush(heap, (total, *state))

        def attach(index, incoming, path, visited, current_cost):
            bound = distance.get((index, incoming), float("inf"))
            if bound == float("inf") or best is not None and current_cost + bound >= best[0]:
                return
            if index in network:
                joined = {**network, **path}
                complete(joined, current_cost)
                return
            candidates = []
            for port, neighbor, opposite in neighbors[index]:
                if port == incoming or visited & (1 << neighbor):
                    continue
                for turns, rotation in options(index, port, incoming):
                    candidates.append((turns + distance.get((neighbor, opposite), float("inf")),
                                       turns, rotation, neighbor, opposite))
            for _, turns, rotation, neighbor, opposite in sorted(candidates):
                path[index] = rotation
                attach(neighbor, opposite, path, visited | (1 << index), current_cost + turns)
            path.pop(index, None)

        attach(goal, level["target_port"] if goal == target else 0, {}, 0, cost)

    if classic:
        seed = {int(i): r for i, r in classic["rotations"].items()}
        complete(seed, classic["minimum_taps"])
        # Uma solução válida que atinge o mínimo até OUT já é ótima globalmente.
        if best is not None and best[0] == classic["minimum_taps"]:
            return {**classic, "path": list(best[1]), "rotations": {str(i): r for i, r in best[1].items()}}
    for turns, rotation in options(source, level["source_port"], 0):
        complete({source: rotation}, turns)
    if best is None:
        return None
    moves = [i for i, r in best[1].items() for _ in range((r - cells[i]["rotation"]) % 4)]
    return {"minimum_taps": best[0], "moves": moves, "path": list(best[1]),
            "rotations": {str(i): r for i, r in best[1].items()}, "expanded_states": expanded}
