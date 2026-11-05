extends SceneTree
## QA das poses finais e da integração; não usa o perfil real.

const Roster = preload("res://scripts/character_roster.gd")


func _initialize() -> void:
	if not "--test" in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		push_error("Usar renderer real e -- --test.")
		quit(1)
		return
	call_deferred("_run")


func _run() -> void:
	await _capture_all()
	call_deferred("quit")


func _capture_all() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/characters")
	DisplayServer.window_set_size(Vector2i(360, 800))
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.board_view.set_process(false)
	app.sound_enabled = false
	app.reduced_flashes = false
	for template in Roster.TEMPLATES:
		app.profile.appearance = {"level": 0, "id": template.character_id, "name": template.display_name}
		app.level_index = 0
		app.start_game(false)
		await _game_image(app, template.character_id + "-idle")
		app._on_cell_pressed(1)
		app.resolution_elapsed = 0.6
		app._sync_controls()
		await _game_image(app, template.character_id + "-zap")
		app.resolution_elapsed = 1.95
		app._sync_controls()
		await _game_image(app, template.character_id + "-recover")
	app.queue_free()
	await process_frame
	await _pose_sheet()
	print("Cinco condenados: 15 capturas da partida e prancha de poses salvas.")


func _game_image(app, name: String) -> void:
	app.queue_redraw()
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://builds/characters/" + name + ".png")


func _pose_sheet() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1800, 1300)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var fill := ColorRect.new()
	fill.size = viewport.size
	fill.color = Color("09141e")
	viewport.add_child(fill)
	for index in range(Roster.TEMPLATES.size()):
		var template = Roster.TEMPLATES[index]
		var label := Label.new()
		label.position = Vector2(index * 360, 14)
		label.size = Vector2(360, 50)
		label.text = template.display_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 26)
		viewport.add_child(label)
		for row in range(3):
			var state: StringName = [&"idle", &"zap", &"recover"][row]
			var picture := TextureRect.new()
			picture.position = Vector2(index * 360 + 5, 60 + row * 410)
			picture.size = Vector2(350, 380)
			picture.texture = template.frame_texture(state, 0)
			picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			viewport.add_child(picture)
			var caption := Label.new()
			caption.position = Vector2(index * 360, 427 + row * 410)
			caption.size = Vector2(360, 36)
			caption.text = ["ESPERA", "CHOQUE", "RECUPERAÇÃO"][row]
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			caption.add_theme_font_size_override("font_size", 19)
			viewport.add_child(caption)
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	viewport.get_texture().get_image().save_png("res://builds/characters/poses.png")
	viewport.queue_free()
	await process_frame
