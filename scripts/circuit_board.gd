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
const BASE_MASKS := {"straight": NORTH | SOUTH, "diode": NORTH | SOUTH, "switch": NORTH | EAST, "curve": NORTH | EAST,
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
var forbidden_nodes: Array[int] = []
var required_ports: Dictionary = {}
var linked_groups: Array = []
var _linked: Dictionary = {}
var _data: Dictionary = {}


func load_level(data: Dictionary) -> void:
	_data = data.duplicate(true)
	width = int(data["size"])
	cells = data["cells"].duplicate(true)
	source_index = int(data["source_index"])
	source_port = int(data["source_port"])
	target_index = int(data["target_index"])
	target_port = int(data["target_port"])
	objectives_valid = _load_challenges(data)
	recompute()


static func _integer(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and float(value) == floor(float(value))


func _goal_index(value: Variant) -> bool:
	return _integer(value) and int(value) >= 0 and int(value) < cells.size() and int(value) not in [source_index, target_index] and cells[int(value)]["kind"] not in ["empty", "blocker"]


func _load_challenges(data: Dictionary) -> bool:
	required_nodes.clear()
	forbidden_nodes.clear()
	required_ports.clear()
	linked_groups.clear()
	_linked.clear()
	for index in range(cells.size()):
		var cell: Variant = cells[index]
		if not cell is Dictionary or not BASE_MASKS.has(cell.get("kind")) or not _integer(cell.get("rotation")):
			return false
		if int(cell["rotation"]) < 0 or int(cell["rotation"]) >= rotation_period(index):
			return false
		if cell["kind"] == "switch":
			var masks: Variant = cell.get("switch_masks")
			if not masks is Array or masks.size() != 2:
				return false
			for mask in masks:
				if not _integer(mask) or int(mask) not in [3, 5, 6, 9, 10, 12]:
					return false
			if masks[0] == masks[1] or (int(masks[0]) & int(masks[1])) == 0:
				return false
	for field in ["required_nodes", "required_outputs", "forbidden_nodes", "linked_groups"]:
		if not data.get(field, []) is Array:
			return false
	for value in data.get("required_nodes", []):
		if not _goal_index(value) or required_nodes.has(int(value)):
			return false
		required_nodes.append(int(value))
	for output in data.get("required_outputs", []):
		if not output is Dictionary or not _goal_index(output.get("index")):
			return false
		var index := int(output["index"])
		var port: Variant = output.get("port")
		if required_nodes.has(index) or not _integer(port) or int(port) not in PORTS:
			return false
		var outward := (int(port) == NORTH and index < width) or (int(port) == SOUTH and index >= cells.size() - width) or (int(port) == WEST and index % width == 0) or (int(port) == EAST and index % width == width - 1)
		if not outward:
			return false
		required_nodes.append(index)
		required_ports[index] = int(port)
	for value in data.get("forbidden_nodes", []):
		if not _goal_index(value) or forbidden_nodes.has(int(value)) or required_nodes.has(int(value)):
			return false
		forbidden_nodes.append(int(value))
	for group in data.get("linked_groups", []):
		if not group is Array or group.size() != 2:
			return false
		var members: Array[int] = []
		for value in group:
			if not _integer(value) or int(value) < 0 or int(value) >= cells.size() or _linked.has(int(value)) or members.has(int(value)):
				return false
			var index := int(value)
			if cells[index]["kind"] in ["empty", "blocker", "switch"] or bool(cells[index].get("fixed", false)):
				return false
			members.append(index)
		for index in members:
			_linked[index] = members
		linked_groups.append(members)
	return true


func snapshot() -> Dictionary:
	var result := _data.duplicate(true)
	result["cells"] = cells.duplicate(true)
	return result


static func rotate_mask(mask: int, turns: int) -> int:
	var result := mask
	for step in range(posmod(turns, 4)):
		result = ((result << 1) & 15) | ((result >> 3) & 1)
	return result


func mask_at(index: int, rotations: Dictionary = {}) -> int:
	var cell: Dictionary = cells[index]
	if cell["kind"] == "switch":
		return int(cell["switch_masks"][posmod(int(rotations.get(index, cell["rotation"])), 2)])
	return rotate_mask(int(BASE_MASKS[cell["kind"]]), int(rotations.get(index, cell["rotation"])))


func ports_for_rotation(index: int, rotation: int) -> Vector2i:
	# x: portas de entrada; y: portas de saída. A seta base aponta ao norte.
	if cells[index]["kind"] == "diode":
		return Vector2i(rotate_mask(SOUTH, rotation), rotate_mask(NORTH, rotation))
	if cells[index]["kind"] == "switch":
		var connection := int(cells[index]["switch_masks"][posmod(rotation, 2)])
		return Vector2i(connection, connection)
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
	outgoing |= int(required_ports.get(index, 0))
	return ports.x & incoming == incoming and ports.y & outgoing == outgoing and (ports.x | ports.y) != 0


func can_rotate(index: int) -> bool:
	if not objectives_valid or index < 0 or index >= cells.size() or cells[index]["kind"] in ["blocker", "empty"]:
		return false
	for member in action_members(index):
		if bool(cells[member].get("fixed", false)):
			return false
	return true


func rotation_period(index: int) -> int:
	return 2 if cells[index]["kind"] == "switch" else 4


func action_members(index: int) -> Array:
	return _linked.get(index, [index])


func action_indices() -> Array[int]:
	var result: Array[int] = []
	for index in range(cells.size()):
		if can_rotate(index) and index == int(action_members(index)[0]):
			result.append(index)
	return result


func steps_to_plan(index: int, rotations: Dictionary) -> int:
	for turns in range(rotation_period(index)):
		var matches := true
		for member: int in action_members(index):
			matches = matches and orientation_key(member, int(cells[member]["rotation"]) + turns) == orientation_key(member, int(rotations.get(member, cells[member]["rotation"])))
		if matches:
			return turns
	return -1


func rotate_cell(index: int) -> bool:
	return _apply_turns(index, 1, false)


func apply_hint(index: int, turns: int) -> bool:
	return _apply_turns(index, turns, true)


func _apply_turns(index: int, turns: int, lock: bool) -> bool:
	if not can_rotate(index):
		return false
	for member: int in action_members(index):
		cells[member]["rotation"] = posmod(int(cells[member]["rotation"]) + turns, rotation_period(member))
		if lock:
			cells[member]["fixed"] = true
	recompute()
	return true


func recompute() -> void:
	revision += 1
	if not objectives_valid:
		energized.clear()
		solved = false
		return
	energized = energized_for()
	solved = objectives_met(energized)


func objectives_met(powered: Dictionary, rotations: Dictionary = {}) -> bool:
	if not required_objectives_met(powered, rotations):
		return false
	for index in forbidden_nodes:
		if powered.has(index):
			return false
	return true


func required_objectives_met(powered: Dictionary, rotations: Dictionary = {}) -> bool:
	if not objectives_valid or not powered.has(target_index) or (ports_at(target_index, rotations).y & target_port) == 0:
		return false
	for index in required_nodes:
		if not powered.has(index) or (ports_at(index, rotations).y & int(required_ports.get(index, 0))) != int(required_ports.get(index, 0)):
			return false
	return true


func target_connected() -> bool:
	return energized.has(target_index) and (ports_at(target_index).y & target_port) != 0


func lit_required_count() -> int:
	var count := 0
	for index in required_nodes:
		if energized.has(index) and (ports_at(index).y & int(required_ports.get(index, 0))) == int(required_ports.get(index, 0)):
			count += 1
	return count


func active_alarm_count() -> int:
	var count := 0
	for index in forbidden_nodes:
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
	var powered := _energy_parents(rotations)
	for index in powered:
		powered[index] = true
	return powered


func energy_path_to(index: int, rotations: Dictionary) -> Array[int]:
	var parents := _energy_parents(rotations)
	var result: Array[int] = []
	if not parents.has(index):
		return result
	while index >= 0:
		result.append(index)
		index = int(parents[index])
	return result


func _energy_parents(rotations: Dictionary) -> Dictionary:
	var powered: Dictionary = {}
	if cells.is_empty() or (ports_at(source_index, rotations).x & source_port) == 0:
		return powered
	var frontier: Array[int] = [source_index]
	powered[source_index] = -1
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
			powered[next] = index
			frontier.append(next)
	return powered
