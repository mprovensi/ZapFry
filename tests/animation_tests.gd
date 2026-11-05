extends RefCounted

const Session = preload("res://scripts/game_session.gd")
const ArtPack = preload("res://scripts/art_pack.gd")
const Roster = preload("res://scripts/character_roster.gd")
const Portrait = preload("res://scripts/character_portrait.gd")


func run_ui(app, check: Callable) -> void:
	app.level_index = 3
	app.profile.appearance = {"level": 3, "id": "cavaleira", "name": "Zefa do Trovão", "palette": 0, "story": 0, "intro_seen": false}
	app.start_game()
	var cells: Array = app.session.board.cells.duplicate(true)
	var remaining: float = app.session.remaining
	var start_y: float = app.dialogue.bubble.position.y
	check.call(app.operator_view.speaking and not app.room_view.speaking, "Somente o Executor reage à primeira fala")
	app._process(0.09)
	check.call(app.dialogue.bubble.modulate.a > 0.45 and app.dialogue.bubble.modulate.a < 1 and app.dialogue.bubble.position.y < start_y, "Balão entra com deslocamento curto e opacidade crescente")
	var time: float = app.dialogue.presentation_time
	var position: Vector2 = app.dialogue.bubble.position
	var face: Vector2 = app.operator_view.face_offset()
	app.pause_game()
	app._process(10)
	app.resume_game()
	check.call(app.dialogue.presentation_time == time and app.dialogue.bubble.position == position and app.operator_view.face_offset() == face, "Pausa congela a entrada do balão e a reação do ator")
	app._process(0.2)
	check.call(app.dialogue.bubble.modulate.a == 1 and app.dialogue.bubble.position.y == 430, "Balão termina a transição no encaixe original")
	app.dialogue.advance()
	check.call(app.room_view.speaking and not app.operator_view.speaking and app.dialogue.presentation_time == 0, "Segunda fala transfere a reação para o condenado e reinicia a entrada")
	app._process(0.18)
	check.call(app.room_view.face_offset().length() > 0 and app.session.state == Session.State.READY and app.session.remaining == remaining and app.session.board.cells == cells and app.session.moves == 0, "Reação da fala não inicia nem altera o puzzle")
	app.dialogue.close()
	app._sync_controls()
	for actor in [app.operator_view, app.room_view]:
		actor.animation_time = 0.0
		var connection: Vector2 = actor.cable_connection_point()
		actor.animation_time = 3.9
		check.call(actor.cable_connection_point() == connection and actor.face_offset().length() < 0.03, "Movimento fica restrito ao retrato, mantendo cabos e pés no lugar")
	check.call(app.operator_view.blink_amount() > 0.95, "Executor fecha os olhos brevemente no ciclo de espera")
	app.operator_view.animation_time = 4.2
	check.call(app.operator_view.blink_amount() == 0, "Executor reabre os olhos após a piscada")
	for state in [&"anticipation", &"zap", &"recover", &"win"]:
		app.operator_view.state = state
		check.call(app.operator_view.blink_amount() == 0, "Piscada não interfere na alavanca nem na descarga")
	var frames: SpriteFrames = app.art_pack.engineer
	for seconds in [0.0, 0.11, 0.18, 0.25, 0.35, 0.4, 3.0]:
		var pose := ArtPack.sample_transition(frames, &"anticipation", seconds, false, 0.05)
		check.call(pose["texture"] == ArtPack.sample_frames(frames, &"anticipation", seconds) and pose["blend"] >= 0 and pose["blend"] <= 1, "Interpolação preserva a seleção e os limites das poses da alavanca")
	var transition := ArtPack.sample_transition(frames, &"anticipation", 0.11, false, 0.05)
	check.call(transition["blend"] > 0 and transition["blend"] < 1 and transition["next"] != transition["texture"], "Passagem entre poses da alavanca é suavizada")
	check.call(ArtPack.sample_transition(frames, &"anticipation", 3.0, false, 0.05)["blend"] == 0, "Última pose permanece estável sem voltar à chave levantada")
	app.level_index = 0
	app.start_game(false)
	app._on_cell_pressed(1)
	for time_point in [0.0, 0.2, 0.4, 1.0, 1.74, 1.75, 2.2]:
		app.resolution_elapsed = time_point
		app._sync_controls()
		check.call(not app.room_view.speaking and not app.operator_view.speaking, "Resolução não herda a reação da conversa")
		if time_point >= app.SWITCH_PULL_TIME and time_point < app.ZAP_END_TIME:
			check.call(app.room_view.face_offset() == Vector2.ZERO and app.room_view.portrait_texture() == app.execution_character.frame_texture(&"zap", 0), "Esqueleto não recebe deformação facial nem desaparece no choque")
	app.start_game(false)
	check.call(not app.room_view.speaking and not app.operator_view.speaking, "Reiniciar limpa a expressão da fala")
	print("Animações: falas, pausa, piscada, alavanca e integridade da descarga verificadas.")


func run_render(tree: SceneTree, check: Callable) -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/animations")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(512, 512)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	tree.root.add_child(viewport)
	var portrait := Portrait.new()
	portrait.size = Vector2(512, 512)
	viewport.add_child(portrait)
	var pack = load("res://assets/art/concept_v3.tres")
	portrait.set_frame(pack.frame_texture(&"engineer", &"idle", 0))
	var open := await _render(tree, viewport, "executor-open")
	portrait.set_motion(pack.engineer_face_region, Vector2.ZERO, pack.engineer_left_eye, pack.engineer_right_eye, 1.0)
	var closed := await _render(tree, viewport, "executor-blink")
	check.call(_changes(open, closed, Rect2i(320, 95, 100, 38)) > 10, "Piscada modifica os olhos no renderer real")
	check.call(_changes(open, closed, Rect2i(0, 190, 240, 310)) == 0 and _changes(open, closed, Rect2i(280, 270, 230, 230)) == 0, "Piscada preserva gerador, corpo, mão e pés do Executor")
	portrait.set_motion(pack.engineer_face_region, Vector2(0.003, 0.008))
	var talking := await _render(tree, viewport, "executor-speak")
	check.call(_changes(open, talking, Rect2i(250, 35, 200, 155)) > 30 and _changes(open, talking, Rect2i(0, 190, 240, 310)) == 0, "Reação do Executor move a cabeça e mantém o gerador estável")
	portrait.set_frame(pack.frame_texture(&"engineer", &"idle", 0))
	portrait.set_pose_blend(pack.frame_texture(&"engineer", &"anticipation", 0.18), 0.5)
	var blended := await _render(tree, viewport, "lever-transition")
	check.call(_changes(open, blended, Rect2i(120, 30, 300, 240)) > 100 and blended.get_pixel(180, 360).a > 0.99, "Transição entre poses é visível e mantém o gerador opaco")
	for template in Roster.TEMPLATES:
		var character = template.duplicate()
		character.palette_index = 1
		portrait.set_frame(character.frame_texture(&"idle", 0), character)
		var idle := await _render(tree, viewport, template.character_id + "-idle")
		portrait.set_motion(character.face_region, Vector2(0.003, 0.008))
		var response := await _render(tree, viewport, template.character_id + "-speak")
		check.call(_changes(idle, response, Rect2i(160, 80, 195, 130)) > 30, "Condenado reage com a cabeça: " + template.character_id)
		check.call(_changes(idle, response, Rect2i(0, 250, 512, 262)) == 0, "Reação preserva cadeira, roupa, mãos e pés: " + template.character_id)
		portrait.set_frame(character.frame_texture(&"zap", 0), character)
		var skeleton := await _render(tree, viewport, template.character_id + "-zap")
		portrait.set_motion(character.face_region, Vector2.ZERO)
		var preserved := await _render(tree, viewport, "")
		check.call(_changes(skeleton, preserved, Rect2i(0, 0, 512, 512)) == 0, "Descarga mantém o esqueleto e sua paleta intactos: " + template.character_id)
	viewport.queue_free()
	await tree.process_frame


func _render(tree: SceneTree, viewport: SubViewport, name: String) -> Image:
	await tree.process_frame
	await tree.process_frame
	RenderingServer.force_draw()
	var picture := viewport.get_texture().get_image()
	if not name.is_empty():
		picture.save_png("res://builds/animations/" + name + ".png")
	return picture


func _changes(first: Image, second: Image, rect: Rect2i) -> int:
	var changed := 0
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var a := first.get_pixel(x, y)
			var b := second.get_pixel(x, y)
			if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a) > 0.04:
				changed += 1
	return changed
