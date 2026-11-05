extends RefCounted
## Dijkstra no tabuleiro atual. Não consulta solution nem reference_path.

const Board = preload("res://scripts/circuit_board.gd")
const RequiredSolution = preload("res://scripts/required_circuit_solution.gd")
var board: CircuitBoard
var choices: Dictionary = {}
var heap: Array = []
var serial := 0


func solve(model: CircuitBoard) -> Dictionary:
	if not model.objectives_valid:
		return {}
	var classic := _solve_path(model)
	if model.required_nodes.is_empty() or classic.is_empty():
		return classic
	# O mínimo até OUT é um limite inferior para qualquer rede completa.
	var rotations: Dictionary = classic["rotations"]
	if model.objectives_met(model.energized_for(rotations), rotations):
		return classic
	return RequiredSolution.new().solve(model, classic)


func _solve_path(model: CircuitBoard) -> Dictionary:
	board = model
	choices.clear()
	heap.clear()
	serial = 0
	_push([0, serial, board.source_index, board.source_port, 1 << board.source_index, [board.source_index], {}])
	var seen: Dictionary = {}
	var best: Dictionary = {}
	while not heap.is_empty():
		var entry := _pop()
		var cost: int = entry[0]
		if not best.is_empty() and cost >= int(best["taps"]):
			break
		var index: int = entry[2]
		var incoming: int = entry[3]
		var visited: int = entry[4]
		# Até 36 células: máscara e estado cabem em um inteiro de 64 bits.
		var key := (visited << 10) | (index << 4) | incoming
		if seen.has(key) and int(seen[key]) <= cost:
			continue
		seen[key] = cost
		if index == board.target_index:
			var final := _orientation(index, incoming, board.target_port)
			if final.x >= 0 and (best.is_empty() or cost + final.x < int(best["taps"])):
				var rotations: Dictionary = entry[6].duplicate()
				rotations[index] = final.y
				best = {"taps": cost + final.x, "path": entry[5], "rotations": rotations}
			continue
		var position := Vector2i(index % board.width, index / board.width)
		for direction in range(4):
			var port: int = Board.PORTS[direction]
			var next_position: Vector2i = position + Board.OFFSETS[direction]
			if port == incoming or next_position.x < 0 or next_position.y < 0 or next_position.x >= board.width or next_position.y >= board.width:
				continue
			var neighbor := next_position.y * board.width + next_position.x
			if visited & (1 << neighbor) or _orientation(neighbor, Board.OPPOSITES[direction], 0).x < 0:
				continue
			var choice := _orientation(index, incoming, port)
			if choice.x < 0:
				continue
			var path: Array = entry[5].duplicate()
			path.append(neighbor)
			var rotations: Dictionary = entry[6].duplicate()
			rotations[index] = choice.y
			serial += 1
			_push([cost + choice.x, serial, neighbor, Board.OPPOSITES[direction], visited | (1 << neighbor), path, rotations])
	return best


func _orientation(index: int, incoming: int, outgoing: int) -> Vector2i:
	var key := (index << 8) | (incoming << 4) | outgoing
	if choices.has(key):
		return choices[key]
	var cell: Dictionary = board.cells[index]
	var base: int = Board.BASE_MASKS[cell["kind"]]
	var result := Vector2i(-1, -1)
	if base != 0:
		for turns in range(4 if board.can_rotate(index) else 1):
			var rotation := (int(cell["rotation"]) + turns) % 4
			if Board.rotate_mask(base, rotation) & (incoming | outgoing) == (incoming | outgoing):
				result = Vector2i(turns, rotation)
				break
	choices[key] = result
	return result


func _less(left: Array, right: Array) -> bool:
	return left[0] < right[0] or (left[0] == right[0] and left[1] < right[1])


func _push(entry: Array) -> void:
	heap.append(entry)
	var index := heap.size() - 1
	while index > 0:
		var parent: int = (index - 1) / 2
		if not _less(heap[index], heap[parent]):
			break
		var swap: Array = heap[parent]
		heap[parent] = heap[index]
		heap[index] = swap
		index = parent


func _pop() -> Array:
	var result: Array = heap[0]
	var last: Array = heap.pop_back()
	if heap.is_empty():
		return result
	heap[0] = last
	var index := 0
	while index * 2 + 1 < heap.size():
		var child := index * 2 + 1
		if child + 1 < heap.size() and _less(heap[child + 1], heap[child]):
			child += 1
		if not _less(heap[child], heap[index]):
			break
		var swap: Array = heap[index]
		heap[index] = heap[child]
		heap[child] = swap
		index = child
	return result
