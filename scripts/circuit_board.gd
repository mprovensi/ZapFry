class_name CircuitBoard
extends RefCounted
## Modelo puro. A energia percorre somente portas recíprocas, nunca diagonais.

const NORTH := 1
const EAST := 2
const SOUTH := 4
const WEST := 8
const PORTS := [NORTH, EAST, SOUTH, WEST]
const OFFSETS := [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const OPPOSITES := [SOUTH, WEST, NORTH, EAST]
const BASE_MASKS := {"straight": NORTH | SOUTH, "diode": NORTH | SOUTH, "curve": NORTH | EAST,
	"tee": NORTH | EAST | WEST, "blocker": 0, "empty": 0}

var width: int
var cells: Array = []
var source_index: int
var source_port: int
var target_index: int
var target_port: int
var energized: Dictionary = {}
var solved := false
var revision := 0
var required_nodes: Array[int] = []
var objectives_valid := true


func load_level(data: Dictionary) -> void:
	width = int(data["size"])
	cells = data["cells"].duplicate(true)
	source_index = int(data["source_index"])
	source_port = int(data["source_port"])
	target_index = int(data["target_index"])
	target_port = int(data["target_port"])
	required_nodes.clear()
	objectives_valid = data.get("required_nodes", []) is Array
	if objectives_valid:
		for value in data.get("required_nodes", []):
			# JSON da engine representa números inteiros como float.
			if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)) or float(value) != floor(float(value)):
				objectives_valid = false
				break
			var index := int(value)
			if index < 0 or index >= cells.size() or index in [source_index, target_index] or required_nodes.has(index) or cells[index]["kind"] in ["empty", "blocker"]:
				objectives_valid = false
				break
			required_nodes.append(index)
	recompute()


static func rotate_mask(mask: int, turns: int) -> int:
	var result := mask
	for step in range(posmod(turns, 4)):
		result = ((result << 1) & 15) | ((result >> 3) & 1)
	return result


func mask_at(index: int, rotations: Dictionary = {}) -> int:
	var cell: Dictionary = cells[index]
	return rotate_mask(int(BASE_MASKS[cell["kind"]]), int(rotations.get(index, cell["rotation"])))


func ports_for_rotation(index: int, rotation: int) -> Vector2i:
	# x: portas de entrada; y: portas de saída. A seta base aponta ao norte.
	if cells[index]["kind"] == "diode":
		return Vector2i(rotate_mask(SOUTH, rotation), rotate_mask(NORTH, rotation))
	var mask := rotate_mask(BASE_MASKS[cells[index]["kind"]], rotation)
	return Vector2i(mask, mask)


func ports_at(index: int, rotations: Dictionary = {}) -> Vector2i:
	return ports_for_rotation(index, int(rotations.get(index, cells[index]["rotation"])))


func orientation_key(index: int, rotation: int) -> int:
	var ports := ports_for_rotation(index, rotation)
	return (ports.x << 4) | ports.y


func matches_rotation(index: int, rotation: int) -> bool:
	return orientation_key(index, int(cells[index]["rotation"])) == orientation_key(index, rotation)


func accepts_rotation(index: int, rotation: int, incoming: int, outgoing: int) -> bool:
	var ports := ports_for_rotation(index, rotation)
	return ports.x & incoming == incoming and ports.y & outgoing == outgoing and (ports.x | ports.y) != 0


func can_rotate(index: int) -> bool:
	return index >= 0 and index < cells.size() and not bool(cells[index].get("fixed", false)) \
		and cells[index]["kind"] not in ["blocker", "empty"]


func rotate_cell(index: int) -> bool:
	if not can_rotate(index):
		return false
	cells[index]["rotation"] = (int(cells[index]["rotation"]) + 1) % 4
	recompute()
	return true


func recompute() -> void:
	revision += 1
	energized = energized_for()
	solved = objectives_met(energized)


func objectives_met(powered: Dictionary, rotations: Dictionary = {}) -> bool:
	if not objectives_valid or not powered.has(target_index) or (ports_at(target_index, rotations).y & target_port) == 0:
		return false
	for index in required_nodes:
		if not powered.has(index):
			return false
	return true


func target_connected() -> bool:
	return energized.has(target_index) and (ports_at(target_index).y & target_port) != 0


func lit_required_count() -> int:
	var count := 0
	for index in required_nodes:
		if energized.has(index):
			count += 1
	return count


func direction_blocked(index: int) -> bool:
	if cells[index]["kind"] != "diode" or energized.has(index):
		return false
	var input := ports_at(index).x
	if index == source_index and (input & source_port) == 0 and mask_at(index) & source_port:
		return true
	var position := Vector2i(index % width, index / width)
	for direction in range(4):
		var port: int = PORTS[direction]
		if not (mask_at(index) & port) or input & port:
			continue
		var point: Vector2i = position + OFFSETS[direction]
		if point.x < 0 or point.y < 0 or point.x >= width or point.y >= width:
			continue
		var neighbor := point.y * width + point.x
		if energized.has(neighbor) and ports_at(neighbor).y & OPPOSITES[direction]:
			return true
	return false


func energized_for(rotations: Dictionary = {}) -> Dictionary:
	var powered: Dictionary = {}
	if cells.is_empty() or (ports_at(source_index, rotations).x & source_port) == 0:
		return powered
	var frontier: Array[int] = [source_index]
	powered[source_index] = true
	var cursor := 0
	while cursor < frontier.size():
		var index := frontier[cursor]
		cursor += 1
		var position := Vector2i(index % width, index / width)
		var mask := ports_at(index, rotations).y
		for direction in range(4):
			if (mask & int(PORTS[direction])) == 0:
				continue
			var neighbor: Vector2i = position + OFFSETS[direction]
			if neighbor.x < 0 or neighbor.x >= width or neighbor.y < 0 or neighbor.y >= width:
				continue
			var next := neighbor.y * width + neighbor.x
			if powered.has(next) or (ports_at(next, rotations).x & int(OPPOSITES[direction])) == 0:
				continue
			powered[next] = true
			frontier.append(next)
	return powered
