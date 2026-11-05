extends Node2D
## Mangueiras externas de apresentação; não modificam o circuito nem a sessão.

const INK := Color("09141e")
var generator: Control
var board: Control
var subject: Control
var _geometry: Array = []
var _paths: Array[Curve2D] = []


func connection_paths() -> Array[Curve2D]:
	if not is_instance_valid(generator) or not is_instance_valid(board) or not is_instance_valid(subject) or board.model == null:
		return []
	var start := _point(generator, generator.cable_connection_point())
	var inlet := _point(board, board.terminal_position(board.model.source_index, Vector2.LEFT))
	var outlet := _point(board, board.terminal_position(board.model.target_index, Vector2.RIGHT))
	var finish := _point(subject, subject.cable_connection_point())
	var top_left := _point(board, Vector2.ZERO)
	var bottom_right := _point(board, board.size)
	var key: Array = [start, inlet, outlet, finish, top_left, bottom_right]
	if key == _geometry:
		return _paths
	_geometry = key
	var left_lane := top_left.x - 26.0
	var right_lane := bottom_right.x + 24.0
	var input := Curve2D.new()
	input.bake_interval = 3.0
	input.add_point(start, Vector2.ZERO, Vector2(-60, 0))
	input.add_point(Vector2(left_lane, top_left.y - 44), Vector2(0, -35), Vector2(0, 24))
	input.add_point(Vector2(left_lane, inlet.y - 40), Vector2(0, -24), Vector2(0, 24))
	input.add_point(inlet, Vector2(-27, 0))
	var output := Curve2D.new()
	output.bake_interval = 3.0
	var bend_y := outlet.y + 44.0
	var guard_y := bottom_right.y + 70.0
	var vertical_handle := minf(80, (guard_y - bend_y) * 0.35)
	output.add_point(outlet, Vector2.ZERO, Vector2(25, 0))
	output.add_point(Vector2(right_lane, bend_y), Vector2(0, -25), Vector2(0, vertical_handle))
	output.add_point(Vector2(right_lane, guard_y), Vector2(0, -vertical_handle), Vector2(0, 95))
	output.add_point(Vector2(finish.x + 180, finish.y + 24), Vector2(68, 0), Vector2(-76, 0))
	output.add_point(finish, Vector2(55, 14))
	_paths = [input, output]
	return _paths


func _point(control: Control, local: Vector2) -> Vector2:
	return to_local(control.get_global_transform() * local)


func _draw() -> void:
	var paths := connection_paths()
	if paths.size() != 2:
		return
	_draw_cable(paths[0], board.model.energized.has(board.model.source_index))
	_draw_cable(paths[1], subject.state in [&"zap", &"recover", &"win"])


func _draw_cable(curve: Curve2D, live: bool) -> void:
	var points := curve.get_baked_points()
	var shadow := PackedVector2Array()
	for point in points:
		shadow.append(point + Vector2(3, 5))
	draw_polyline(shadow, Color(0.015, 0.025, 0.035, 0.6), 30, true)
	draw_polyline(points, INK, 27, true)
	draw_polyline(points, Color("28353e"), 23, true)
	draw_polyline(points, Color("52646c"), 17, true)
	draw_polyline(points, Color("73837e"), 5, true)
	var length := curve.get_baked_length()
	var distance := 28.0
	while distance < length - 28:
		var center := curve.sample_baked(distance, true)
		var tangent := _tangent(curve, distance)
		var normal := Vector2(-tangent.y, tangent.x)
		var rib := PackedVector2Array([center - normal * 10, center - normal * 5 + tangent * 2, center + tangent * 3, center + normal * 5 + tangent * 2, center + normal * 10])
		draw_polyline(rib, Color("17232c"), 4, true)
		for index in range(rib.size()):
			rib[index] -= tangent * 1.5
		draw_polyline(rib, Color("8c9793"), 1.4, true)
		distance += 9.0
	for fraction in [0.38, 0.68]:
		var offset: float = length * fraction
		var point := curve.sample_baked(offset, true)
		var tangent := _tangent(curve, offset)
		if absf(tangent.y) > 0.98 and point.y > _geometry[4].y + 50 and point.y < _geometry[5].y - 40:
			_draw_wall_clamp(point, tangent)
	_draw_plug(curve.sample_baked(13, true), _tangent(curve, 13), live)
	_draw_plug(curve.sample_baked(length - 13, true), _tangent(curve, length - 13), live)


func _tangent(curve: Curve2D, distance: float) -> Vector2:
	return (curve.sample_baked(minf(curve.get_baked_length(), distance + 2), true) - curve.sample_baked(maxf(0, distance - 2), true)).normalized()


func _draw_plug(point: Vector2, tangent: Vector2, live: bool) -> void:
	draw_set_transform(point, tangent.angle())
	var rim := PackedVector2Array([Vector2(-15, -11), Vector2(-10, -16), Vector2(10, -16), Vector2(15, -11), Vector2(15, 11), Vector2(10, 16), Vector2(-10, 16), Vector2(-15, 11)])
	draw_colored_polygon(rim, INK)
	draw_rect(Rect2(-11, -12, 23, 24), Color("9c753c"))
	draw_rect(Rect2(-9, -11, 6, 22), Color("e1bb70"))
	draw_rect(Rect2(6, -12, 5, 24), Color("536674"))
	draw_line(Vector2(-10, -11), Vector2(11, -11), Color("f0d59a"), 2, true)
	for y in [-7, 7]:
		draw_circle(Vector2(0, y), 2.4, INK)
		draw_line(Vector2(-1, y), Vector2(1, y), Color("a8b3ad"), 1, true)
	draw_rect(Rect2(6, -7, 4, 14), Color("79ecff") if live else Color("384b57"))
	draw_set_transform(Vector2.ZERO)


func _draw_wall_clamp(point: Vector2, tangent: Vector2) -> void:
	var normal := Vector2(-tangent.y, tangent.x)
	draw_line(point - normal * 20, point + normal * 20, INK, 13, true)
	draw_line(point - normal * 18, point + normal * 18, Color("7a858a"), 8, true)
	draw_line(point - normal * 17 - tangent * 2, point + normal * 17 - tangent * 2, Color("bcc0b4"), 2, true)
	for side in [-1, 1]:
		var bolt: Vector2 = point + normal * side * 16
		draw_circle(bolt, 3, INK)
		draw_line(bolt - tangent * 1.5, bolt + tangent * 1.5, Color("b7beb9"), 1, true)
