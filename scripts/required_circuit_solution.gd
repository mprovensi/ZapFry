extends RefCounted
## Rede mínima para fonte, OUT e lâmpadas. Cada ramo une um objetivo à rede
## já fixada; todas as orientações compatíveis do T são consideradas.

const Board = preload("res://scripts/circuit_board.gd")
const UNREACHABLE := 1000000
var board: CircuitBoard
var options: Dictionary = {}
var neighbors: Array = []
var reverse: Dictionary = {}
var best: Dictionary = {}
var goals: Array = []


func solve(model: CircuitBoard, classic: Dictionary) -> Dictionary:
	board = model
	options.clear()
	neighbors.clear()
	reverse.clear()
	best.clear()
	goals = [board.target_index]
	goals.append_array(board.required_nodes)
	_build_graph()
	if not classic.is_empty():
		_complete(classic["rotations"], int(classic["taps"]))
		if not best.is_empty() and best["taps"] == classic["taps"]:
			return best
	for choice: Vector2i in _options(board.source_index, board.source_port, 0):
		_complete({board.source_index: choice.y}, choice.x)
	return best


func _options(index: int, incoming: int, outgoing: int) -> Array:
	var key := (index << 8) | (incoming << 4) | outgoing
	if options.has(key):
		return options[key]
	var found: Dictionary = {}
	var cell: Dictionary = board.cells[index]
	for turns in range(4 if board.can_rotate(index) else 1):
		var rotation := (int(cell["rotation"]) + turns) % 4
		var identity := board.orientation_key(index, rotation)
		if board.accepts_rotation(index, rotation, incoming, outgoing) and not found.has(identity):
			found[identity] = Vector2i(turns, rotation)
	options[key] = found.values()
	return options[key]


func _build_graph() -> void:
	for index in range(board.cells.size()):
		var adjacent: Array = []
		var position := Vector2i(index % board.width, index / board.width)
		for direction in range(4):
			var point: Vector2i = position + Board.OFFSETS[direction]
			if point.x >= 0 and point.y >= 0 and point.x < board.width and point.y < board.width:
				adjacent.append([Board.PORTS[direction], point.y * board.width + point.x, Board.OPPOSITES[direction]])
		neighbors.append(adjacent)
		for incoming in [0, 1, 2, 4, 8]:
			for edge: Array in adjacent:
				if edge[0] == incoming:
					continue
				# A busca vai do objetivo à fonte: edge aponta à entrada,
				# e o estado incoming guarda a saída em direção ao objetivo.
				var choices := _options(index, int(edge[0]), incoming)
				if choices.is_empty():
					continue
				var destination := (int(edge[1]) << 4) | int(edge[2])
				if not reverse.has(destination):
					reverse[destination] = []
				# Opções estão ordenadas pelo custo crescente de giro.
				reverse[destination].append([(index << 4) | incoming, choices[0].x])


func _complete(network: Dictionary, cost: int) -> void:
	if not best.is_empty() and cost >= int(best["taps"]):
		return
	if board.objectives_met(board.energized_for(network), network):
		best = {"taps": cost, "path": network.keys(), "rotations": network.duplicate()}
		return
	var goal := -1
	for index: int in goals:
		if not network.has(index):
			goal = index
			break
	if goal < 0:
		return
	var distances := _distances(network)
	_attach(goal, board.target_port if goal == board.target_index else 0, {}, 0, cost, network, distances)


func _distances(network: Dictionary) -> Dictionary:
	# Menor custo relaxado até a rede: ignora visitas repetidas, nunca aumenta
	# o custo real. Peças da rede são destinos imutáveis, não atalhos giráveis.
	var distances: Dictionary = {}
	var queue: Array[int] = []
	for index: int in network:
		var mask := board.ports_at(index, network).y
		for port: int in Board.PORTS:
			if mask & port:
				var key := (index << 4) | port
				distances[key] = 0
				queue.append(key)
	var cursor := 0
	while cursor < queue.size():
		var key := queue[cursor]
		cursor += 1
		for edge: Array in reverse.get(key, []):
			var previous: int = edge[0]
			if network.has(previous >> 4):
				continue
			var total := int(distances[key]) + int(edge[1])
			if total < int(distances.get(previous, UNREACHABLE)):
				distances[previous] = total
				queue.append(previous)
	return distances


func _attach(index: int, incoming: int, path: Dictionary, visited: int, cost: int, network: Dictionary, distances: Dictionary) -> void:
	var bound := int(distances.get((index << 4) | incoming, UNREACHABLE))
	if bound == UNREACHABLE or (not best.is_empty() and cost + bound >= int(best["taps"])):
		return
	if network.has(index):
		var joined := network.duplicate()
		joined.merge(path)
		_complete(joined, cost)
		return
	var candidates: Array = []
	for edge: Array in neighbors[index]:
		var port: int = edge[0]
		var neighbor: int = edge[1]
		var opposite: int = edge[2]
		if port == incoming or visited & (1 << neighbor):
			continue
		for choice: Vector2i in _options(index, port, incoming):
			var estimate := choice.x + int(distances.get((neighbor << 4) | opposite, UNREACHABLE))
			candidates.append([estimate, choice.x, choice.y, neighbor, opposite])
	candidates.sort_custom(func(a: Array, b: Array): return a[0] < b[0])
	for candidate: Array in candidates:
		path[index] = candidate[2]
		_attach(candidate[3], candidate[4], path, visited | (1 << index), cost + int(candidate[1]), network, distances)
	path.erase(index)
