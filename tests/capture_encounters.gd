extends SceneTree


func _initialize() -> void:
	if not "--test" in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		push_error("Usar renderer real e -- --test.")
		quit(1)
		return
	call_deferred("_run")


func _run() -> void:
	await _capture()
	call_deferred("quit")


func _capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/encounters")
	DisplayServer.window_set_size(Vector2i(360, 800))
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.board_view.set_process(false)
	app.sound_enabled = false
	app.profile.appearance = {"level": 0, "id": "cavaleira", "name": "Zefa do Trovão", "palette": 3, "story": 0, "intro_seen": false}
	app.start_game()
	await _shot(app, "intro-executor")
	app.dialogue.advance()
	await _shot(app, "intro-condenado")
	app.dialogue.finish()
	await process_frame
	await _shot(app, "palette-gameplay")
	app._on_cell_pressed(1)
	app.resolution_elapsed = 0.6
	app._sync_controls()
	await _shot(app, "palette-zap")
	app._process(app.RESOLUTION_DURATION)
	await _shot(app, "palette-result")
	app.queue_free()
	await process_frame
	print("Balões, paleta na partida, esqueleto e resultado capturados.")


func _shot(app, name: String) -> void:
	if app.dialogue.active and app.dialogue.presentation_time < 0.18:
		app._process(0.18 - app.dialogue.presentation_time)
	app.queue_redraw()
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://builds/encounters/" + name + ".png")
