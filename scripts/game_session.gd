class_name GameSession
extends RefCounted
## Regras da tentativa, independentes da apresentação e do relógio do sistema.

const Board = preload("res://scripts/circuit_board.gd")
const Solution = preload("res://scripts/circuit_solution.gd")
enum State { READY, PLAYING, PAUSED, RESOLVING, WON, LOST }

var board := Board.new()
var state: State = State.READY
var remaining := 90.0
var time_limit := 90.0
var moves := 0
var elapsed := 0.0
var hints_used := 0
var previous_state: State = State.READY
var level: Dictionary
var _hint_revision := -1
var _hint_plan: Dictionary = {}


func start(data: Dictionary) -> void:
	level = data.duplicate(true)
	board.load_level(level)
	time_limit = maxf(0.0, float(level["time_limit"]))
	remaining = time_limit
	moves = 0
	elapsed = 0.0
	hints_used = 0
	_hint_revision = -1
	_hint_plan.clear()
	state = State.READY
	previous_state = State.READY


func has_time_limit() -> bool:
	return time_limit > 0.0


func tick(seconds: float) -> void:
	if state != State.PLAYING:
		return
	var delta := maxf(0.0, seconds)
	if not has_time_limit():
		elapsed += delta
		return
	elapsed += minf(delta, remaining)
	remaining = maxf(0.0, remaining - delta)
	if remaining <= 0.0:
		state = State.LOST


func rotate_cell(index: int) -> bool:
	if state not in [State.READY, State.PLAYING] or not board.can_rotate(index):
		return false
	if state == State.PLAYING and has_time_limit() and remaining <= 0.0:
		state = State.LOST
		return false
	if state == State.READY:
		state = State.PLAYING
	board.rotate_cell(index)
	moves += 1
	if board.solved:
		state = State.RESOLVING
	return true


func hint_candidate() -> int:
	if state not in [State.READY, State.PLAYING] or hints_used > 0 or board.solved:
		return -1
	if has_time_limit() and remaining <= 0.0:
		return -1
	if _hint_revision != board.revision:
		_hint_plan = Solution.new().solve(board)
		_hint_revision = board.revision
	for value in _hint_plan.get("path", []):
		var index := int(value)
		var cell: Dictionary = board.cells[index]
		var goal := Board.rotate_mask(int(Board.BASE_MASKS[cell["kind"]]), int(_hint_plan["rotations"][index]))
		if board.can_rotate(index) and board.mask_at(index) != goal:
			return index
	return -1


func use_hint() -> int:
	var index := hint_candidate()
	if index < 0:
		return -1
	var cell: Dictionary = board.cells[index]
	var base := int(Board.BASE_MASKS[cell["kind"]])
	var goal := Board.rotate_mask(base, int(_hint_plan["rotations"][index]))
	var turns := 1
	while turns < 4 and Board.rotate_mask(base, int(cell["rotation"]) + turns) != goal:
		turns += 1
	cell["rotation"] = (int(cell["rotation"]) + turns) % 4
	cell["fixed"] = true
	board.recompute()
	moves += turns
	hints_used = 1
	state = State.RESOLVING if board.solved else State.PLAYING
	return index


func pause() -> void:
	if state in [State.READY, State.PLAYING]:
		previous_state = state
		state = State.PAUSED


func resume() -> void:
	if state == State.PAUSED:
		state = previous_state


func finish_resolution() -> void:
	if state == State.RESOLVING:
		state = State.WON


func score() -> int:
	if state not in [State.WON, State.RESOLVING]:
		return 0
	if not has_time_limit():
		return 1000
	return 1000 + int(floor(1000.0 * clampf(remaining / time_limit, 0.0, 1.0)))


func stars() -> int:
	if score() == 0:
		return 0
	if not has_time_limit():
		return 3
	var ratio := remaining / time_limit
	return 3 if ratio >= 0.5 else (2 if ratio >= 0.25 else 1)
