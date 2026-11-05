extends SceneTree
## Prévia de seis segundos a 30 FPS; nunca usa o perfil do jogador.


func _initialize() -> void:
	if not "--test" in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		quit(1)
		return
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/animations/preview")
	DisplayServer.window_set_size(Vector2i(360, 800))
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.board_view.set_process(false)
	app.sound_enabled = false
	app.pulse = 3.4
	app.profile.appearance = {"level": 0, "id": "cavaleira", "name": "Zefa do Trovão", "palette": 3, "story": 0, "intro_seen": false}
	app.start_game()
	for frame in range(180):
		if frame == 36:
			app.dialogue.advance()
		if frame == 72:
			app.dialogue.finish()
			await process_frame
		if frame == 75:
			app._on_cell_pressed(1)
		app._process(1.0 / 30.0)
		app.queue_redraw()
		await process_frame
		await process_frame
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://builds/animations/preview/%04d.png" % frame)
	app.queue_free()
	await process_frame
	print("Prévia: 180 quadros de diálogos, piscada, alavanca, choque e recuperação.")
	call_deferred("quit")
