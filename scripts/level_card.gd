extends Button
## Cartão nativo: os rótulos não interceptam cliques nem toques.

const Profile = preload("res://scripts/player_profile.gd")
var level_id := 0
var record: Dictionary = {}
var _number: Label
var _status: Label
var _stars: Label
var _title: Label
var _score: Label
var _time: Label


func _label(node_name: String, point: Vector2, extent: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.position = point
	label.size = extent
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label


func configure(data: Dictionary, result: Dictionary, unlocked: bool) -> void:
	if _number == null:
		_number = _label("Number", Vector2(16, 8), Vector2(60, 42), 32)
		_status = _label("Status", Vector2(76, 17), Vector2(136, 28), 15)
		_stars = _label("Stars", Vector2(222, 11), Vector2(80, 34), 23)
		_title = _label("Title", Vector2(16, 54), Vector2(280, 44), 20)
		_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_score = _label("Score", Vector2(16, 102), Vector2(280, 26), 20)
		_time = _label("Time", Vector2(16, 130), Vector2(280, 26), 20)
	level_id = int(data["id"])
	record = result.duplicate(true)
	disabled = not unlocked
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if unlocked else Control.CURSOR_ARROW
	var completed := bool(record.get("completed", false))
	var accent := Color("6ce1c4") if completed else (Color("ffce49") if unlocked else Color("637e8b"))
	for variant in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("213c49") if variant in ["hover", "focus"] else Color("172a37")
		style.border_color = accent if unlocked else Color("304653")
		style.set_border_width_all(2)
		style.set_corner_radius_all(16)
		add_theme_stylebox_override(variant, style)
	_number.text = "%02d" % level_id
	_title.text = str(data["name"])
	_status.text = "CONCLUÍDA" if completed else ("DISPONÍVEL" if unlocked else "BLOQUEADA")
	var count := int(record.get("stars", 0))
	_stars.text = "★".repeat(count) + "☆".repeat(3 - count) if count > 0 else "—"
	if not unlocked:
		_score.text = "Complete a fase anterior"
		_time.text = "para desbloquear."
	elif bool(record.get("legacy", false)):
		_score.text = "Recordes por registrar"
		_time.text = "Rejogue esta fase."
	elif completed:
		_score.text = "Recorde: %d pts" % int(record.get("best_score", 0))
		_time.text = "Melhor: " + Profile.format_time(float(record.get("best_time", -1)))
	else:
		_score.text = "Sem recorde ainda"
		_time.text = "Toque para jogar."
	for label in [_number, _title]:
		label.add_theme_color_override("font_color", Color("f1eee1") if unlocked else Color("8299a4"))
	_status.add_theme_color_override("font_color", accent)
	_stars.add_theme_color_override("font_color", Color("ffce49") if count > 0 else Color("8299a4"))
	_score.add_theme_color_override("font_color", Color("b6c9cf") if unlocked else Color("8299a4"))
	_time.add_theme_color_override("font_color", Color("94adb8"))
