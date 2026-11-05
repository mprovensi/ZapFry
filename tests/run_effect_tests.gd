extends SceneTree
## Testes de impacto com OpenGL real; executar tools/dev.ps1 effects-test.

const EffectTests = preload("res://tests/execution_effect_tests.gd")
const EncounterTests = preload("res://tests/encounter_tests.gd")
var checks := 0
var failures := 0
var render_results: Array[Dictionary] = []


func _initialize() -> void:
	if not "--test" in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		push_error("Executar com renderer real e -- --test para proteger o perfil.")
		quit(1)
		return
	call_deferred("_run")


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/effects")
	await _exercise()
	var output := FileAccess.open("res://builds/effects/results.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks": checks, "failures": failures, "render": render_results,
		"hardware_haptics_verified": false}, "\t"))
	output.close()
	print("Impacto automatizado: %d verificações; %d falhas; %d dimensões renderizadas." % [checks, failures, render_results.size()])
	call_deferred("quit", 1 if failures > 0 else 0)


func _exercise() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.board_view.set_process(false)
	_check(not app.persistence_enabled, "Testes não podem gravar o perfil do jogador")
	EffectTests.new().run_ui(app, _check)
	for dimensions in [Vector2i(360, 800), Vector2i(720, 1280), Vector2i(720, 1600)]:
		DisplayServer.window_set_size(dimensions)
		await process_frame
		await process_frame
		app._layout_stage()
		await _test_render(app, dimensions)
	app.queue_free()
	await process_frame
	await EncounterTests.new().run_render(self, _check)


func _test_render(app, dimensions: Vector2i) -> void:
	var label := "%dx%d" % [dimensions.x, dimensions.y]
	app.level_index = 0
	app.start_game(false)
	app._on_cell_pressed(1)
	app.resolution_elapsed = 0.48
	app.reduced_flashes = true
	app._sync_controls()
	app.shock_flash.hide()
	var stable: Image = await _render(app)
	_check(stable.get_size() == dimensions, "Captura tem a dimensão solicitada: " + label)
	app.reduced_flashes = false
	app._sync_controls()
	app.shock_flash.hide()
	var shaken: Image = await _render(app)
	var transform: Transform2D = root.get_final_transform() * app.stage.get_global_transform_with_canvas()
	# Faixa de parede fora da matriz e dos atores; o clarão está desligado nesta comparação.
	var wall := _pixel_rect(transform, Rect2(8, 470, 24, 500), stable.get_size())
	var header := _pixel_rect(transform, Rect2(0, 0, 720, 120), stable.get_size())
	var board_transform: Transform2D = root.get_final_transform() * app.board_view.get_global_transform_with_canvas()
	var plate: Rect2 = app.board_view.cell_rect(14).grow(-18)
	var plate_pixels := _pixel_rect(board_transform, plate, stable.get_size())
	var wall_change := _difference(stable, shaken, wall)
	var header_change := _difference(stable, shaken, header)
	var header_displacement := _foreground_mask_change(stable, shaken, header)
	var plate_change := _difference(stable, shaken, plate_pixels)
	_check(wall_change > 0.0001, "Tremor move os pixels reais da parede: " + label)
	# O painel do cabeçalho é translúcido: a parede pode variar atrás dele.
	# A máscara de texto/ícones detecta deslocamento sem confundir essa variação.
	_check(header_displacement < 0.01, "Tremor não desloca texto e ícones do cabeçalho: " + label)
	_check(plate_change < 0.00001, "Tremor não desloca a matriz renderizada: " + label)
	_check(_edges_covered(stable, shaken, transform), "Tremor não abre bordas vazias na sala: " + label)
	# Mesma imagem e mesmo instante, agora com a camada de clarão ativa.
	app.shock_flash.show()
	var flashed: Image = await _render(app)
	var unlit := _luminance(shaken, plate_pixels)
	var lit := _luminance(flashed, plate_pixels)
	_check(lit > unlit + 0.04, "Clarão ilumina a placa opaca durante o tremor: " + label)
	_check(_difference(shaken, flashed, header) < 0.00001, "Clarão deixa o cabeçalho livre: " + label)
	for entry in [["soft-stable", stable], ["normal-shake", shaken], ["normal-flash", flashed]]:
		_check(entry[1].save_png("res://builds/effects/%s-%s.png" % [label, entry[0]]) == OK, "Captura de evidência salva: " + label)
	# Depois do choque, os modos devem desenhar o cenário novamente na mesma posição.
	app.resolution_elapsed = app.ZAP_END_TIME + 0.1
	app._sync_controls()
	var recovered: Image = await _render(app)
	app.reduced_flashes = true
	app._sync_controls()
	var soft_recovered: Image = await _render(app)
	_check(_difference(recovered, soft_recovered, wall) < 0.00001, "Parede volta à posição original após o choque: " + label)
	render_results.append({"size": label, "wall_change": wall_change, "header_change": header_change,
		"header_displacement": header_displacement, "plate_change": plate_change, "flash_lit": lit, "flash_unlit": unlit})
	print("Render %s: parede %.6f; cabeçalho %.6f; matriz %.6f; clarão %.4f / %.4f." % [label, wall_change, header_change, plate_change, lit, unlit])


func _render(app) -> Image:
	app.queue_redraw()
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	return root.get_texture().get_image()


func _pixel_rect(transform: Transform2D, rect: Rect2, image_size: Vector2i) -> Rect2i:
	var start := Vector2i((transform * rect.position).ceil())
	var end := Vector2i((transform * rect.end).floor())
	return Rect2i(start, end - start).intersection(Rect2i(Vector2i.ZERO, image_size))


func _difference(first: Image, second: Image, rect: Rect2i) -> float:
	if not rect.has_area():
		return INF
	var total := 0.0
	var count := 0
	for y in range(rect.position.y, rect.end.y, 2):
		for x in range(rect.position.x, rect.end.x, 2):
			var a := first.get_pixel(x, y)
			var b := second.get_pixel(x, y)
			total += absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)
			count += 3
	return total / maxi(1, count)


func _luminance(picture: Image, rect: Rect2i) -> float:
	if not rect.has_area():
		return 0
	var total := 0.0
	var count := 0
	for y in range(rect.position.y, rect.end.y, 2):
		for x in range(rect.position.x, rect.end.x, 2):
			total += picture.get_pixel(x, y).get_luminance()
			count += 1
	return total / maxi(1, count)


func _foreground_mask_change(first: Image, second: Image, rect: Rect2i) -> float:
	var foreground := 0
	var displaced := 0
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var a := first.get_pixel(x, y).get_luminance() > 0.55
			var b := second.get_pixel(x, y).get_luminance() > 0.55
			if a or b:
				foreground += 1
				if a != b:
					displaced += 1
	return float(displaced) / foreground if foreground > 0 else INF


func _edges_covered(stable: Image, shaken: Image, transform: Transform2D) -> bool:
	var checked := 0
	var empty := Color("09141e")
	for x in [0.5, 719.5]:
		for y in range(450, 1000, 8):
			var point := Vector2i(transform * Vector2(x, y))
			if not Rect2i(Vector2i.ZERO, stable.get_size()).has_point(point):
				return false
			var before := stable.get_pixelv(point)
			var after := shaken.get_pixelv(point)
			var previous_distance := absf(before.r - empty.r) + absf(before.g - empty.g) + absf(before.b - empty.b)
			if previous_distance > 0.03:
				checked += 1
				if absf(after.r - empty.r) + absf(after.g - empty.g) + absf(after.b - empty.b) < 0.003:
					return false
	return checked >= 16
