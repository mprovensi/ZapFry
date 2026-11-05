extends SceneTree
## Prévias isoladas: não altera recursos da campanha nem o perfil do jogador.

const BASE := "res://test_sprites/condemned_v1/"
const Character = preload("res://scripts/execution_character.gd")
var failures := 0


func _initialize() -> void:
	if not "--test" in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		push_error("Usar renderer real e -- --test.")
		quit(1)
		return
	call_deferred("_run")


func _run() -> void:
	await _create_previews()
	call_deferred("quit", 1 if failures else 0)


func _create_previews() -> void:
	DirAccess.make_dir_recursive_absolute(BASE + "previews")
	var entries: Array = JSON.parse_string(FileAccess.get_file_as_string(BASE + "characters.json"))
	var textures: Array[Texture2D] = []
	var screenshots: Array[Texture2D] = []
	DisplayServer.window_set_size(Vector2i(360, 800))
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.board_view.set_process(false)
	app.sound_enabled = false
	if app.persistence_enabled:
		push_error("Perfil precisa estar isolado.")
		failures += 1
		return
	var background: Texture2D = app.art_pack.game_background
	var floor_texture: Texture2D = app.art_pack.room_floor
	for entry in entries:
		var image := Image.load_from_file(ProjectSettings.globalize_path(BASE + entry["file"]))
		if image == null or image.is_empty() or not image.detect_alpha():
			push_error("Sprite ausente ou sem alpha: " + entry["file"])
			failures += 1
			app.queue_free()
			return
		var texture := ImageTexture.create_from_image(image)
		textures.append(texture)
		var frames := SpriteFrames.new()
		frames.add_animation(&"idle")
		frames.add_frame(&"idle", texture)
		var character := Character.new()
		character.display_name = entry["name"]
		character.portrait = frames
		app.level_index = 0
		app.start_game()
		app.execution_character = character
		app._sync_controls()
		await process_frame
		await process_frame
		RenderingServer.force_draw()
		var screenshot := root.get_texture().get_image()
		_save(screenshot, "game-" + entry["id"])
		screenshots.append(ImageTexture.create_from_image(screenshot))
	app.queue_free()
	await process_frame
	await _sheet(entries, textures, background, floor_texture, false)
	await _sheet(entries, screenshots, background, floor_texture, true)
	print("Prévia: cinco PNGs com alpha e cinco capturas da partida; %d falhas." % failures)


func _sheet(entries: Array, textures: Array[Texture2D], background: Texture2D, floor_texture: Texture2D, gameplay: bool) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(2000, 1100 if gameplay else 920)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Control.new()
	canvas.size = viewport.size
	viewport.add_child(canvas)
	var fill := ColorRect.new()
	fill.size = canvas.size
	fill.color = Color("09141e")
	canvas.add_child(fill)
	_label(canvas, "ZAP & FRY / CONDENADOS", Rect2(40, 24, 1920, 62), 43, Color("ffce49"))
	_label(canvas, "ENCAIXE NA PARTIDA · 360 × 800" if gameplay else "CINCO PERSONAGENS · POSE DE ESPERA", Rect2(40, 88, 1920, 42), 24, Color("94adb8"))
	for index in range(entries.size()):
		var x := 40 + index * 388
		_label(canvas, entries[index]["name"], Rect2(x, 151, 368, 45), 29, Color("f1eee1"))
		_label(canvas, entries[index]["role"], Rect2(x, 197, 368, 35), 21, Color("94adb8"))
		if gameplay:
			_picture(canvas, textures[index], Rect2(x + 4, 256, 360, 800), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		else:
			_picture(canvas, background, Rect2(x, 252, 368, 554), TextureRect.STRETCH_SCALE)
			var atlas := AtlasTexture.new()
			atlas.atlas = textures[index]
			atlas.region = _solid_bounds(textures[index].get_image())
			_picture(canvas, floor_texture, Rect2(x, 731, 368, 75), TextureRect.STRETCH_SCALE)
			_picture(canvas, atlas, Rect2(x + 15, 262, 338, 485), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	if not gameplay:
		_label(canvas, "PRÉVIAS DE ARTE · choque, recuperação, paletas e diálogos serão a próxima etapa.", Rect2(40, 837, 1920, 40), 24, Color("94adb8"))
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	_save(viewport.get_texture().get_image(), "prancha-jogo" if gameplay else "prancha-personagens")
	viewport.queue_free()
	await process_frame


func _picture(parent: Node, texture: Texture2D, rect: Rect2, mode: TextureRect.StretchMode) -> void:
	var picture := TextureRect.new()
	picture.position = rect.position
	picture.size = rect.size
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = mode
	picture.texture = texture
	parent.add_child(picture)


func _label(parent: Node, text: String, rect: Rect2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)


func _save(image: Image, name: String) -> void:
	if image.save_png(BASE + "previews/" + name + ".png") != OK:
		failures += 1
		push_error("Não foi possível salvar a prévia: " + name)


func _solid_bounds(image: Image) -> Rect2:
	# Franjas de alpha quase invisível não devem mudar a escala na prancha.
	# Somente o recorte de exibição muda; o PNG original permanece intacto.
	var start := image.get_size()
	var end := Vector2i.ZERO
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.125:
				start = start.min(Vector2i(x, y))
				end = end.max(Vector2i(x + 1, y + 1))
	return Rect2(Vector2(start), Vector2(end - start))
