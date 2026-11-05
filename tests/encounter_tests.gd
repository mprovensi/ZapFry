extends RefCounted

const Stories = preload("res://scripts/encounter_stories.gd")
const Roster = preload("res://scripts/character_roster.gd")
const Profile = preload("res://scripts/player_profile.gd")
const Portrait = preload("res://scripts/character_portrait.gd")
const Session = preload("res://scripts/game_session.gd")
const DialogueView = preload("res://scripts/dialogue_view.gd")


func run(check: Callable) -> void:
	check.call(Stories.CASES.size() == 48, "Catálogo ampliado tem 48 micro-histórias")
	var unique_stories: Dictionary = {}
	for story in Stories.CASES:
		check.call(not unique_stories.has(str(story)), "Conversas cadastradas não são duplicadas")
		unique_stories[str(story)] = true
		check.call(story.size() == 2, "História tem somente uma fala do Executor e uma do condenado")
		for line in story:
			check.call(line is String and not line.is_empty(), "Falas são textos locais não vazios")
	var roster := Roster.new(1700)
	for story_id in Stories.RESTRICTIONS:
		for template in Roster.TEMPLATES:
			check.call((story_id in Stories.eligible(template.character_id)) == (Stories.RESTRICTIONS[story_id] == template.character_id), "Conversa específica só aparece para a base compatível")
	var last_story := roster.select(0, {"level": 0, "id": "elfa", "name": "Líria Faísca", "palette": 0, "story": 47, "intro_seen": true})
	check.call(last_story["snapshot"]["story"] == 47 and last_story["snapshot"]["intro_seen"], "Último caso novo pode ser restaurado sem trocar a conversa")
	var combinations: Dictionary = {}
	var speaker_colors := {DialogueView.EXECUTOR_COLOR: true}
	for template in Roster.TEMPLATES:
		check.call(not speaker_colors.has(template.dialogue_color), "Cada personagem possui uma cor de balão distinta, incluindo o Executor")
		speaker_colors[template.dialogue_color] = true
		for name in template.aliases:
			for palette in range(4):
				var selected := roster.select(0, {"level": 0, "id": template.character_id, "name": name, "palette": palette, "story": 0, "intro_seen": true})
				var snapshot: Dictionary = selected["snapshot"]
				combinations[str([snapshot["id"], snapshot["name"], snapshot["palette"]])] = true
				check.call(selected["character"].palette_index == palette and snapshot["intro_seen"], "Nome e paleta selecionados chegam à instância")
		check.call(template.palette_index == 0, "Templates não são recoloridos pelo sorteio")
	check.call(combinations.size() == 140, "Sete bases, cinco nomes e quatro cores geram 140 combinações")
	var prior := -1
	for level in range(24):
		var selected := roster.select(level, {})
		var snapshot: Dictionary = selected["snapshot"]
		check.call(snapshot["story"] in Stories.eligible(snapshot["id"]) and snapshot["story"] != prior, "História sorteada é compatível e evita repetição imediata")
		prior = snapshot["story"]
	var profile := Profile.new()
	profile.appearance = roster.select(0, {})["snapshot"]
	profile.appearance["intro_seen"] = true
	var path := "res://builds/encounter-profile.cfg"
	check.call(profile.save_profile(path) == OK, "Encontro completo pode ser salvo")
	var restored := Profile.new()
	check.call(restored.load_profile(path) == OK and restored.appearance == profile.appearance, "Cor, história e introdução vista sobrevivem à reabertura")
	var old := roster.select(0, {"level": 0, "id": "cavaleira", "name": "Zefa do Trovão"})
	check.call(old["snapshot"]["palette"] == 0 and not old["snapshot"]["intro_seen"], "Perfil v5 conserva cor original e recebe uma introdução")
	var bad := roster.select(0, {"level": 0, "id": "pirata", "name": "Zeca Maré", "palette": 99, "story": 3, "intro_seen": true})
	check.call(bad["snapshot"]["palette"] in range(4) and bad["snapshot"]["story"] in Stories.eligible("pirata") and not bad["snapshot"]["intro_seen"], "Dados inválidos recebem fallback compatível sem pular introdução nova")


func run_ui(app, tree: SceneTree, check: Callable) -> void:
	app.level_index = 3
	app.profile.appearance = {"level": 3, "id": "cavaleira", "name": "Zefa do Trovão", "palette": 2, "story": 0, "intro_seen": false}
	app.start_game()
	var remaining: float = app.session.remaining
	var cells: Array = app.session.board.cells.duplicate(true)
	var snapshot: Dictionary = app.profile.appearance.duplicate()
	check.call(app.dialogue.active and app.dialogue.visible and not app.board_view.interactive, "Conversa abre antes do puzzle e bloqueia a grade")
	check.call(app.dialogue.speaker.text == "Executor" and not _has_step_labels(app.dialogue), "Primeiro balão identifica o Executor sem contador de passos")
	check.call(app.dialogue.speaker.get_theme_font_size("font_size") >= 32 and app.dialogue.nameplate.get_rect().encloses(app.dialogue.speaker.get_rect()), "Nome ampliado fica destacado e contido na tarja")
	check.call(app.dialogue.body.get_theme_font_size("font_size") == 40, "Falas usam fonte maior de 40 unidades")
	var executor_style: StyleBoxFlat = app.dialogue.bubble.get_theme_stylebox("panel")
	check.call(executor_style.border_width_left >= 6 and executor_style.bg_color.get_luminance() > 0.75 and app.dialogue.body.get_theme_color("font_color").get_luminance() < 0.1, "Balão de quadrinho usa papel claro, texto escuro e contorno marcado")
	var executor_color := executor_style.bg_color
	app._on_cell_pressed(1)
	app.use_free_hint()
	app._process(60)
	check.call(app.session.state == Session.State.READY and app.session.moves == 0 and app.session.hints_used == 0 and app.session.remaining == remaining and app.session.board.cells == cells, "Conversa não consome tempo, gira fios nem usa dicas")
	await _click(tree, app.dialogue.advance_button.get_global_rect().get_center())
	check.call(app.dialogue.step == 1 and app.dialogue.speaker.text == app.execution_character.display_name, "Resposta mostra o nome do condenado")
	var subject_style: StyleBoxFlat = app.dialogue.bubble.get_theme_stylebox("panel")
	check.call(subject_style.bg_color != executor_color and subject_style.bg_color == app.execution_character.dialogue_color.lerp(DialogueView.PAPER, 0.85) and not _has_step_labels(app.dialogue), "Resposta mantém a cor do condenado sem contador de passos")
	await _click(tree, app.buttons["pause"].get_global_rect().get_center())
	check.call(app.session.state == Session.State.PAUSED and app.dialogue.active and not app.dialogue.visible, "Pausa do cabeçalho funciona durante a conversa")
	app.show_settings()
	app._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	app._process(120)
	app.close_settings()
	app.resume_game()
	check.call(app.dialogue.visible and app.dialogue.step == 1 and app.profile.appearance == snapshot and app.session.remaining == remaining, "Ajustes e segundo plano preservam fala, encontro e relógio")
	await _tap(tree, app.dialogue.advance_button.get_global_rect().get_center())
	check.call(not app.dialogue.active and app.profile.appearance["intro_seen"] and app.session.moves == 0 and app.board_view.interactive, "Começar no segundo balão fecha a introdução sem terceira fala nem giro")
	var released := InputEventMouseButton.new()
	released.device = -1
	released.button_index = MOUSE_BUTTON_LEFT
	released.position = app.board_view.get_global_rect().get_center()
	tree.root.push_input(released, true)
	check.call(app.session.moves == 0, "Mouse emulado após o último toque não altera o painel")
	app.start_game(false)
	check.call(not app.dialogue.active and app.profile.appearance["intro_seen"], "Reiniciar vai direto ao puzzle")
	app.level_index = 4
	app.start_game()
	check.call(app.dialogue.active, "Fase seguinte apresenta outro encontro")
	await _click(tree, app.dialogue.skip_button.get_global_rect().get_center())
	check.call(not app.dialogue.active and app.profile.appearance["intro_seen"] and app.session.moves == 0, "Pular libera o puzzle e salva a introdução vista")
	app.level_index = 5
	app.start_game()
	await _key(tree, KEY_ENTER)
	check.call(app.dialogue.step == 1, "Enter avança exatamente uma fala")
	var step_before: int = app.dialogue.step
	var point: Vector2 = app.dialogue.body.get_global_rect().get_center()
	var press := InputEventScreenTouch.new()
	press.position = point
	press.pressed = true
	tree.root.push_input(press, true)
	app.pause_game()
	app.resume_game()
	press = InputEventScreenTouch.new()
	press.position = point
	press.pressed = false
	tree.root.push_input(press, true)
	check.call(app.dialogue.step == step_before, "Gesto interrompido pela pausa não avança ao retornar")
	await _key(tree, KEY_ESCAPE)
	check.call(app.session.state == Session.State.PAUSED and app.dialogue.active, "Escape abre a pausa sem pular a conversa")
	app.resume_game()
	await _click(tree, app.dialogue.skip_button.get_global_rect().get_center())
	app.level_index = 6
	app.start_game()
	await _tap(tree, app.dialogue.body.get_global_rect().get_center())
	check.call(app.dialogue.step == 1 and app.dialogue.active, "Toque nativo avança da fala do Executor para a resposta")
	await _tap(tree, app.dialogue.body.get_global_rect().get_center())
	check.call(not app.dialogue.active and app.session.moves == 0, "Segundo toque no balão inicia a fase sem terceira fala nem giro")
	for template in Roster.TEMPLATES:
		app.profile.appearance = {"level": app.level_index, "id": template.character_id, "name": template.display_name, "palette": 0, "story": 0, "intro_seen": false}
		app.start_game()
		var style: StyleBoxFlat = app.dialogue.bubble.get_theme_stylebox("panel")
		check.call(app.dialogue.speaker.text == "Executor" and style.bg_color == DialogueView.EXECUTOR_COLOR.lerp(DialogueView.PAPER, 0.85), "Novo encontro restaura nome e cor do Executor")
		app.dialogue.advance()
		check.call(style.bg_color == template.dialogue_color.lerp(DialogueView.PAPER, 0.85) and app.dialogue.speaker.text == template.display_name, "Cada base recebe sua própria cor de resposta na partida")
		var name_font: Font = app.dialogue.speaker.get_theme_font("font")
		for name in template.aliases:
			app.dialogue.begin(Stories.CASES[0], name, template.dialogue_color)
			app.dialogue.advance()
			check.call(name_font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, app.dialogue.speaker.get_theme_font_size("font_size")).x <= app.dialogue.speaker.size.x, "Nome cabe no cabeçalho ampliado: " + name)
			check.call(app.dialogue.bubble.get_rect().size.x >= app.dialogue.nameplate.get_rect().end.x and app.dialogue.nameplate.get_rect().encloses(app.dialogue.speaker.get_rect()), "Tarja acompanha nomes longos sem cortar a identificação")
		app.dialogue.finish()
		await tree.process_frame
	for dimensions in [Vector2(360, 800), Vector2(720, 1280), Vector2(720, 1600)]:
		app.size = dimensions
		app._layout_stage()
		for story in Stories.CASES:
			app.dialogue.begin(story, "Zefa do Trovão", app.execution_character.dialogue_color)
			for step in range(2):
				await tree.process_frame
				check.call(app.get_global_rect().encloses(app.dialogue.bubble.get_global_rect()), "Balão cabe na tela em todas as dimensões")
				var font: Font = app.dialogue.body.get_theme_font("font")
				var height: float = font.get_height(app.dialogue.body.get_theme_font_size("font_size")) * app.dialogue.body.get_line_count()
				check.call(height <= app.dialogue.body.size.y + 1, "Todas as falas cabem sem cortar texto")
				app.dialogue.advance()
			await tree.process_frame
	app.dialogue.close()
	app.start_game(false)
	print("Encontros: 48 histórias, 140 combinações, navegação, toque e texto em três proporções verificados.")


func _has_step_labels(dialogue) -> bool:
	for label in dialogue.bubble.find_children("*", "Label", true, false):
		if label.text in ["1 / 2", "2 / 2", "1/2", "2/2"]:
			return true
	return false


func run_render(tree: SceneTree, check: Callable) -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/encounters")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(2048, 512)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	tree.root.add_child(viewport)
	var portraits: Array = []
	for index in range(4):
		var portrait := Portrait.new()
		portrait.position = Vector2(index * 512, 0)
		portrait.size = Vector2(512, 512)
		viewport.add_child(portrait)
		portraits.append(portrait)
	for template in Roster.TEMPLATES:
		for state in [&"idle", &"zap", &"recover"]:
			for palette in range(4):
				var character = template.duplicate()
				character.palette_index = palette
				portraits[palette].set_frame(template.frame_texture(state, 0), character)
			await tree.process_frame
			await tree.process_frame
			RenderingServer.force_draw()
			var picture := viewport.get_texture().get_image()
			picture.save_png("res://builds/encounters/%s-%s-palettes.png" % [template.character_id, state])
			for palette in range(1, 4):
				var changed := _changed_pixels(picture, palette, Rect2i(125, 200, 260, 250))
				check.call(changed > 50, "Paleta realmente modifica o traje renderizado: %s/%s/%d" % [template.character_id, state, palette])
				check.call(_changed_pixels(picture, palette, Rect2i(210, 118, 96, 54)) == 0, "Cor preserva rosto/pele do personagem")
				check.call(_changed_pixels(picture, palette, Rect2i(153, 330, 12, 90)) == 0, "Cor preserva a madeira da cadeira")
				if state == &"zap":
					check.call(_bright_bones_unchanged(picture, palette), "Paleta preserva os ossos e o brilho do esqueleto")
			check.call(portraits[1].material != portraits[2].material and template.palette_index == 0, "Instâncias usam materiais independentes")
	viewport.queue_free()
	await tree.process_frame


func _changed_pixels(picture: Image, palette: int, rect: Rect2i) -> int:
	var changed := 0
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var a := picture.get_pixel(x, y)
			var b := picture.get_pixel(x + 512 * palette, y)
			if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a) > 0.04:
				changed += 1
	return changed


func _bright_bones_unchanged(picture: Image, palette: int) -> bool:
	var sampled := 0
	for y in range(205, 440):
		for x in range(170, 345):
			var a := picture.get_pixel(x, y)
			if a.a > 0.95 and a.g > 0.85 and a.b > 0.85 and a.r < 0.75:
				sampled += 1
				var b := picture.get_pixel(x + 512 * palette, y)
				if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.04:
					return false
	return sampled > 10


func _click(tree: SceneTree, point: Vector2) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		tree.root.push_input(event, true)
		await tree.process_frame
	await tree.process_frame


func _tap(tree: SceneTree, point: Vector2) -> void:
	for pressed in [true, false]:
		var event := InputEventScreenTouch.new()
		event.position = point
		event.index = 0
		event.pressed = pressed
		tree.root.push_input(event, true)
		await tree.process_frame
	await tree.process_frame


func _key(tree: SceneTree, code: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.pressed = pressed
		tree.root.push_input(event, true)
		await tree.process_frame
