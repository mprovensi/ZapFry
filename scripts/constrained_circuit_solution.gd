extends RefCounted
## Busca exata com alarmes e duplas. O resolvedor positivo fornece um limite
## inferior; cada caminho que aciona um alarme precisa ser interrompido.

const Board = preload("res://scripts/circuit_board.gd")
var board: CircuitBoard
var positive: Callable
var best: Dictionary = {}
var seen: Dictionary = {}
var grouped: Dictionary = {}


func solve(model: CircuitBoard, positive_solver: Callable) -> Dictionary:
	board = model
	positive = positive_solver
	best.clear()
	seen.clear()
	grouped.clear()
	for group: Array in board.linked_groups:
		for index: int in group:
			grouped[index] = true
	var domains: Dictionary = {}
	for index in range(board.cells.size()):
		var values: Array[int] = []
		var identities: Dictionary = {}
		for turns in range(board.rotation_period(index) if board.can_rotate(index) else 1):
			var rotation := posmod(int(board.cells[index]["rotation"]) + turns, board.rotation_period(index))
			var identity := board.orientation_key(index, rotation)
			if grouped.has(index) or not identities.has(identity):
				values.append(rotation)
				identities[identity] = true
		domains[index] = values
	_enumerate_groups(0, domains, 0)
	return best


func _enumerate_groups(position: int, domains: Dictionary, cost: int) -> void:
	if not best.is_empty() and cost >= int(best["taps"]):
		return
	if position == board.linked_groups.size():
		_search(domains, cost)
		return
	var group: Array = board.linked_groups[position]
	for turns in range(4 if board.can_rotate(group[0]) else 1):
		var child := domains.duplicate()
		for index: int in group:
			child[index] = [posmod(int(board.cells[index]["rotation"]) + turns, 4)]
		_enumerate_groups(position + 1, child, cost + turns)


func _search(domains: Dictionary, group_cost: int) -> void:
	var key := ""
	for index in range(board.cells.size()):
		var mask := 0
		for rotation: int in domains[index]:
			mask |= 1 << rotation
		key += "%x" % mask
	if seen.has(key) and int(seen[key]) <= group_cost:
		return
	seen[key] = group_cost
	var data := board.snapshot()
	data["linked_groups"] = []
	data["forbidden_nodes"] = []
	var cost := group_cost
	var rotations: Dictionary = {}
	for index in range(board.cells.size()):
		var value := int(domains[index][0])
		rotations[index] = value
		data["cells"][index]["rotation"] = value
		if grouped.has(index) or domains[index].size() == 1:
			data["cells"][index]["fixed"] = true
		if not grouped.has(index):
			cost += posmod(value - int(board.cells[index]["rotation"]), board.rotation_period(index))
	if not best.is_empty() and cost >= int(best["taps"]):
		return
	var working := Board.new()
	working.load_level(data)
	var plan: Dictionary = positive.call(working, domains)
	if plan.is_empty():
		return
	cost += int(plan["taps"])
	if not best.is_empty() and cost >= int(best["taps"]):
		return
	rotations.merge(plan["rotations"], true)
	var powered := board.energized_for(rotations)
	if board.objectives_met(powered, rotations):
		best = {"taps": cost, "path": board.action_indices(), "rotations": rotations}
		return
	for alarm: int in board.forbidden_nodes:
		if not powered.has(alarm):
			continue
		# Toda solução com o alarme desligado muda ao menos uma orientação
		# neste caminho. Peças fora do caminho OUT também entram na busca.
		for index: int in board.energy_path_to(alarm, rotations):
			if grouped.has(index) or not board.can_rotate(index):
				continue
			var alternatives: Array[int] = []
			for value: int in domains[index]:
				if board.orientation_key(index, value) != board.orientation_key(index, rotations[index]):
					alternatives.append(value)
			if not alternatives.is_empty():
				var child := domains.duplicate()
				child[index] = alternatives
				_search(child, group_cost)
		return
