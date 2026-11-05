extends Control
## Apresentação de duas falas. Não conhece fases, relógio ou persistência.

const EXECUTOR_COLOR := Color("8be0ae")

signal finished
signal advanced
var active := false
var step := 0
var lines: Array = []
var subject_name := ""
var subject_color := Color.WHITE
var presentation_time := 0.0
var advance_button: Button
var skip_button: Button
var bubble: Panel
var speaker: Label
var body: Label
var counter: Label
var _pointer_down := false
var _bubble_style: StyleBoxFlat


func _ready() -> void:
	size = Vector2(720, 1600)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var area := ColorRect.new()
	area.position = Vector2(0, 122)
	area.size = Vector2(720, 1478)
	area.color = Color(0.015, 0.025, 0.04, 0.3)
	area.gui_input.connect(_on_pointer)
	add_child(area)
	bubble = Panel.new()
	bubble.size = Vector2(592, 280)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("172a37")
	style.border_color = Color("94adb8")
	style.set_border_width_all(2)
	style.set_corner_radius_all(24)
	bubble.add_theme_stylebox_override("panel", style)
	_bubble_style = style
	add_child(bubble)
	speaker = _label(Vector2(24, 18), Vector2(410, 40), 28, Color.WHITE)
	counter = _label(Vector2(466, 18), Vector2(100, 40), 26, Color("c7d4dd"))
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	body = _label(Vector2(24, 72), Vector2(544, 184), 40, Color("f1eee1"))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advance_button = Button.new()
	advance_button.position = Vector2(112, 1474)
	advance_button.size = Vector2(496, 96)
	advance_button.pressed.connect(advance)
	add_child(advance_button)
	skip_button = Button.new()
	skip_button.text = "PULAR"
	skip_button.position = Vector2(536, 1330)
	skip_button.size = Vector2(160, 80)
	skip_button.pressed.connect(finish)
	add_child(skip_button)
	hide()


func _label(position_value: Vector2, extent: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = position_value
	label.size = extent
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	bubble.add_child(label)
	return label


func begin(dialogue: Array, name_value: String, color_value: Color) -> void:
	lines = dialogue.duplicate()
	subject_name = name_value
	subject_color = color_value
	step = 0
	active = true
	_pointer_down = false
	_update_text()
	show()
	advance_button.grab_focus()


func advance() -> void:
	if not active or not visible:
		return
	if step >= lines.size() - 1:
		finish()
	else:
		step += 1
		_update_text()
		advanced.emit()


func finish() -> void:
	if active and visible:
		call_deferred("_finish")


func _finish() -> void:
	if not active:
		return
	active = false
	_pointer_down = false
	hide()
	finished.emit()


func close() -> void:
	active = false
	_pointer_down = false
	hide()


func _update_text() -> void:
	presentation_time = 0.0
	_update_entrance()
	speaker.text = subject_name if step == 1 else "Executor"
	var accent := subject_color if step == 1 else EXECUTOR_COLOR
	_bubble_style.bg_color = accent.darkened(0.82)
	_bubble_style.border_color = accent
	speaker.add_theme_color_override("font_color", accent)
	body.text = lines[step]
	counter.text = "%d / %d" % [step + 1, lines.size()]
	advance_button.text = "COMEÇAR" if step == lines.size() - 1 else "CONTINUAR"
	queue_redraw()


func advance_presentation(delta: float) -> void:
	if not active or not visible:
		return
	presentation_time += maxf(0, delta)
	_update_entrance()


func _update_entrance() -> void:
	var progress := smoothstep(0.0, 0.18, presentation_time)
	bubble.position = Vector2(64, (760 if step == 1 else 430) + 12.0 * (1.0 - progress))
	bubble.modulate.a = lerpf(0.45, 1.0, progress)
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	var bottom := bubble.position.y + bubble.size.y - 3.0
	var top := bubble.position.y + 3.0
	var points := PackedVector2Array([Vector2(320, bottom), Vector2(358, 1070), Vector2(386, bottom)]) if step == 1 else PackedVector2Array([Vector2(182, top), Vector2(234, 370), Vector2(258, top)])
	var fill := _bubble_style.bg_color
	var edge := _bubble_style.border_color
	fill.a *= bubble.modulate.a
	edge.a *= bubble.modulate.a
	draw_colored_polygon(points, fill)
	draw_polyline(points, edge, 2, true)


func _on_pointer(event: InputEvent) -> void:
	if not active or not visible:
		return
	if event is InputEventScreenTouch and event.index == 0:
		if not event.pressed and _pointer_down:
			advance()
		_pointer_down = event.pressed
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.device != -1:
		if not event.pressed and _pointer_down:
			advance()
		_pointer_down = event.pressed
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not visible:
		_pointer_down = false


func _input(event: InputEvent) -> void:
	# Consumir pressão e soltura impede que o botão também avance por ui_accept.
	if active and visible and event is InputEventKey and event.keycode in [KEY_SPACE, KEY_ENTER]:
		if event.pressed and not event.echo:
			if get_viewport().gui_get_focus_owner() == skip_button:
				finish()
			else:
				advance()
		get_viewport().set_input_as_handled()
