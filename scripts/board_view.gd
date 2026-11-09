extends Control
## Desenho vetorial nativo provisório; aceita mouse e toque emulado pelo Godot.

signal cell_pressed(index: int)
const Board = preload("res://scripts/circuit_board.gd")
const ArtPack = preload("res://scripts/art_pack.gd")
@export var art_pack: ArtPack
const INK := Color("0a1420")
const TILE := Color("233a49")
const WIRE := Color("788e96")
const LIVE := Color("ffcd4d")
var model: CircuitBoard
var interactive := true
var hovered := -1
var activated := -1
var activation_time := 0.0
var guide_index := -1
var hint_index := -1
var energy_time := 1.0
var equipment_time := 0.0
var newly_energized: Dictionary = {}
var _styles: Array[StyleBoxFlat] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_exited.connect(func():
		hovered = -1
		queue_redraw())


func _process(delta: float) -> void:
	if model != null and not model.required_ports.is_empty() and model.lit_required_count() > 0:
		equipment_time += maxf(delta, 0)
		queue_redraw()
	if activation_time > 0.0:
		activation_time = maxf(0.0, activation_time - delta)
		queue_redraw()
	if energy_time < 0.65:
		energy_time += maxf(delta, 0)
		queue_redraw()


func animate_energy(previous: Array) -> void:
	newly_energized.clear()
	for index in model.energized:
		if not previous.has(index):
			newly_energized[index] = minf(0.18, newly_energized.size() * 0.025)
	energy_time = 0.0
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if model == null or not interactive:
		return
	if event is InputEventMouseMotion:
		hovered = index_at(event.position)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if model.can_rotate(hovered) else Control.CURSOR_ARROW
		queue_redraw()
	if event is InputEventScreenTouch and event.pressed and event.index == 0:
		_press_at(event.position)
		accept_event()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# O toque já foi tratado acima; ignorar o mouse sintetizado evita giro duplo.
		if event.device != -1:
			_press_at(event.position)
		accept_event()


func _press_at(point: Vector2) -> void:
	var index := index_at(point)
	if index >= 0:
		activated = index
		activation_time = 0.16
		cell_pressed.emit(index)


func index_at(point: Vector2) -> int:
	if model == null or not Rect2(Vector2.ZERO, size).has_point(point):
		return -1
	var step := size.x / float(model.width)
	var column := int(point.x / step)
	var row := int(point.y / step)
	var index := row * model.width + column
	if not cell_rect(index).has_point(point):
		return -1
	return index


func cell_rect(index: int) -> Rect2:
	if model == null or index < 0 or index >= model.cells.size():
		return Rect2()
	var step := size.x / float(model.width)
	var gap := minf(5.0, step / 26.0)
	var origin := Vector2(index % model.width, index / model.width) * step
	return Rect2(origin + Vector2.ONE * gap, Vector2.ONE * (step - 2.0 * gap))


func _draw() -> void:
	if model == null:
		return
	_styles.clear()
	var step := size.x / float(model.width)
	var detail_scale := minf(1.0, step / 156.0)
	var live_color: Color = art_pack.live_color if art_pack != null else LIVE
	for index in range(model.cells.size()):
		var cell: Dictionary = model.cells[index]
		var origin := Vector2(index % model.width, index / model.width) * step
		var rect := cell_rect(index)
		var live := model.energized.has(index)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("2e4957") if index == hovered and interactive else TILE
		if cell["kind"] == "empty":
			style.bg_color = Color("132632")
		style.border_color = Color("61727b") if bool(cell.get("fixed", false)) else Color("3a5664")
		if live:
			style.border_color = live_color.darkened(0.3)
		style.set_border_width_all(2)
		style.set_corner_radius_all(maxi(8, int(15 * detail_scale)))
		style.shadow_color = INK
		style.shadow_size = 1
		style.shadow_offset = Vector2(0, 5)
		_styles.append(style)
		draw_style_box(style, rect)
		if art_pack != null and art_pack.tile_background != null:
			draw_texture_rect(art_pack.tile_background, rect, false)
			if cell["kind"] == "empty":
				draw_rect(rect.grow(-4), Color(0.02, 0.05, 0.08, 0.58))
			elif index == hovered and interactive:
				draw_rect(rect.grow(-4), Color(1, 1, 1, 0.07))
		var center := origin + Vector2.ONE * step * 0.5
		if cell["kind"] == "empty":
			draw_circle(center, maxf(2, 3 * detail_scale), Color("29404e"))
			continue
		if cell["kind"] == "blocker":
			var blocker_texture: Texture2D = art_pack.blocker if art_pack != null else null
			if blocker_texture != null:
				draw_texture_rect(blocker_texture, rect, false)
			else:
				_draw_blocker(center, step)
			continue
		var visual_kind := str(cell["kind"])
		var visual_rotation := int(cell["rotation"])
		if visual_kind == "switch":
			var switch_mask := model.mask_at(index)
			visual_kind = "straight" if switch_mask in [5, 10] else "curve"
			for turns in range(4):
				if Board.rotate_mask(Board.BASE_MASKS[visual_kind], turns) == switch_mask:
					visual_rotation = turns
					break
		var texture: Texture2D = art_pack.wire_texture(visual_kind, live) if art_pack != null else null
		if texture != null:
			draw_set_transform(center, float(visual_rotation) * PI * 0.5)
			draw_texture_rect(texture, Rect2(-rect.size * 0.5, rect.size), false)
			draw_set_transform(Vector2.ZERO)
		else:
			var mask := model.mask_at(index)
			var reach := rect.size.x * 0.5
			for direction in range(4):
				if (mask & int(Board.PORTS[direction])) == 0:
					continue
				var end := center + Vector2(Board.OFFSETS[direction]) * reach
				draw_line(center, end, INK, 31 * detail_scale, true)
				draw_line(center, end, Color("a87931") if live else Color("4c626b"), 23 * detail_scale, true)
				draw_line(center, end, LIVE if live else WIRE, 13 * detail_scale, true)
				if live:
					draw_line(center, end, Color("fff2b0"), maxf(2, 3 * detail_scale), true)
			draw_circle(center, 15 * detail_scale, INK)
			draw_circle(center, 10 * detail_scale, LIVE if live else Color("aec0c4"))
			draw_circle(center, 4 * detail_scale, Color("fff2b0") if live else Color("526a75"))
		if cell["kind"] == "diode":
			_draw_direction(index, center, detail_scale)
		if cell["kind"] == "switch":
			_draw_switch(index, center, detail_scale)
		if bool(cell.get("fixed", false)):
			var lock_pos := rect.position + Vector2(15, 15) * detail_scale
			if index == model.source_index:
				lock_pos.x = rect.end.x - 15 * detail_scale
			draw_circle(lock_pos, maxf(7, 10 * detail_scale), INK)
			draw_arc(lock_pos + Vector2(0, -3 * detail_scale), maxf(3, 4 * detail_scale), PI, TAU, 12, Color("ffce49"), 2, true)
			draw_rect(Rect2(lock_pos + Vector2(-5, -2) * detail_scale, Vector2(10, 8) * detail_scale), Color("ffce49"))
		if live and newly_energized.has(index):
			var progress := (energy_time - float(newly_energized[index])) / 0.42
			if progress > 0.0 and progress < 1.0:
				for direction in range(4):
					if model.ports_at(index).y & Board.PORTS[direction]:
						var spark := center + Vector2(Board.OFFSETS[direction]) * rect.size.x * 0.45 * progress
						draw_circle(spark, maxf(2, 3 * detail_scale), Color(1, 0.95, 0.7, 1.0 - progress))
		if model.action_members(activated).has(index) and activation_time > 0.0:
			draw_arc(center, step * 0.30, -1.3, 0.3, 16, LIVE, 3, true)
		if model.action_members(hint_index).has(index):
			var hint_style := StyleBoxFlat.new()
			hint_style.draw_center = false
			hint_style.border_color = Color("6ce1c4")
			hint_style.set_border_width_all(4)
			hint_style.set_corner_radius_all(maxi(8, int(15 * detail_scale)))
			_styles.append(hint_style)
			draw_style_box(hint_style, rect.grow(-2))
			if model.action_members(index).size() == 1:
				draw_string(ThemeDB.fallback_font, rect.position + Vector2(8, rect.size.y - 8), "✓", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("6ce1c4"))
		if index == guide_index and interactive:
			var guide_style := StyleBoxFlat.new()
			guide_style.draw_center = false
			guide_style.border_color = LIVE
			guide_style.set_border_width_all(3)
			guide_style.set_corner_radius_all(maxi(8, int(15 * detail_scale)))
			_styles.append(guide_style)
			draw_style_box(guide_style, rect.grow(-2))
			var arrow := rect.position + Vector2(rect.size.x - 26 * detail_scale, 26 * detail_scale)
			draw_circle(arrow, 18 * detail_scale, INK)
			draw_arc(arrow, 10 * detail_scale, -2.4, 1.1, 20, LIVE, maxf(2, 3 * detail_scale), true)
			draw_colored_polygon(PackedVector2Array([arrow + Vector2(-1, 4) * detail_scale, arrow + Vector2(8, 11) * detail_scale, arrow + Vector2(10, 0) * detail_scale]), LIVE)
		if model.required_nodes.has(index):
			if model.required_ports.has(index):
				_draw_fan(lamp_rect(index), live and (model.ports_at(index).y & int(model.required_ports[index])) != 0)
			else:
				_draw_lamp(lamp_rect(index), live)
		if model.forbidden_nodes.has(index):
			_draw_alarm(lamp_rect(index), live)
		for group_number in range(model.linked_groups.size()):
			if model.linked_groups[group_number].has(index):
				_draw_link(rect, group_number + 1)
	_draw_terminal(model.source_index, Vector2.LEFT, "IN", live_color)
	_draw_terminal(model.target_index, Vector2.RIGHT, "OUT", Color("6ce1c4") if model.target_connected() else Color("93a8b1"))
	for index: int in model.required_ports:
		var direction := Board.PORTS.find(int(model.required_ports[index]))
		_draw_terminal(index, Vector2(Board.OFFSETS[direction]), "VENT", Color("6ce1c4") if model.energized.has(index) and (model.ports_at(index).y & int(model.required_ports[index])) != 0 else Color("93a8b1"))


func _draw_switch(index: int, center: Vector2, detail: float) -> void:
	var state := int(model.cells[index]["rotation"])
	draw_circle(center, 18 * detail, INK)
	draw_line(center + Vector2(0, 10) * detail, center + Vector2(11 if state else -11, -12) * detail, Color("f1eee1"), 6 * detail, true)
	draw_circle(center + Vector2(11 if state else -11, -12) * detail, 6 * detail, Color("ffce49"))
	var badge := lamp_rect(index)
	draw_circle(badge.get_center(), badge.size.x * 0.5, INK)
	draw_string(ThemeDB.fallback_font, badge.get_center() + Vector2(-6, 7), "B" if state else "A", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffce49"))


func _draw_link(rect: Rect2, number: int) -> void:
	var badge := Rect2(rect.position + Vector2(4, rect.size.y - 31), Vector2(38, 27))
	var style := StyleBoxFlat.new()
	style.bg_color = INK
	style.set_corner_radius_all(8)
	_styles.append(style)
	draw_style_box(style, badge)
	var point := badge.position + Vector2(13, 13)
	for offset in [-4, 4]:
		draw_arc(point + Vector2(offset, 0), 5, -0.4, TAU - 1.2, 16, Color("6ce1c4"), 2, true)
	draw_string(ThemeDB.fallback_font, badge.position + Vector2(25, 20), str(number), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f1eee1"))


func _draw_alarm(rect: Rect2, live: bool) -> void:
	var center := rect.get_center()
	var scale_value := rect.size.x / 38.0
	draw_circle(center, 19 * scale_value, INK)
	var triangle := PackedVector2Array([center + Vector2(0, -14) * scale_value, center + Vector2(-14, 12) * scale_value, center + Vector2(14, 12) * scale_value])
	draw_colored_polygon(triangle, Color("fa8e74") if live else Color("b7c5ce"))
	draw_line(center + Vector2(0, -5) * scale_value, center + Vector2(0, 3) * scale_value, INK, maxf(2, 3 * scale_value), true)
	draw_circle(center + Vector2(0, 7) * scale_value, maxf(1.5, 2 * scale_value), INK)
	if live:
		for sign_value in [-1, 1]:
			draw_line(center + Vector2(sign_value * 14, -9) * scale_value, center + Vector2(sign_value * 17, -14) * scale_value, Color("fa8e74"), 2, true)


func _draw_fan(rect: Rect2, live: bool) -> void:
	var center := rect.get_center()
	var unit := rect.size.x / 38.0
	draw_circle(center, 19 * unit, INK)
	draw_arc(center, 14 * unit, 0, TAU, 24, Color("6ce1c4") if live else Color("b7c5ce"), 2, true)
	var angle := equipment_time * 4.0 if live else 0.0
	for blade in range(3):
		var direction := Vector2.from_angle(angle + blade * TAU / 3)
		draw_line(center + direction * 3 * unit, center + direction * 10 * unit, Color("6ce1c4") if live else Color("b7c5ce"), 6 * unit, true)
	draw_circle(center, 4 * unit, Color("f1eee1"))


func lamp_rect(index: int) -> Rect2:
	var rect := cell_rect(index)
	var extent := clampf(rect.size.x * 0.30, 27, 38)
	return Rect2(Vector2(rect.end.x - extent - 5, rect.position.y + 5), Vector2.ONE * extent)


func _draw_direction(index: int, center: Vector2, scale_value: float) -> void:
	var forward := Vector2.UP.rotated(float(model.cells[index]["rotation"]) * PI * 0.5)
	var side := forward.orthogonal()
	var points := PackedVector2Array()
	for offset in [Vector2(-6, -20), Vector2(-6, 3), Vector2(-14, 3), Vector2(0, 25), Vector2(14, 3), Vector2(6, 3), Vector2(6, -20)]:
		points.append(center + (side * offset.x + forward * offset.y) * scale_value)
	var blocked := model.direction_blocked(index)
	draw_colored_polygon(points, Color("fa8e74") if blocked else Color("fff2b0") if model.energized.has(index) else Color("6ce1c4"))
	points.append(points[0])
	draw_polyline(points, INK, maxf(3, 5 * scale_value), true)
	if blocked:
		var rect := cell_rect(index)
		var mark := rect.end - Vector2(15, 17) * scale_value
		draw_circle(mark, 12 * scale_value, INK)
		draw_string(ThemeDB.fallback_font, mark + Vector2(-3, 6) * scale_value, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(14, int(21 * scale_value)), Color("fa8e74"))


func _draw_lamp(rect: Rect2, live: bool) -> void:
	var center := rect.get_center()
	var unit := rect.size.x / 38.0
	var bulb := center + Vector2(0, -3) * unit
	var color := Color("ffe47a") if live else Color("d3dfe6")
	draw_circle(center, 19 * unit, INK)
	if live:
		for direction in [Vector2.UP, Vector2.LEFT, Vector2.RIGHT]:
			draw_line(bulb + direction * 12 * unit, bulb + direction * 16 * unit, color, 2 * unit, true)
	draw_circle(bulb, 9 * unit, color)
	draw_circle(bulb, 6 * unit, Color("fff4ac") if live else Color("344b60"))
	draw_line(bulb + Vector2(-3, 0) * unit, bulb + Vector2(0, 4) * unit, color, 2 * unit, true)
	draw_line(bulb + Vector2(0, 4) * unit, bulb + Vector2(3, 0) * unit, color, 2 * unit, true)
	for y in [7, 10, 13]:
		draw_line(bulb + Vector2(-4, y) * unit, bulb + Vector2(4, y) * unit, color, 2 * unit, true)


func _draw_blocker(center: Vector2, step: float) -> void:
	var detail_scale := minf(1.0, step / 156.0)
	var rect := Rect2(center - Vector2(step * 0.23, step * 0.18), Vector2(step * 0.46, step * 0.36))
	draw_rect(rect, INK)
	draw_line(center - Vector2(15, 14) * detail_scale, center + Vector2(15, 14) * detail_scale, Color("ef8b70"), 6 * detail_scale, true)
	draw_line(center - Vector2(15, -14) * detail_scale, center + Vector2(15, -14) * detail_scale, Color("ef8b70"), 6 * detail_scale, true)
	for sign_value in [-1, 1]:
		var x: float = center.x + sign_value * step * 0.29
		draw_line(Vector2(x, center.y - 18 * detail_scale), Vector2(x, center.y + 18 * detail_scale), Color("566c75"), 9 * detail_scale, true)


func _draw_terminal(index: int, direction: Vector2, caption: String, color: Color) -> void:
	var step := size.x / float(model.width)
	var detail_scale := minf(1.0, step / 156.0)
	var end := terminal_position(index, direction)
	draw_circle(end, 12 * detail_scale, INK)
	draw_circle(end, 8 * detail_scale, color)
	var offset := Vector2(maxf(8, 12 * detail_scale), -step * 0.22) if direction.x < 0 else Vector2(-maxf(28, 40 * detail_scale), step * 0.30)
	draw_string(ThemeDB.fallback_font, end + offset, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)


func terminal_position(index: int, direction: Vector2) -> Vector2:
	var step := size.x / float(model.width)
	var center := Vector2(index % model.width + 0.5, index / model.width + 0.5) * step
	return center + direction * (step * 0.5 - 7)
