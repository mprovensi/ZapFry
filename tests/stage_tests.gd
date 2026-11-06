extends RefCounted

const Session = preload("res://scripts/game_session.gd")
const ExecutionCharacter = preload("res://scripts/execution_character.gd")


func run_ui(app, check: Callable) -> void:
	var pack = app.art_pack
	var character = app.execution_character
	var raised: Texture2D = pack.frame_texture(&"engineer", &"idle", 0.0)
	var middle: Texture2D = pack.frame_texture(&"engineer", &"anticipation", 0.18)
	var lowered: Texture2D = pack.frame_texture(&"engineer", &"anticipation", 0.35)
	check.call(raised != null and middle != raised and lowered != middle and lowered != raised, "Goblin tem três poses distintas para abaixar a chave")
	check.call(pack.frame_texture(&"engineer", &"zap", 0.0) == lowered, "A chave fica abaixada durante a descarga")
	for state in [&"idle", &"worried", &"anticipation", &"zap", &"zap_soft", &"recover", &"win", &"lose"]:
		check.call(character.frame_texture(state, 0.0) != null, "Personagem independente tem estado " + state)
	var skeleton: Texture2D = character.frame_texture(&"zap", 0.1)
	check.call(character.frame_texture(&"zap", 0.1, true) == skeleton and character.frame_texture(&"zap", 0.1) == skeleton, "Esqueleto aparece durante o choque nos modos normal e suave")
	check.call(pack.menu_portrait != raised, "Menu tem arte independente do goblin da partida")
	for viewport in [Vector2(720, 1280), Vector2(360, 800), Vector2(720, 1600)]:
		app.size = viewport
		app.level_index = 23
		app.start_game(false)
		app._layout_stage()
		var operator: Rect2 = app.operator_view.get_global_rect()
		var board: Rect2 = app.board_view.get_global_rect()
		var subject: Rect2 = app.room_view.get_global_rect()
		check.call(operator.end.y < board.position.y and board.end.y < subject.position.y, "Goblin, grade e cadeira mantêm a ordem vertical")
		check.call(board.position.y - operator.end.y <= 16 * app.stage.scale.y and subject.position.y - board.end.y <= 16 * app.stage.scale.y, "Atores ficam próximos da grade na sala contínua")
		check.call(app.operator_view.embedded and app.room_view.embedded, "Atores da partida usam a sala sem cards explicativos")
		for control in [app.operator_view, app.board_view, app.room_view, app.feedback_label, app.buttons["hint"], app.buttons["restart"], app.buttons["pause"]]:
			check.call(app.get_global_rect().encloses(control.get_global_rect()), "Cena e controles cabem em " + str(viewport))
		for key in ["pause", "restart", "hint"]:
			var extent: Vector2 = app.buttons[key].get_global_rect().size
			check.call(extent.x >= 48 and extent.y >= 48, "Ação %s tem alvo de pelo menos 48 unidades na dimensão testada" % key)
		check.call(app.buttons["pause"].get_global_rect().end.y < operator.position.y, "Pausa fica no cabeçalho")
		check.call(operator.position.y - app.buttons["pause"].get_global_rect().end.y <= 4 * app.stage.scale.y + 0.01, "Sala começa junto ao cabeçalho, sem faixa vazia")
		check.call(not app.buttons["back"].visible, "Partida mantém acesso ao menu somente pela pausa")
		check.call(app.feedback_label.get_global_rect().end.y < app.buttons["hint"].get_global_rect().position.y, "Feedback cabe acima dos botões do rodapé")
		check.call(subject.end.y < app.buttons["hint"].get_global_rect().position.y, "Cadeira não sobrepõe botões de jogo")
		check.call(app.buttons["hint"].size == app.buttons["restart"].size, "Ações do rodapé têm o mesmo tamanho")
		check.call(app.feedback_label.get_theme_font_size("font_size") >= 28 and app.feedback_label.get_theme_constant("outline_size") >= 2, "Feedback mantém leitura e contorno sobre a textura da sala")
		var feedback_font: Font = app.feedback_label.get_theme_font("font")
		check.call(feedback_font.get_height(app.feedback_label.get_theme_font_size("font_size")) * 2 <= app.feedback_label.size.y, "Duas linhas de feedback cabem na faixa inferior")
	var cells: Array = app.session.board.cells.duplicate(true)
	var remaining: float = app.session.remaining
	var moves: int = app.session.moves
	var records: Dictionary = app.profile.records.duplicate(true)
	var replacement := ExecutionCharacter.new()
	replacement.display_name = "Personagem de teste"
	replacement.portrait = character.portrait.duplicate()
	replacement.portrait.set_frame(&"idle", 0, character.frame_texture(&"recover", 0.0))
	app.execution_character = replacement
	app._sync_controls()
	check.call(app.room_view.execution_character == replacement and replacement.frame_texture(&"idle", 0.0) != character.frame_texture(&"idle", 0.0), "Troca independente alcança a imagem e o nome da cadeira")
	check.call(app.operator_view.art_pack == pack and pack.frame_texture(&"engineer", &"idle", 0.0) == raised, "Trocar ocupante preserva o goblin e a chave")
	check.call(app.session.board.cells == cells and app.session.remaining == remaining and app.session.moves == moves and app.profile.records == records, "Trocar personagem preserva tentativa e progresso")
	check.call(ExecutionCharacter.new().frame_texture(&"zap", 0.0) == null, "Personagem vazio permite fallback do pacote visual")
	app.execution_character = null
	app._sync_controls()
	check.call(app.room_view.execution_character == null and app.room_view.art_pack == pack, "Sem personagem selecionado a sala conserva o pacote anterior")
	app.execution_character = character
	app.level_index = 0
	app.start_game(false)
	character = app.execution_character
	app.sound_enabled = true
	app._on_cell_pressed(1)
	check.call(app.session.state == Session.State.RESOLVING and app.audio.last_cue == "rotate", "Fechar circuito inicia a chave sem antecipar o som do choque")
	app._process(0.15)
	check.call(app.operator_view.state == &"anticipation" and app.room_view.state == &"anticipation", "Cliente aguarda enquanto o goblin abaixa a chave")
	app._on_cell_pressed(1)
	check.call(app.session.moves == 1 and app.buttons["restart"].disabled, "Movimentos ficam bloqueados durante a sequência")
	app._process(0.26)
	check.call(app.operator_view.state == &"zap" and app.room_view.state == &"zap" and app.audio.last_cue == "zap", "Descarga e áudio começam depois da chave abaixada")
	var serial: int = app.audio.cue_serial
	app._process(0.1)
	app._sync_controls()
	check.call(app.audio.cue_serial == serial, "Som da descarga toca uma única vez")
	app._process(app.ZAP_END_TIME - 0.51 + 0.1)
	check.call(app.room_view.state == &"recover" and app.session.state == Session.State.RESOLVING, "Recuperação antecede o resultado")
	app._process(app.RESOLUTION_DURATION - app.ZAP_END_TIME - 0.1 + 0.01)
	check.call(app.session.state == Session.State.WON and app.operator_view.state == &"win", "Resultado aparece ao terminar a sequência")
	app.start_game(false)
	check.call(app.operator_view.state == &"idle" and app.execution_character == character, "Reiniciar levanta a chave e mantém o ocupante selecionado")
	app.level_index = 10
	app.start_game(false)
	app._on_cell_pressed(5)
	app.session.tick(app.session.time_limit + 1)
	app._sync_controls()
	check.call(app.operator_view.state == &"lose" and pack.frame_texture(&"engineer", &"lose", 0.0) == raised, "Fim do tempo não abaixa a chave")
	app.show_levels()
	check.call(not app.operator_view.visible and not app.room_view.visible, "Seletor esconde as duas salas")
	app.show_menu()
	check.call(not app.operator_view.visible and app.room_view.is_menu, "Menu conserva sua composição própria")
	app.sound_enabled = false
	print("Cena: operador, chave sincronizada, ocupante substituível e três proporções verificados.")
