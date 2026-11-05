extends Control
## Apresentação da sala. Não conhece GameSession, fases, save ou pontuação.

const ArtPack = preload("res://scripts/art_pack.gd")
const ExecutionCharacter = preload("res://scripts/execution_character.gd")
const Portrait = preload("res://scripts/character_portrait.gd")
const INK := Color("09141e")
const CREAM := Color("f1eee1")
const MUTED := Color("94adb8")
const YELLOW := Color("ffce49")
var art_pack: ArtPack
var execution_character: ExecutionCharacter
var is_operator := false
var embedded := false
var state: StringName = &"idle"
var animation_time := 0.0
var soft_flashes := true
var is_menu := false
var line_one := "É só uma revisão elétrica..."
var line_two := "...certo?"
var _styles: Array[StyleBoxFlat] = []
var portrait_view: TextureRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	portrait_view = Portrait.new()
	portrait_view.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(portrait_view)


func _draw() -> void:
	_styles.clear()
	portrait_view.hide()
	if is_operator:
		_draw_operator()
		return
	if not embedded:
		_panel(Rect2(Vector2.ZERO, size), Color("142431"), Color("34505f"), 20)
	if not embedded and art_pack != null and art_pack.room_background != null:
		draw_texture_rect(art_pack.room_background, Rect2(Vector2(10, 10), size - Vector2(20, 20)), false)
	var art_bounds := Rect2(Vector2.ZERO, size) if embedded else Rect2(Vector2(12, 6), Vector2(230, minf(size.y - 12, 230)))
	var image_rect := ArtPack.contain_rect(Vector2(256, 256), art_bounds)
	draw_set_transform(image_rect.position, 0.0, image_rect.size / 256.0)
	_draw_electricity()
	draw_set_transform(Vector2.ZERO)
	var character_texture: Texture2D
	var chair_texture: Texture2D
	var composite: Texture2D
	if art_pack != null:
		chair_texture = art_pack.frame_texture(&"chair", state, animation_time, soft_flashes)
		character_texture = art_pack.frame_texture(&"character", state, animation_time, soft_flashes)
	composite = portrait_texture()
	if composite != null:
		character_texture = composite
	elif chair_texture != null:
		draw_texture_rect(chair_texture, ArtPack.contain_rect(chair_texture.get_size(), art_bounds), false)
	else:
		draw_set_transform(image_rect.position, 0.0, image_rect.size / 256.0)
		_draw_fallback_chair()
		draw_set_transform(Vector2.ZERO)
	if character_texture != null:
		var character_rect := ArtPack.contain_rect(character_texture.get_size(), art_bounds)
		# Respiração discreta, ancorada nos pés; as poses continuam substituíveis.
		if state == &"idle":
			var breathing := sin(animation_time * 2.5) * 0.007
			character_rect.position.y -= character_rect.size.y * breathing
			character_rect.size.y *= 1.0 + breathing
		elif state == &"anticipation":
			character_rect = _anchored_scale(character_rect, Vector2(1.06, 0.94))
		elif state == &"zap":
			var shake := 0.4 if soft_flashes else 2.0
			character_rect.position.x += sin(animation_time * 91.0) * shake
			character_rect = _anchored_scale(character_rect, Vector2(0.97, 1.03))
		elif state == &"recover":
			var spring := sin(animation_time * 18.0) * exp(-animation_time * 8.0) * 0.025
			character_rect = _anchored_scale(character_rect, Vector2(1.0 - spring, 1.0 + spring))
		if composite != null:
			portrait_view.position = character_rect.position
			portrait_view.size = character_rect.size
			portrait_view.set_frame(character_texture, execution_character if not is_menu else null)
		else:
			draw_texture_rect(character_texture, character_rect, false)
	else:
		draw_set_transform(image_rect.position, 0.0, image_rect.size / 256.0)
		_draw_fallback_character()
		draw_set_transform(Vector2.ZERO)
	draw_set_transform(image_rect.position, 0.0, image_rect.size / 256.0)
	_draw_smoke()
	draw_set_transform(Vector2.ZERO)
	if embedded:
		return
	var active := state in [&"anticipation", &"zap", &"recover", &"win"]
	_panel(Rect2(Vector2(244, size.y * 0.28), Vector2(size.x - 262, size.y * 0.55)), Color(0.025, 0.065, 0.095, 0.78), Color("29434f"), 10)
	draw_circle(Vector2(size.x - 25, 25), 6, Color("6ce1c4") if active else Color("fa8e74"))
	_text("SALA AO LADO", Vector2(20, 29), 12, MUTED)
	var title := "CLIENTE AGUARDANDO"
	if not is_menu and execution_character != null:
		title = execution_character.display_name.to_upper() + " NA CADEIRA"
	if is_menu and art_pack != null and art_pack.menu_portrait != null:
		title = "ALTA TENSÃO"
	var first := line_one
	var second := line_two
	match state:
		&"anticipation": title = "SEGURE O PENTEADO!"
		&"zap":
			title = "ZAAAP!"
			first = "Revisão elétrica concluída."
			second = "Penteado: recalibrado."
		&"recover", &"win":
			title = "REVISÃO CONCLUÍDA"
			first = "A fiação passou no teste."
			second = "O penteado pediu demissão."
		&"lose":
			title = "UFA... DEU PANE!"
			first = "O cliente ganhou um intervalo."
			second = "Seu chefe quer outro teste."
	_text(title, Vector2(254, size.y * 0.42), 32 if state == &"zap" else 20, YELLOW if active else CREAM)
	_text(first, Vector2(254, size.y * 0.62), 20, Color("b4c4c8"))
	_text(second, Vector2(254, size.y * 0.62 + 30), 20, Color("b4c4c8"))
	for point in [Vector2(10, 10), Vector2(size.x - 10, 10), Vector2(10, size.y - 10), size - Vector2(10, 10)]:
		draw_circle(point, 3, Color("607985"))
		draw_line(point - Vector2(2, 0), point + Vector2(2, 0), INK, 1, true)


func _draw_operator() -> void:
	if not embedded:
		_panel(Rect2(Vector2.ZERO, size), Color("142431"), Color("34505f"), 20)
	if not embedded and art_pack != null and art_pack.room_background != null:
		draw_texture_rect(art_pack.room_background, Rect2(Vector2(10, 10), size - Vector2(20, 20)), false)
	var texture := _engineer_texture()
	var bounds := Rect2(Vector2.ZERO, size) if embedded else Rect2(14, 8, 250, size.y - 16)
	if texture != null:
		draw_texture_rect(texture, ArtPack.contain_rect(texture.get_size(), bounds), false)
	else:
		# Pacotes antigos mantêm um indicador de chave funcional.
		var pivot := Vector2(130, size.y * 0.6)
		var progress := clampf(animation_time / 0.4, 0, 1) if state == &"anticipation" else 1.0 if state in [&"zap", &"recover", &"win"] else 0.0
		var end := pivot + Vector2.from_angle(lerpf(-PI * 0.5, PI * 0.15, progress)) * 90
		_panel(Rect2(pivot - Vector2(45, 15), Vector2(90, 65)), Color("526a73"), INK, 10)
		draw_line(pivot, end, YELLOW, 14, true)
		draw_circle(end, 17, Color("ab5747"))
	if embedded:
		return
	var closed := state in [&"zap", &"recover", &"win"]
	var title := "ENGENHEIRO DE PLANTÃO"
	var first := "Feche o circuito no painel."
	var second := "O goblin cuida da chave geral."
	if state == &"anticipation":
		title = "ABAIXANDO A CHAVE..."
		first = "Circuito fechado. Tudo pronto!"
		second = "O cliente vai sentir a diferença."
	elif closed:
		title = "CHAVE ABAIXADA"
		first = "Energia liberada para a cadeira."
		second = "Serviço com garantia do goblin."
	elif state == &"lose":
		title = "FALTOU ENERGIA"
		first = "A chave continua levantada."
		second = "Refaça a ligação e tente de novo."
	_panel(Rect2(270, size.y * 0.25, size.x - 288, size.y * 0.6), Color(0.025, 0.065, 0.095, 0.84), Color("29434f"), 10)
	_text("CHAVE GERAL", Vector2(20, 29), 12, MUTED)
	draw_circle(Vector2(size.x - 25, 25), 6, Color("6ce1c4") if closed else Color("fa8e74"))
	_text(title, Vector2(282, size.y * 0.42), 19, YELLOW if closed or state == &"anticipation" else CREAM)
	_text(first, Vector2(282, size.y * 0.62), 18, MUTED)
	_text(second, Vector2(282, size.y * 0.62 + 28), 18, MUTED)


func _anchored_scale(rect: Rect2, factor: Vector2) -> Rect2:
	var extent := rect.size * factor
	return Rect2(rect.position + Vector2((rect.size.x - extent.x) * 0.5, rect.size.y - extent.y), extent)


func portrait_texture() -> Texture2D:
	if is_menu and art_pack != null and art_pack.menu_portrait != null:
		return art_pack.menu_portrait
	if not is_menu and execution_character != null:
		var selected := execution_character.frame_texture(state, animation_time, soft_flashes)
		if selected != null:
			return selected
	return art_pack.frame_texture(&"portrait", state, animation_time, soft_flashes) if art_pack != null else null


func _engineer_texture() -> Texture2D:
	if art_pack == null:
		return null
	return art_pack.frame_texture(&"engineer", state, animation_time)


func cable_connection_point() -> Vector2:
	var texture := _engineer_texture() if is_operator else portrait_texture()
	if is_operator and texture == null:
		return Vector2(85, size.y * 0.6 + 20)
	var extent := texture.get_size() if texture != null else Vector2(256, 256)
	var bounds := ArtPack.contain_rect(extent, Rect2(Vector2.ZERO, size))
	var anchor := Vector2(0.16, 0.66) if is_operator else Vector2(0.74, 0.69)
	if is_operator and art_pack != null:
		anchor = art_pack.engineer_cable_anchor
	elif not is_operator and execution_character != null:
		anchor = execution_character.cable_anchor
	return bounds.position + bounds.size * anchor.clamp(Vector2.ZERO, Vector2.ONE)


func _draw_electricity() -> void:
	if state != &"zap":
		return
	for side in [-1, 1]:
		var points := PackedVector2Array()
		for step in range(6):
			var phase := float(step) / 5.0
			var wave := sin(step * 2.4 + (0.0 if soft_flashes else animation_time * 28.0))
			points.append(Vector2(128 + side * (71 - phase * 29) + wave * 5, 42 + phase * 95))
		draw_polyline(points, Color(1.0, 0.8, 0.3, 0.15 if soft_flashes else 0.25), 12, true)
		draw_polyline(points, Color("6ce1c4") if soft_flashes else YELLOW, 3, true)


func _draw_smoke() -> void:
	if state != &"recover":
		return
	var progress := clampf(animation_time / 0.55, 0, 1)
	for index in range(5):
		var origin := Vector2(76 + index * 24, 49 - progress * (20 + index * 3))
		origin.x += sin(index * 2.1) * progress * 15
		draw_circle(origin, 4 + progress * 7, Color(0.65, 0.75, 0.78, (1.0 - progress) * 0.3))


func _draw_fallback_chair() -> void:
	_panel(Rect2(72, 51, 112, 150), Color("314654"), INK, 16)
	for x in [77, 179]:
		draw_line(Vector2(x, 187), Vector2(x, 236), INK, 14, true)
	draw_line(Vector2(55, 168), Vector2(201, 168), Color("69808b"), 16, true)


func _draw_fallback_character() -> void:
	for x in [107, 149]:
		draw_line(Vector2(x, 177), Vector2(x, 219), INK, 22, true)
	_panel(Rect2(93, 121, 70, 76), YELLOW, INK, 14)
	draw_line(Vector2(94, 141), Vector2(67, 160), YELLOW, 16, true)
	draw_line(Vector2(162, 141), Vector2(189, 160), YELLOW, 16, true)
	draw_circle(Vector2(128, 87), 43, INK)
	draw_circle(Vector2(128, 87), 37, Color("e8b38b"))
	if state == &"zap" and not soft_flashes:
		draw_circle(Vector2(128, 87), 32, CREAM)
		for x in [115, 141]:
			draw_circle(Vector2(x, 84), 9, INK)
		draw_line(Vector2(128, 133), Vector2(128, 178), CREAM, 7, true)
	else:
		for x in [115, 141]:
			draw_circle(Vector2(x, 86), 8, CREAM)
			draw_circle(Vector2(x + 2, 86), 4, INK)
		draw_arc(Vector2(128, 102), 11, PI, TAU, 14, INK, 3, true)
	if state in [&"zap", &"recover", &"win"]:
		for x in [108, 128, 148]:
			draw_line(Vector2(x, 54), Vector2(x - 8, 28), INK, 7, true)


func _panel(rect: Rect2, fill: Color, border: Color, radius: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(radius)
	_styles.append(style)
	draw_style_box(style, rect)


func _text(caption: String, point: Vector2, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, point, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
