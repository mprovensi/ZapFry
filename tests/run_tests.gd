extends SceneTree
## Execute com --headless --path . --script tests/run_tests.gd -- --test

const Board = preload("res://scripts/circuit_board.gd")
const Session = preload("res://scripts/game_session.gd")
const App = preload("res://scripts/main.gd")
const ProfileTests = preload("res://tests/profile_tests.gd")
const HintStressTests = preload("res://tests/hint_stress_tests.gd")
const Solution = preload("res://scripts/circuit_solution.gd")
const ArtTests = preload("res://tests/art_pack_tests.gd")
const PolishTests = preload("res://tests/polish_tests.gd")
const StageTests = preload("res://tests/stage_tests.gd")
const PowerCableTests = preload("res://tests/power_cable_tests.gd")
const ExecutionEffectTests = preload("res://tests/execution_effect_tests.gd")
const CharacterRosterTests = preload("res://tests/character_roster_tests.gd")
const EncounterTests = preload("res://tests/encounter_tests.gd")
var failures := 0
var checks := 0
var level: Dictionary


func _initialize() -> void:
	if not "--test" in OS.get_cmdline_user_args():
		push_error("Executar com -- --test para proteger o perfil do jogador.")
		quit(1)
		return
	call_deferred("_run")


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FALHOU: " + description)


func _run() -> void:
	level = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/original_level_01.json"))
	_test_ports()
	_test_connectivity()
	_test_level()
	_test_session()
	_test_intro_levels()
	ArtTests.new().run(_check)
	ProfileTests.new().run(_check)
	CharacterRosterTests.new().run(_check)
	EncounterTests.new().run(_check)
	await _test_encounters()
	_test_hint_rules()
	HintStressTests.new().run(_check)
	await _test_ui()
	await _test_selector()
	await _test_settings()
	await _test_focus_lifecycle()
	await _test_clock()
	await _test_hint_playability()
	await _test_hint_feedback()
	await _test_visual_pack()
	await _test_campaign_playability()
	print("RESULTADO: %d verificações; %d falhas." % [checks, failures])
	quit(1 if failures > 0 else 0)


func _test_ports() -> void:
	_check(Board.rotate_mask(Board.NORTH, 1) == Board.EAST, "Rotação N → E")
	_check(Board.rotate_mask(Board.WEST, 1) == Board.NORTH, "Rotação W → N sem quinto bit")
	_check(Board.rotate_mask(3, 4) == 3, "Quatro rotações restauram a peça")
	_check(Board.rotate_mask(5, 2) == 5, "Simetria de fio reto")
	_check(Board.rotate_mask(0, 3) == 0, "Obstáculo não tem portas")


func _test_encounters() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.sound_enabled = false
	await EncounterTests.new().run_ui(app, self, _check)
	app.queue_free()
	await process_frame


func _test_connectivity() -> void:
	var fixture := {"size": 2, "source_index": 0, "source_port": Board.WEST,
		"target_index": 1, "target_port": Board.EAST, "cells": [
			{"kind": "straight", "rotation": 1}, {"kind": "straight", "rotation": 1},
			{"kind": "straight", "rotation": 1}, {"kind": "straight", "rotation": 1}]}
	var board := Board.new()
	board.load_level(fixture)
	_check(board.solved and board.energized.size() == 2, "Conexão recíproca alcança a saída")
	board.cells[1]["rotation"] = 0
	board.recompute()
	_check(not board.solved and board.energized.size() == 1, "Porta incompatível não conduz")
	board.cells[0]["rotation"] = 0
	board.recompute()
	_check(board.energized.is_empty(), "Gerador precisa da porta correta")
	fixture["source_index"] = 1
	fixture["source_port"] = Board.EAST
	fixture["target_index"] = 2
	fixture["target_port"] = Board.WEST
	board.load_level(fixture)
	_check(not board.solved, "Borda não salta para a linha seguinte")
	fixture["source_index"] = 0
	fixture["source_port"] = Board.NORTH
	fixture["target_index"] = 3
	fixture["target_port"] = Board.NORTH
	fixture["cells"] = [{"kind": "tee", "rotation": 1}, {"kind": "curve", "rotation": 2},
		{"kind": "curve", "rotation": 0}, {"kind": "curve", "rotation": 3}]
	board.load_level(fixture)
	_check(board.energized.size() == 4 and board.solved, "Ciclo termina e T aceita ramificação aberta")
	fixture["target_port"] = Board.EAST
	board.load_level(fixture)
	_check(not board.solved, "Energizar célula de destino sem sua porta não vence")
	fixture["cells"][2] = {"kind": "blocker", "rotation": 0, "fixed": true}
	board.load_level(fixture)
	_check(not board.energized.has(2), "Fusível queimado bloqueia energia")


func _test_level() -> void:
	var board := Board.new()
	board.load_level(level)
	_check(board.width == 4 and board.cells.size() == 16, "Fase 4 × 4 carregada")
	_check(not board.solved, "Embaralhamento inicial não está resolvido")
	_check(not board.rotate_cell(0), "Fio fixo não gira")
	_check(not board.rotate_cell(12), "Fusível queimado não gira")
	_check(not board.rotate_cell(-1) and not board.rotate_cell(16), "Índice inválido é ignorado")
	for cell in board.cells:
		cell["rotation"] = cell["solution"]
	board.recompute()
	_check(board.solved, "Solução de referência da fase funciona")
	for index in level["reference_path"]:
		_check(board.energized.has(int(index)), "Energia percorre a célula %d da referência" % index)
	_check(not board.energized.has(12), "Obstáculo permanece sem energia na solução")
	_check(int(level["cells"][1]["rotation"]) == 3, "Modelo não modifica dados originais")


func _test_session() -> void:
	var session := Session.new()
	session.start(level)
	session.tick(500)
	_check(session.remaining == 90 and session.state == Session.State.READY, "Relógio aguarda primeira jogada")
	_check(not session.rotate_cell(0) and session.moves == 0, "Toque em fixo não inicia relógio")
	session.rotate_cell(1)
	session.tick(2.5)
	_check(session.remaining == 87.5 and session.moves == 1, "Primeira jogada inicia contagem")
	session.pause()
	session.tick(100)
	_check(session.remaining == 87.5 and not session.rotate_cell(1), "Pausa congela relógio e comandos")
	session.resume()
	session.tick(0.5)
	_check(session.remaining == 87, "Retomar mantém tempo restante")
	session.tick(100)
	_check(session.state == Session.State.LOST and session.remaining == 0, "Tempo termina em zero")
	_check(not session.rotate_cell(1) and session.score() == 0, "Derrota bloqueia jogada e pontuação")
	session.start(level)
	session.pause()
	session.resume()
	_check(session.state == Session.State.READY, "Pausa antes de começar preserva READY")
	_solve_session(session)
	_check(session.state == Session.State.RESOLVING, "Solução dispara conclusão automática")
	var remaining := session.remaining
	session.tick(100)
	_check(session.remaining == remaining and not session.rotate_cell(1), "Zap bloqueia relógio e comandos")
	session.finish_resolution()
	_check(session.state == Session.State.WON and session.score() == 2000 and session.stars() == 3, "Resultado e estrelas da vitória")
	session.finish_resolution()
	_check(session.score() == 2000, "Conclusão repetida é inofensiva")
	session.start(level)
	_check(session.moves == 0 and not session.board.solved and session.remaining == 90, "Reinício restaura a tentativa")
	session.rotate_cell(1)
	session.tick(90)
	_check(not session.rotate_cell(15), "Toque no limite de tempo não permite vencer após expirar")


func _solve_session(session: GameSession) -> void:
	for index in range(session.board.cells.size()):
		if not session.board.can_rotate(index):
			continue
		for turn in range(4):
			if int(session.board.cells[index]["rotation"]) == int(session.board.cells[index]["solution"]):
				break
			session.rotate_cell(index)


func _test_intro_levels() -> void:
	for number in range(1, App.LEVEL_PATHS.size() + 1):
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_%02d.json" % number))
		var session := Session.new()
		session.start(data)
		_check(not session.board.solved, "Fase %d começa sem solução pronta" % number)
		var expected_width := 4 if number <= 8 else (5 if number <= 16 else 6)
		_check(session.board.width == expected_width and session.board.cells.size() == expected_width * expected_width, "Fase %d tem dimensões corretas" % number)
		_check(session.has_time_limit() == (number not in [1, 2, 3, 9]), "Fase %d respeita o treino sem tempo" % number)
		for index in range(session.board.cells.size()):
			if session.board.cells[index]["kind"] == "empty":
				_check(not session.board.can_rotate(index), "Célula vazia não conta como fio")
		for value in data["reference_path"]:
			var index := int(value)
			var cell: Dictionary = session.board.cells[index]
			var goal := Board.rotate_mask(int(Board.BASE_MASKS[cell["kind"]]), int(cell["solution"]))
			for turn in range(4):
				if session.board.mask_at(index) == goal:
					break
				session.rotate_cell(index)
		_check(session.state == Session.State.RESOLVING, "Solução da fase %d dispara vitória" % number)
		_check(session.moves == int(data["reference_taps"]), "Fase %d resolve em %d toques previstos" % [number, int(data["reference_taps"])])
		print("Fase %d resolvida em %d toques; %s." % [number, session.moves, "sem tempo" if not session.has_time_limit() else "%d segundos" % session.time_limit])
		session.finish_resolution()
		_check(session.score() > 0 and session.stars() == 3, "Pontuação válida na fase %d" % number)
	var untimed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_03.json"))
	var training := Session.new()
	training.start(untimed)
	training.rotate_cell(1)
	training.tick(3600)
	_check(training.state == Session.State.PLAYING and training.remaining == 0, "Treino permanece ativo mesmo após uma hora")
	training.pause()
	training.tick(3600)
	training.resume()
	_check(training.state == Session.State.PLAYING, "Treino sem tempo permite pausar e retomar")
	_solve_session(training)
	training.finish_resolution()
	_check(training.score() == 1000 and training.stars() == 3, "Treino dá estrelas sem dividir por tempo zero")


func _test_ui() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var app = packed.instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.sound_enabled = false
	_check(app.screen == "menu" and app.buttons["start"].visible, "Menu abre com ação principal")
	await _click(app.buttons["start"].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.screen == "game" and app.board_view.visible, "Clique real em iniciar abre o puzzle")
	var point: Vector2 = app.board_view.get_global_transform() * Vector2(234, 78)
	_check(app.board_view.guide_index == 1, "Tutorial destaca a única peça necessária")
	await _click(point)
	_check(app.session.moves == 1 and app.session.state == Session.State.RESOLVING, "Primeira fase vence com exatamente um clique")
	app._process(app.RESOLUTION_DURATION + 0.1)
	_check(app.session.state == Session.State.WON and app.unlocked_level == 1, "Vitória desbloqueia a segunda fase")
	await _click(app.buttons["continue"].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.level_index == 1 and app.session.state == Session.State.READY, "Próxima fase avança sem voltar ao menu")
	await _click(point)
	_check(app.board_view.guide_index == 3, "Seta avança para a curva após conectar o fio reto")
	await _touch(point)
	_check(app.session.moves == 2, "Toque nativo gira uma peça")
	var emulated := InputEventMouseButton.new()
	emulated.device = -1
	emulated.button_index = MOUSE_BUTTON_LEFT
	emulated.pressed = true
	emulated.position = point
	root.push_input(emulated, true)
	_check(app.session.moves == 2, "Mouse emulado pelo toque não duplica a rotação")
	await _click(app.buttons["pause"].get_global_rect().get_center())
	_check(app.session.state == Session.State.PAUSED and app.overlay.visible, "Pausa exibe painel sobre a grade")
	await _click(point)
	_check(app.session.moves == 2, "Overlay impede clique na grade em pausa")
	await _click(app.buttons["continue"].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.session.state == Session.State.PLAYING and not app.overlay.visible, "Botão continuar restaura partida")
	_check(not quit_on_go_back, "Voltar do Android usa navegação do jogo")
	app.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(app.session.state == Session.State.PAUSED, "Segundo plano pausa automaticamente")
	app._handle_back()
	_check(app.session.state == Session.State.PLAYING, "Voltar retoma a partida pausada")
	await _click(app.buttons["restart"].get_global_rect().get_center())
	_check(app.session.moves == 0 and app.session.state == Session.State.READY, "Reinício pela interface")
	_solve_session(app.session)
	app._process(app.RESOLUTION_DURATION + 0.1)
	_check(app.overlay.visible and app.buttons["continue"].text.contains("PRÓXIMA"), "Vitória oferece a próxima fase")
	await _click(app.buttons["exit"].get_global_rect().get_center())
	_check(app.screen == "menu" and not app.overlay.visible, "Resultado retorna ao menu")
	await _click(app.buttons["start"].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.level_index == 2, "Menu continua na primeira fase desbloqueada ainda não concluída")
	await _touch(app.buttons["pause"].get_global_rect().get_center())
	_check(app.session.state == Session.State.PAUSED and app.buttons["exit"].visible, "Pausa mantém o acesso ao menu principal")
	await _click(app.buttons["exit"].get_global_rect().get_center())
	_check(app.screen == "menu" and not app.overlay.visible, "Menu da pausa retorna à tela principal")
	await _click(app.buttons["levels"].get_global_rect().get_center())
	await _click(app.buttons["sector_0"].get_global_rect().get_center())
	await _click(app.level_cards[0].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.level_index == 0, "É possível praticar novamente desde a primeira fase")
	app.level_index = app.levels.size() - 1
	app.start_game(false)
	_solve_session(app.session)
	app._process(app.RESOLUTION_DURATION + 0.1)
	_check(app.unlocked_level == app.levels.size() - 1 and app.buttons["continue"].text.contains("INÍCIO"), "Última fase conclui campanha sem índice inválido")
	await _click(app.buttons["continue"].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.level_index == 0, "Fim da campanha permite jogar do início")
	await _solve_original_through_ui(app)
	app.queue_free()
	await process_frame


func _solve_original_through_ui(app) -> void:
	app.level_data = level.duplicate(true)
	app.level_data["instruction"] = "Leve a corrente de IN até OUT."
	app.level_data["tip_lines"] = ["Fase original em teste.", "Verificação de conectividade."]
	app.session.start(app.level_data)
	app.board_view.model = app.session.board
	app._update_guidance()
	app._sync_controls()
	for value in level["reference_path"]:
		var index := int(value)
		var cell: Dictionary = app.session.board.cells[index]
		var goal := Board.rotate_mask(int(Board.BASE_MASKS[cell["kind"]]), int(cell["solution"]))
		for turn in range(4):
			if app.session.board.mask_at(index) == goal:
				break
			var local := Vector2(index % 4 + 0.5, index / 4 + 0.5) * 156
			await _touch(app.board_view.get_global_transform() * local)
	_check(app.session.state == Session.State.RESOLVING and app.session.moves == 17, "Fase original resolvida pela interface com 17 toques")
	print("Fase original: solução confirmada pela interface em 17 toques.")


func _cell_center(app, index: int) -> Vector2:
	var width: int = app.session.board.width
	var step: float = app.board_view.size.x / width
	var local := Vector2(index % width + 0.5, index / width + 0.5) * step
	return app.board_view.get_global_transform() * local


func _test_hint_rules() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_03.json"))
	var session := Session.new()
	session.start(data)
	session.pause()
	_check(session.use_hint() == -1 and session.hints_used == 0, "Dica não é consumida em pausa")
	session.resume()
	var index := session.hint_candidate()
	_check(index >= 0 and session.use_hint() == index, "Dica corrige um fio elegível")
	_check(session.hints_used == 1 and not session.board.can_rotate(index), "Fio corrigido fica preso até o fim da tentativa")
	var before := session.moves
	_check(session.use_hint() == -1 and session.moves == before, "Segunda dica não é concedida na mesma tentativa")
	session.tick(2.5)
	_check(session.elapsed == 2.5, "Treino livre registra tempo ativo")
	session.pause()
	session.tick(500)
	_check(session.elapsed == 2.5, "Pausa não aumenta o melhor tempo")
	session.start(data)
	_check(session.hints_used == 0 and session.board.can_rotate(index), "Reiniciar devolve dica e remove trava temporária")
	_check(data["cells"][index].get("fixed", false) == false, "Dica não modifica os dados autorais")
	var timed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_04.json"))
	session.start(timed)
	session.rotate_cell(1)
	session.tick(181)
	_check(session.use_hint() == -1 and session.hints_used == 0, "Dica não revive uma fase perdida")
	_check(session.elapsed == 180, "Tempo ativo cronometrado para no limite da fase")
	session.start(data)
	for cell in session.board.cells:
		cell["rotation"] = cell["solution"]
	session.board.recompute()
	_check(session.use_hint() == -1 and session.hints_used == 0, "Nenhuma dica é gasta quando não há fio incorreto")


func _test_selector() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.sound_enabled = false
	await _click(app.buttons["levels"].get_global_rect().get_center())
	_check(app.screen == "levels" and app.level_cards.size() == 8, "Menu abre seletor com oito cartões por setor")
	_check(not app.level_cards[0].disabled and app.level_cards[1].disabled, "Perfil novo libera somente a primeira fase no seletor")
	await _click(app.buttons["sector_2"].get_global_rect().get_center())
	_check(app.sector_index == 2 and app.level_cards[0].level_id == 17, "Aba 6×6 exibe as fases 17–24")
	await _click(app.level_cards[0].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.screen == "levels" and not app.play_selected_level(16), "Fase bloqueada não abre nem por chamada direta")
	_check(not app.play_selected_level(-1) and not app.play_selected_level(24), "Seletor rejeita índice inválido")
	app.profile.record_win(1, 1000, 3, 4.0)
	app._open_sector(0)
	_check(app.level_cards[0].record["stars"] == 3 and not app.level_cards[1].disabled, "Cartão exibe estrelas e fase seguinte desbloqueada")
	await _click(app.level_cards[0].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.screen == "game" and app.level_index == 0, "É possível repetir fase concluída sem zerar o progresso")
	app.show_levels()
	app._handle_back()
	_check(app.screen == "menu" and app.unlocked_level == 1, "Voltar do seletor preserva desbloqueios")
	# Os três grupos são utilizáveis com a janela estreita do teste mobile.
	for id in range(1, 24):
		app.profile.record_win(id, 1000, 3, 4.0)
	app.size = Vector2(360, 800)
	app._layout_stage()
	app.show_levels()
	for sector in range(3):
		await _click(app.buttons["sector_%d" % sector].get_global_rect().get_center())
		_check(app.sector_index == sector, "Aba do setor %d funciona em janela estreita" % sector)
		for slot in range(8):
			var rect: Rect2 = app.level_cards[slot].get_global_rect()
			_check(app.get_global_rect().encloses(rect), "Cartão %d do setor %d permanece na tela" % [slot, sector])
		await _click(app.level_cards[7].get_global_rect().get_center())
		await _dismiss_intro(app)
		_check(app.screen == "game" and app.level_index == sector * 8 + 7, "Última fase do setor %d pode ser selecionada" % sector)
		app.show_levels()
	var records_before: Dictionary = app.profile.records.duplicate(true)
	var unlocked_before: int = app.unlocked_level
	for key in ["selector_continue", "start_over"]:
		var rect: Rect2 = app.buttons[key].get_global_rect()
		_check(app.get_global_rect().encloses(rect) and rect.size.y >= 48, "Ação do seletor cabe na tela com alvo de toque de 48: " + key)
	_check(not app.buttons["start_over"].get_global_rect().intersects(app.buttons["selector_continue"].get_global_rect()), "Começar de novo não sobrepõe Continuar")
	await _touch(app.buttons["start_over"].get_global_rect().get_center())
	_check(app.screen == "menu" and app.level_index == 0 and app.profile.current_level == 0 and not app.overlay.visible, "Começar de novo volta à fase 1 e ao menu sem abrir a partida")
	_check(app.profile.records == records_before and app.unlocked_level == unlocked_before and not app.sound_enabled, "Começar de novo preserva recordes, desbloqueios e preferências")
	var restart_path := "res://builds/start-over-profile.cfg"
	_check(app.profile.save_profile(restart_path) == OK, "Novo ponto de continuação pode ser persistido")
	var restored = load("res://scripts/player_profile.gd").new()
	_check(restored.load_profile(restart_path) == OK and restored.current_level == 0 and restored.unlocked_level == unlocked_before and restored.records == records_before, "Reabrir o jogo mantém a fase 1 sem perder conquistas")
	app.profile = restored
	app.show_menu()
	_check(app.buttons["start"].text == "JOGAR" and not app.buttons["start_over"].visible, "Menu principal fica pronto para jogar do início")
	await _click(app.buttons["start"].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.screen == "game" and app.level_index == 0 and app.session.state == Session.State.READY, "Jogar após começar de novo abre a primeira fase")
	app._on_cell_pressed(1)
	app._process(app.RESOLUTION_DURATION + 0.1)
	app.show_menu()
	await _click(app.buttons["start"].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.level_index == 1 and app.profile.current_level == 1 and app.unlocked_level == unlocked_before, "Após vencer a fase 1, Continuar segue para a fase 2 sem saltar aos desbloqueios antigos")
	app.queue_free()
	await process_frame


func _test_settings() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.size = Vector2(360, 800)
	app._layout_stage()
	for id in range(1, 4):
		app.profile.record_win(id, 1000, 3, 4.0)
	app.show_menu()
	var records: Dictionary = app.profile.records.duplicate(true)
	var unlocked: int = app.unlocked_level
	await _touch(app.buttons["settings"].get_global_rect().get_center())
	_check(app.settings.visible and app.screen == "menu" and not app.buttons["start"].visible, "Ajustes abrem pelo menu e isolam seus controles")
	for control in [app.music_slider, app.effects_slider, app.buttons["sound"], app.buttons["vibration"], app.buttons["flashes"], app.buttons["settings_back"]]:
		var rect: Rect2 = control.get_global_rect()
		_check(app.get_global_rect().encloses(rect) and rect.size.y >= 48, "Ajuste cabe na tela estreita e tem alvo de 48 unidades")
	var music_rect: Rect2 = app.music_slider.get_global_rect()
	# HSlider recebe mouse nativo; no Android, a engine emula mouse a partir do toque.
	# push_input(ScreenTouch) do viewport não passa por essa emulação do Input.
	_check(ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"), "Toque no Android emula entrada nativa dos controles de volume")
	await _click(music_rect.position + music_rect.size * Vector2(0.3, 0.5))
	_check(app.profile.music_volume > 0.15 and app.profile.music_volume < 0.45 and app.profile.effects_volume == 1, "Controle de música ajusta somente a música")
	var music_volume: float = app.profile.music_volume
	var effects_rect: Rect2 = app.effects_slider.get_global_rect()
	await _click(effects_rect.position + effects_rect.size * Vector2(0.7, 0.5))
	_check(app.profile.effects_volume > 0.55 and app.profile.effects_volume < 0.85 and app.profile.music_volume == music_volume, "Controle de efeitos preserva a música")
	await _touch(app.buttons["vibration"].get_global_rect().get_center())
	_check(not app.profile.vibration_enabled and app.sound_enabled, "Vibração pode ser desligada independentemente do som")
	await _click(app.buttons["flashes"].get_global_rect().get_center())
	_check(app.reduced_flashes and not app.profile.vibration_enabled, "Flashes suaves não reativam a vibração")
	await _touch(app.buttons["sound"].get_global_rect().get_center())
	_check(not app.sound_enabled and not app.audio.music.playing and not app.music_slider.editable and not app.effects_slider.editable, "Som geral silencia tudo sem apagar os volumes escolhidos")
	app._handle_back()
	_check(not app.settings.visible and app.screen == "menu", "Voltar fecha ajustes do menu sem sair do jogo")
	var path := "res://builds/settings-ui.cfg"
	_check(app.profile.save_profile(path) == OK, "Ajustes podem ser gravados com o progresso")
	var restored = load("res://scripts/player_profile.gd").new()
	_check(restored.load_profile(path) == OK and restored.records == records and restored.unlocked_level == unlocked and is_equal_approx(restored.music_volume, music_volume) and not restored.vibration_enabled and not restored.sound_enabled, "Reabrir preserva ajustes e conquistas")
	app.profile = restored
	app.show_menu()
	await _click(app.buttons["settings"].get_global_rect().get_center())
	await _touch(app.buttons["sound"].get_global_rect().get_center())
	_check(app.sound_enabled and app.music_slider.editable and is_equal_approx(app.profile.music_volume, music_volume), "Religar som recupera os níveis escolhidos")
	await _click(app.buttons["settings_back"].get_global_rect().get_center())
	app.level_index = 3
	app.start_game(false)
	for index in range(app.session.board.cells.size()):
		if app.session.board.can_rotate(index):
			app._on_cell_pressed(index)
			break
	await _touch(app.buttons["pause"].get_global_rect().get_center())
	var cells: Array = app.session.board.cells.duplicate(true)
	var remaining: float = app.session.remaining
	var moves: int = app.session.moves
	await _click(app.buttons["pause_settings"].get_global_rect().get_center())
	_check(app.settings.visible and app.session.state == Session.State.PAUSED and not app.overlay.visible and not app.buttons["pause"].visible, "Ajustes da pausa isolam a interface e mantêm a partida pausada")
	app._process(3.0)
	_check(app.session.remaining == remaining and app.session.board.cells == cells and app.session.moves == moves, "Ajustes não consomem tempo nem alteram a tentativa")
	app._handle_back()
	_check(not app.settings.visible and app.overlay.visible and app.session.state == Session.State.PAUSED, "Voltar dos ajustes retorna à pausa")
	await _touch(app.buttons["continue"].get_global_rect().get_center())
	_check(app.session.state == Session.State.PLAYING and not app.audio.music.stream_paused, "Continuar retoma a partida e a trilha com os níveis salvos")
	_check(app.profile.records == records and app.unlocked_level == unlocked, "Fluxo completo de ajustes preserva conquistas")
	app.queue_free()
	await process_frame
	print("Ajustes: mouse/toque, navegação da pausa, mixagem e persistência verificados.")


func _test_focus_lifecycle() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.level_index = 3
	app.start_game(false)
	app._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	app._process(30)
	_check(app.session.state == Session.State.PAUSED and app.session.moves == 0, "Segundo plano antes de jogar mantém a tentativa sem iniciar o relógio")
	app._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(app.session.state == Session.State.PAUSED, "Voltar ao aplicativo aguarda comando de continuar")
	app.resume_game()
	_check(app.session.state == Session.State.READY, "Continuar após segundo plano restaura READY")
	for index in range(app.session.board.cells.size()):
		if app.session.board.can_rotate(index):
			app._on_cell_pressed(index)
			break
	var cells: Array = app.session.board.cells.duplicate(true)
	var moves: int = app.session.moves
	app._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	# A notificação contabiliza o tempo ativo até o instante de pausar.
	var remaining: float = app.session.remaining
	app._process(120)
	app._on_cell_pressed(0)
	app.use_free_hint()
	_check(app.session.state == Session.State.PAUSED and app.session.remaining == remaining and app.session.moves == moves and app.session.board.cells == cells and app.session.hints_used == 0, "Segundo plano congela tempo e bloqueia giros e dicas")
	app.show_settings()
	app._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	app._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	app._process(20)
	_check(app.settings.visible and app.session.state == Session.State.PAUSED and app.session.remaining == remaining, "Retomar com ajustes abertos conserva modal e partida pausada")
	app._handle_back()
	_check(not app.settings.visible and app.session.state == Session.State.PAUSED, "Voltar dos ajustes após segundo plano retorna à pausa")
	app._handle_back()
	_check(app.session.state == Session.State.PLAYING and app.session.board.cells == cells, "Continuar retorna ao tabuleiro preservado")
	app.queue_free()
	await process_frame


func _test_clock() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	var clock := {"now": 1000}
	app.ticks_msec = func(): return clock["now"]
	app.sound_enabled = false
	app.level_index = 3
	app.start_game(false)
	for index in range(app.session.board.cells.size()):
		if app.session.board.can_rotate(index):
			app._on_cell_pressed(index)
			break
	var remaining: float = app.session.remaining
	clock["now"] += 2500
	app._process(0)
	_check(is_equal_approx(app.session.remaining, remaining - 2.5), "Relógio desconta o tempo real entre eventos")
	app._process(0)
	_check(is_equal_approx(app.session.remaining, remaining - 2.5), "Eventos no mesmo instante não descontam tempo em dobro")
	app.pause_game()
	clock["now"] += 60000
	app._process(60)
	app.resume_game()
	_check(is_equal_approx(app.session.remaining, remaining - 2.5), "Relógio exclui o tempo passado em pausa")
	clock["now"] += 1000
	app._process(0)
	_check(is_equal_approx(app.session.remaining, remaining - 3.5), "Relógio retoma sem cobrar o intervalo da pausa")
	app.queue_free()
	await process_frame


func _test_hint_playability() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.sound_enabled = false
	app.size = Vector2(360, 800)
	app._layout_stage()
	var results: Array = []
	for number in range(1, app.levels.size() + 1):
		var before := failures
		app.level_index = number - 1
		app.start_game(false)
		var index: int = app.session.hint_candidate()
		_check(index >= 0 and not app.buttons["hint"].disabled, "Fase %d oferece dica gratuita" % number)
		await _click(app.buttons["hint"].get_global_rect().get_center())
		_check(app.session.hints_used == 1 and not app.session.board.can_rotate(index), "Dica da fase %d corrige e prende um fio" % number)
		_check(app.buttons["hint"].disabled, "Dica da fase %d só pode ser usada uma vez por tentativa" % number)
		var after_hint: Dictionary = Solution.new().solve(app.session.board)
		for value in after_hint.get("path", []):
			var cell_index := int(value)
			var cell: Dictionary = app.session.board.cells[cell_index]
			var goal := Board.rotate_mask(int(Board.BASE_MASKS[cell["kind"]]), int(after_hint["rotations"][cell_index]))
			for turn in range(4):
				if app.session.board.mask_at(cell_index) == goal or app.session.state == Session.State.RESOLVING:
					break
				await _touch(_cell_center(app, cell_index))
		_check(app.session.state == Session.State.RESOLVING and app.session.board.solved, "Fase %d continua solucionável após a dica" % number)
		app._process(app.RESOLUTION_DURATION + 0.1)
		var record: Dictionary = app.profile.level_record(number)
		_check(record.get("completed", false) and record.get("stars", 0) > 0 and record.get("best_time", -1) >= 0, "Vitória da fase %d registra estrelas e tempo" % number)
		var count: int = record["completions"]
		app._process(app.RESOLUTION_DURATION + 0.1)
		_check(app.profile.level_record(number)["completions"] == count, "Resultado da fase %d não é salvo duas vezes" % number)
		app.start_game(false)
		_check(app.session.hints_used == 0 and not app.buttons["hint"].disabled, "Fase %d pode ser repetida com nova dica" % number)
		results.append({"id": number, "passed": failures == before})
	var output := FileAccess.open("res://builds/hint-results.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"levels": results}, "\t"))
	output.close()
	_check(app.profile.completed_count() == 24, "Dicas não impedem registrar a campanha completa")
	app.show_menu()
	await _click(app.buttons["levels"].get_global_rect().get_center())
	await _touch(app.buttons["start_over"].get_global_rect().get_center())
	await _click(app.buttons["start"].get_global_rect().get_center())
	await _dismiss_intro(app)
	_check(app.level_index == 0 and app.profile.completed_count() == 24, "Rejogar campanha concluída mantém todos os recordes")
	print("Dica gratuita: 24 fases jogáveis e resultados individuais registrados.")
	app.queue_free()
	await process_frame


func _test_hint_feedback() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://builds/hint-states-input.json"))
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.sound_enabled = false
	for case in data["cases"]:
		if case["name"] not in ["11-valid-tee-11", "18-initial", "18-mistakes-0"]:
			continue
		for viewport_size in [Vector2(720, 1280), Vector2(360, 800)]:
			app.size = viewport_size
			app._layout_stage()
			for mode in ["mouse", "touch"]:
				app.level_index = int(case["level"]) - 1
				app.levels[app.level_index] = case["state"].duplicate(true)
				app.start_game(false)
				var index: int = app.session.hint_candidate()
				if mode == "mouse":
					await _click(app.buttons["hint"].get_global_rect().get_center())
				else:
					await _touch(app.buttons["hint"].get_global_rect().get_center())
				_check(app.session.hints_used == 1 and app.board_view.hint_index == index, "Dica funciona e marca a peça com " + mode)
				_check(app.feedback.contains("linha %d, coluna %d" % [index / app.session.board.width + 1, index % app.session.board.width + 1]), "Dica informa coordenadas da peça correta")
				app.board_view._process(1.0)
				_check(app.board_view.hint_index == index, "Marca da dica permanece após a animação")
				if int(case["valid_tee"]) >= 0:
					_check(app.session.board.mask_at(11) == Board.rotate_mask(Board.BASE_MASKS["tee"], int(case["state"]["cells"][11]["rotation"])), "Interface não gira T que já fazia a conexão")
				var plan: Dictionary = Solution.new().solve(app.session.board)
				for value in plan["path"]:
					var cell_index := int(value)
					var turns := posmod(int(plan["rotations"][cell_index]) - int(app.session.board.cells[cell_index]["rotation"]), 4)
					for turn in range(turns):
						await _touch(_cell_center(app, cell_index))
				_check(app.session.state == Session.State.RESOLVING, "Partida com dica contextual conclui pela interface")
				app._process(app.RESOLUTION_DURATION + 0.1)
				app.start_game(false)
				_check(app.board_view.hint_index == -1 and app.session.hints_used == 0, "Reiniciar remove marca e devolve dica")
	app.queue_free()
	await process_frame
	print("Dica contextual: 12 cenários de interface em mouse/toque, duas dimensões.")


func _test_visual_pack() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.sound_enabled = false
	ArtTests.new().run_ui(app, _check)
	PolishTests.new().run_ui(app, _check)
	StageTests.new().run_ui(app, _check)
	PowerCableTests.new().run_ui(app, _check)
	ExecutionEffectTests.new().run_ui(app, _check)
	CharacterRosterTests.new().run_ui(app, _check)
	app.queue_free()
	await process_frame


func _test_campaign_playability() -> void:
	# O plano vem do resolvedor Python, que ignora reference_path e solution.
	var solution_file := "res://builds/level-solutions.json"
	if not FileAccess.file_exists(solution_file):
		_check(false, "Execute tools/dev.ps1 test para gerar as soluções independentes")
		return
	var audit: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(solution_file))
	var reports: Array = audit["levels"]
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	app.sound_enabled = false
	_check(app.levels.size() == reports.size(), "Todas as fases em disco estão registradas na campanha")
	var results: Array = []
	for report in reports:
		var level_checks_before := failures
		var number := int(report["id"])
		var variants: Array = []
		for viewport_size in [Vector2(720, 1280), Vector2(360, 800)]:
			app.size = viewport_size
			app._layout_stage()
			for input_mode in ["mouse", "touch"]:
				var before := failures
				app.level_index = number - 1
				app.start_game(false)
				_check(app.phase_label.visible and app.phase_label.text == "FASE %02d / 24" % number, "Fase %d exibe seu número em destaque" % number)
				_check(app.get_global_rect().encloses(app.phase_label.get_global_rect()), "Fase %d mantém o indicador dentro da tela" % number)
				_check(not app.buttons["back"].visible and not app.phase_label.get_global_rect().intersects(app.buttons["pause"].get_global_rect()), "Fase %d mostra cabeçalho sem menu e sem sobrepor a pausa" % number)
				var cell_extent: float = app.board_view.cell_rect(0).size.x * app.stage.scale.x
				_check(cell_extent >= 48, "Fase %d mantém células com alvo confortável na dimensão testada" % number)
				var masks_before: Array = []
				for index in range(app.session.board.cells.size()):
					masks_before.append(app.session.board.mask_at(index))
					var center := _cell_center(app, index)
					var local: Vector2 = app.board_view.get_global_transform().affine_inverse() * center
					_check(app.board_view.index_at(local) == index, "Fase %d mapeia o centro da célula %d corretamente" % [number, index])
					_check(app.get_global_rect().has_point(center), "Fase %d mantém a célula %d dentro da tela" % [number, index])
					var target: Rect2 = app.board_view.cell_rect(index)
					for probe in [target.position + Vector2.ONE, target.end - Vector2.ONE]:
						_check(app.board_view.index_at(probe) == index, "Fase %d aceita toque nos cantos da célula %d" % [number, index])
				# Nenhuma tentativa pode começar resolvida ou perder antes da primeira jogada.
				app.session.tick(600)
				_check(app.session.state == Session.State.READY, "Fase %d aguarda a primeira jogada" % number)
				for index in range(app.session.board.cells.size()):
					if not app.session.board.can_rotate(index):
						await _touch(_cell_center(app, index))
						_check(app.session.moves == 0 and app.session.state == Session.State.READY, "Fase %d ignora toque em peça não girável" % number)
						_check(app.session.board.mask_at(index) == masks_before[index], "Fase %d preserva peça não girável" % number)
				# Pausa e reinício são exercitados em cada fase pela própria interface.
				await _click(app.buttons["pause"].get_global_rect().get_center())
				var remaining: float = app.session.remaining
				app.session.tick(600)
				_check(app.session.state == Session.State.PAUSED and app.session.remaining == remaining, "Fase %d congela tempo em pausa" % number)
				await _click(app.buttons["continue"].get_global_rect().get_center())
				await _dismiss_intro(app)
				var first := int(report["moves"][0])
				await _touch(_cell_center(app, first))
				await _click(app.buttons["restart"].get_global_rect().get_center())
				# Na fase de um toque a resolução bloqueia reiniciar até terminar.
				if app.session.state == Session.State.RESOLVING:
					_check(app.buttons["restart"].disabled, "Reiniciar fica bloqueado durante o zap")
					app._process(app.RESOLUTION_DURATION + 0.1)
					await _click(app.buttons["exit"].get_global_rect().get_center())
					await _click(app.buttons["levels"].get_global_rect().get_center())
					await _click(app.buttons["sector_0"].get_global_rect().get_center())
					await _click(app.level_cards[0].get_global_rect().get_center())
					await _dismiss_intro(app)
				_check(app.session.state == Session.State.READY and app.session.moves == 0, "Fase %d reinicia a tentativa" % number)
				_check(app.phase_label.text == "FASE %02d / 24" % number, "Reiniciar preserva o número da fase")
				for index in range(masks_before.size()):
					_check(app.session.board.mask_at(index) == masks_before[index], "Fase %d restaura o embaralhamento" % number)
				# Execute somente entradas de usuário, sem alterar orientações diretamente.
				for value in report["moves"]:
					app.session.tick(float(audit["seconds_per_tap"]))
					var index := int(value)
					if input_mode == "mouse":
						await _click(_cell_center(app, index))
					else:
						await _touch(_cell_center(app, index))
				_check(app.session.state == Session.State.RESOLVING and app.session.board.solved, "Fase %d vence usando %s com solução independente" % [number, input_mode])
				_check(app.session.moves == int(report["minimum_taps"]), "Fase %d registra os toques mínimos" % number)
				_check(not app.session.has_time_limit() or app.session.remaining > 0, "Fase %d pode ser concluída dentro do tempo simulado" % number)
				app._process(app.RESOLUTION_DURATION + 0.1)
				_check(app.session.state == Session.State.WON and app.overlay.visible and app.session.score() > 0, "Fase %d apresenta resultado de vitória" % number)
				for index in range(app.session.board.cells.size()):
					if app.session.board.cells[index]["kind"] == "blocker":
						_check(not app.session.board.energized.has(index), "Fase %d vence sem atravessar fusível" % number)
				await _click(app.buttons["continue"].get_global_rect().get_center())
				await _dismiss_intro(app)
				var next_index: int = number if number < reports.size() else 0
				_check(app.level_index == next_index and app.session.state == Session.State.READY, "Fase %d permite seguir a campanha" % number)
				_check(app.phase_label.text == "FASE %02d / 24" % (next_index + 1), "Avançar atualiza o número da fase")
				_check(app.session.board.width == int(app.levels[next_index]["size"]), "Transição após a fase %d carrega a grade correta" % number)
				variants.append({"input": input_mode, "width": int(viewport_size.x), "height": int(viewport_size.y), "passed": failures == before})
		# Derrota, bloqueio após o fim do tempo e tentativa gratuita em cada fase cronometrada.
		app.level_index = number - 1
		app.start_game(false)
		if app.session.has_time_limit():
			await _touch(_cell_center(app, int(report["moves"][0])))
			app.session.tick(app.session.time_limit + 1)
			app._sync_controls()
			var moves_before: int = app.session.moves
			# O toque na grade não pode acertar uma ação válida do próprio resultado.
			var blocked_point := Vector2.INF
			for value in report["moves"]:
				var point := _cell_center(app, int(value))
				if not app.buttons["continue"].get_global_rect().has_point(point) and not app.buttons["exit"].get_global_rect().has_point(point):
					blocked_point = point
					break
			_check(blocked_point.is_finite(), "Fase %d tem ponto de teste fora das ações do resultado" % number)
			await _touch(blocked_point)
			_check(app.session.state == Session.State.LOST and app.session.moves == moves_before, "Fase %d bloqueia jogada após tempo acabar" % number)
			await _click(app.buttons["continue"].get_global_rect().get_center())
			await _dismiss_intro(app)
			_check(app.level_index == number - 1 and app.session.moves == 0 and app.session.state == Session.State.READY, "Fase %d permite repetir após derrota" % number)
		results.append({"id": number, "minimum_taps": report["minimum_taps"], "passed": failures == level_checks_before, "variants": variants})
		print("Jogabilidade da fase %d: %s; mouse/toque em duas dimensões." % [number, "OK" if failures == level_checks_before else "FALHOU"])
	var result_file := FileAccess.open("res://builds/gameplay-results.json", FileAccess.WRITE)
	if result_file == null:
		_check(false, "Gravação do resultado por fase")
	else:
		result_file.store_string(JSON.stringify({"levels": results}, "\t"))
		result_file.close()
	var report_file := FileAccess.open("res://docs/TESTES_FASES.md", FileAccess.READ_WRITE)
	if report_file == null:
		_check(false, "Gravação do relatório de jogabilidade")
	else:
		report_file.seek_end()
		report_file.store_string("\n## Resultado na interface da engine\n\nQuatro cenários por fase: mouse e toque nas dimensões 720×1280 e 360×800. Cada cenário verifica pausa, peças não giráveis, reinício, solução independente, resultado e progressão. As fases com relógio também verificam derrota por tempo e nova tentativa.\n\n| Fase | Cenários aprovados | Resultado |\n| --- | --- | --- |\n")
		for row in results:
			var passed_variants := 0
			for variant in row["variants"]:
				if variant["passed"]:
					passed_variants += 1
			report_file.store_string("| %d | %d / 4 | %s |\n" % [int(row["id"]), passed_variants, "APROVADA" if row["passed"] else "FALHOU"])
		report_file.close()
	var hint_file := "res://builds/hint-results.json"
	if FileAccess.file_exists(hint_file):
		var hint_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(hint_file))
		var passed_hints := 0
		for row in hint_data["levels"]:
			if row["passed"]:
				passed_hints += 1
		var feature_report := FileAccess.open("res://docs/TESTES_FASES.md", FileAccess.READ_WRITE)
		if feature_report != null:
			feature_report.seek_end()
			feature_report.store_string("\n## Seletor, progresso e dica gratuita\n\n- Dica gratuita: **%d / 24 fases aprovadas** após corrigir e prender um fio.\n- Seletor: grupos 4×4, 5×5 e 6×6, bloqueios, seleção de fases concluídas e navegação em janela estreita.\n- Recordes: melhores estrelas, pontuação e tempo por fase, sem redução ao rejogar.\n- Persistência: gravação/releitura, atualização da cópia de segurança e recuperação de perfil inválido.\n- Migração: desbloqueios e preferências antigos preservados, sem inventar recordes desconhecidos.\n" % passed_hints)
			feature_report.close()
	app.queue_free()
	await process_frame


func _touch(point: Vector2) -> void:
	for pressed in [true, false]:
		var event := InputEventScreenTouch.new()
		event.index = 0
		event.position = point
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame


func _click(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame


func _dismiss_intro(app) -> void:
	# Estes cenários exercitam o puzzle; a conversa tem sua própria suíte de interação.
	if app.dialogue.active:
		await _click(app.dialogue.skip_button.get_global_rect().get_center())
