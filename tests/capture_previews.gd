extends SceneTree
## QA visual com renderer real. Não executar com --headless.

var app


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.sound_enabled = false
	await _capture("01-menu")
	app.sound_enabled = true
	app.show_settings()
	await _capture("63-settings-menu")
	app.close_settings()
	app.sound_enabled = false
	app.start_game(false)
	await _capture("02-gameplay")
	app.pause_game()
	await _capture("03-pause")
	app.sound_enabled = true
	app.show_settings()
	await _capture("64-settings-paused")
	app.close_settings()
	app.sound_enabled = false
	app.start_game(false)
	app._on_cell_pressed(1)
	app.resolution_elapsed = 0.6
	app.board_view.queue_redraw()
	app._sync_controls()
	await _capture("04-zap")
	app._process(app.RESOLUTION_DURATION + 0.1)
	await _capture("05-victory")
	app.show_levels()
	app._open_sector(0)
	await _capture("33-selector-start")
	app._open_sector(1)
	await _capture("34-selector-locked")
	app._overlay_primary()
	await _capture("08-phase-02")
	app.level_index = 2
	app.start_game(false)
	await _capture("09-phase-03")
	app.level_index = 4
	app.start_game(false)
	await _capture("10-phase-05")
	for number in range(6, app.levels.size() + 1):
		app.level_index = number - 1
		app.start_game(false)
		await _capture("%02d-phase-%02d" % [number + 5, number])
	app.level_index = 3
	app.start_game(false)
	app._on_cell_pressed(1)
	app.session.tick(181)
	app._sync_controls()
	await _capture("06-defeat")
	DisplayServer.window_set_size(Vector2i(360, 800))
	app.level_index = 0
	app.start_game(false)
	await _capture("07-narrow-screen")
	app.level_index = 8
	app.start_game(false)
	await _capture("22-phase-09-narrow")
	app.level_index = 15
	app.start_game(false)
	await _capture("23-phase-16-narrow")
	app.level_index = 16
	app.start_game(false)
	await _capture("30-phase-17-narrow")
	app.level_index = 23
	app.start_game(false)
	await _capture("31-phase-24-narrow")
	var audit: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://builds/level-solutions.json"))
	for value in audit["levels"][-1]["moves"]:
		app._on_cell_pressed(int(value))
	app._process(app.RESOLUTION_DURATION + 0.1)
	await _capture("32-campaign-complete")
	# Perfil de QA produzido por partidas da própria engine; não é o save do usuário.
	for report in audit["levels"]:
		app.level_index = int(report["id"]) - 1
		app.start_game(false)
		for value in report["moves"]:
			app.session.tick(2.0)
			app._on_cell_pressed(int(value))
		app._process(app.RESOLUTION_DURATION + 0.1)
	app.show_menu()
	await _capture("38-menu-complete")
	app.show_levels()
	app._open_sector(0)
	await _capture("35-selector-records")
	app._open_sector(2)
	await _capture("36-selector-six-by-six")
	app.level_index = 2
	app.start_game(false)
	app.use_free_hint()
	await _capture("37-free-hint")
	var legacy := ConfigFile.new()
	legacy.set_value("progress", "unlocked_level", 10)
	legacy.set_value("progress", "best_score", 2000)
	legacy.save("res://builds/qa-legacy.cfg")
	app.profile.load_profile("res://builds/qa-legacy.cfg")
	app.sound_enabled = false
	app.show_levels()
	app._open_sector(0)
	await _capture("39-selector-migrated")
	app.level_index = 10
	app.start_game(false)
	await _capture("40-phase-11-calibrated")
	# Reproduz o T já conectado antes da dica (caso relatado no playtest).
	var hint_cases: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://builds/hint-states-input.json"))
	for case in hint_cases["cases"]:
		if case["name"] == "11-valid-tee-11":
			app.levels[10] = case["state"]
			app.start_game(false)
			await _capture("41-phase-11-connected-tee")
			app.use_free_hint()
			await _capture("42-phase-11-contextual-hint")
			break
	app.level_index = 0
	app.start_game(false)
	app.reduced_flashes = false
	app._on_cell_pressed(1)
	app.resolution_elapsed = 0.64
	app._sync_controls()
	await _capture("43-sprites-zap")
	app.resolution_elapsed = app.ZAP_END_TIME + 0.25
	app._sync_controls()
	await _capture("44-sprites-recover")
	app.reduced_flashes = true
	app.resolution_elapsed = 0.64
	app._sync_controls()
	await _capture("45-sprites-soft-zap")
	var original_art = app.art_pack
	var original_character = app.execution_character
	app.execution_character = null
	app.art_pack = load("res://scripts/art_pack.gd").new()
	app.level_index = 10
	app.start_game(false)
	await _capture("46-geometric-fallback")
	app.art_pack.character = original_art.character
	app._sync_controls()
	await _capture("47-partial-art-pack")
	app.art_pack = original_art
	app.execution_character = original_character
	app.levels[10] = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_11.json"))
	app.level_index = 10
	app.start_game(false)
	app._on_cell_pressed(5)
	app.session.tick(app.session.time_limit - 9)
	app._sync_controls()
	await _capture("48-laboratory-low-time")
	app.start_game(false)
	app._on_cell_pressed(5)
	app.board_view._process(0.12)
	await _capture("49-current-sparks")
	app.session.tick(app.session.time_limit + 1)
	app._sync_controls()
	await _capture("50-polished-defeat")
	app.level_index = 0
	app.start_game(false)
	app.reduced_flashes = false
	await _capture("51-goblin-chair-ready")
	app._on_cell_pressed(1)
	app.resolution_elapsed = 0.18
	app._sync_controls()
	await _capture("52-goblin-pulling-switch")
	app.resolution_elapsed = 0.35
	app._sync_controls()
	await _capture("53-goblin-switch-down")
	app.resolution_elapsed = 0.64
	app._sync_controls()
	await _capture("54-goblin-chair-zap")
	app.resolution_elapsed = app.ZAP_END_TIME + 0.25
	app._sync_controls()
	await _capture("55-goblin-chair-recover")
	app.reduced_flashes = true
	app.resolution_elapsed = 0.64
	app._sync_controls()
	await _capture("56-goblin-chair-soft-zap")
	app.start_game(false)
	app.reduced_flashes = false
	app._on_cell_pressed(1)
	for sample in [[0.48, "57-background-flash-first"], [0.98, "58-background-flash-second"], [1.48, "59-background-flash-third"], [1.67, "60-execution-extended"]]:
		app.resolution_elapsed = sample[0]
		app._sync_controls()
		await _capture(sample[1])
		if sample[1] == "57-background-flash-first" and not await _verify_flash_over_board():
			quit(1)
			return
	app.reduced_flashes = true
	app.resolution_elapsed = 1.075
	app._sync_controls()
	await _capture("61-soft-background-glow")
	app.resolution_elapsed = app.ZAP_END_TIME + 0.25
	app._sync_controls()
	await _capture("62-background-impact-ended")
	print("Capturas salvas em builds/previews.")
	quit()


func _verify_flash_over_board() -> bool:
	# Uma placa vazia é estática: o pixel deve clarear com o flash, mesmo sobre a matriz opaca.
	var point: Vector2 = root.get_final_transform() * app.board_view.get_global_transform_with_canvas() * app.board_view.cell_rect(14).get_center()
	var pixel := Vector2i(point)
	var image := root.get_texture().get_image()
	if not Rect2i(Vector2i.ZERO, image.get_size()).has_point(pixel):
		push_error("Amostra do clarão está fora da imagem: " + str(pixel))
		return false
	var lit := image.get_pixelv(pixel).get_luminance()
	app.shock_flash.hide()
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	var unlit := root.get_texture().get_image().get_pixelv(pixel).get_luminance()
	app._sync_controls()
	var passed := lit > unlit + 0.04
	var output := FileAccess.open("res://builds/flash-render-check.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"lit": lit, "unlit": unlit, "passed": passed}, "\t"))
	output.close()
	if not passed:
		push_error("O clarão não apareceu no pixel da matriz: %.4f / %.4f" % [lit, unlit])
	else:
		print("Clarão renderizado sobre a matriz: %.4f / %.4f." % [lit, unlit])
	return passed


func _capture(filename: String) -> void:
	app.queue_redraw()
	app.overlay.queue_redraw()
	await process_frame
	await process_frame
	# Telas estáticas podem não emitir outro frame_post_draw em modo econômico.
	RenderingServer.force_draw()
	var screenshot := root.get_texture().get_image()
	var error := screenshot.save_png("res://builds/previews/" + filename + ".png")
	if error != OK:
		push_error("Erro ao salvar captura: " + error_string(error))
		quit(1)
