extends RefCounted

const Board = preload("res://scripts/circuit_board.gd")
const Session = preload("res://scripts/game_session.gd")
const Solution = preload("res://scripts/circuit_solution.gd")


func run(check: Callable) -> void:
	# A cadeira já está ligada; a lâmpada está no ramo sul do T.
	var data := {"id": 1, "size": 2, "time_limit": 90, "source_index": 0,
		"source_port": 8, "target_index": 1, "target_port": 2, "required_nodes": [2],
		"cells": [{"kind": "tee", "rotation": 2, "fixed": true},
			{"kind": "straight", "rotation": 1, "fixed": true},
			{"kind": "straight", "rotation": 1}, {"kind": "empty", "rotation": 0}]}
	var session := Session.new()
	session.start(data)
	check.call(session.board.energized.has(1) and not session.board.solved, "OUT sozinho não vence com lâmpada apagada")
	check.call(session.state == Session.State.READY and session.remaining == 90, "Apresentar objetivo não inicia cronômetro")
	var plan := Solution.new().solve(session.board)
	check.call(not plan.is_empty() and plan["taps"] == 1 and plan["path"].has(2), "Resolvedor inclui ramo da lâmpada fora do caminho até OUT")
	check.call(session.use_hint() == 2 and session.board.solved, "Dica corrige lâmpada sem alterar T ou terminais fixos")
	check.call(session.state == Session.State.RESOLVING, "Descarga começa somente com cadeira e lâmpada energizadas")
	session.start(data)
	check.call(session.rotate_cell(2) and session.board.solved, "Jogador pode resolver ramificação manualmente")
	data["cells"][2]["fixed"] = true
	session.start(data)
	check.call(Solution.new().solve(session.board).is_empty(), "Ramo fixo desconectado é impossível")
	check.call(session.use_hint() == -1 and session.hints_used == 0, "Dica impossível não gasta ajuda nem altera fios")
	data.erase("required_nodes")
	session.start(data)
	check.call(session.board.solved, "Fase clássica não exige lâmpada")
	for invalid in [[-1], [4], [3], [2, 2], [1], "2", [1.5]]:
		data["required_nodes"] = invalid
		session.start(data)
		check.call(not session.board.objectives_valid and not session.board.solved, "Objetivo inválido falha fechado: " + str(invalid))
		check.call(Solution.new().solve(session.board).is_empty(), "Dados inválidos não produzem dica")
	for number in range(1, 25):
		var campaign: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_%02d.json" % number))
		session.start(campaign)
		check.call(not session.board.required_nodes.is_empty() == (number in [10, 11]), "Desafio escolhido pela autoria; fase %d" % number)
		check.call(session.board.objectives_valid, "Objetivos válidos na fase %d" % number)
		if number in [10, 11]:
			check.call(campaign["rules_revision"] == 2, "Regras novas têm revisão própria")


func run_ui(app, check: Callable) -> void:
	for dimensions in [Vector2(360, 800), Vector2(720, 1280), Vector2(720, 1600)]:
		app.size = dimensions
		app._layout_stage()
		app.level_index = 10
		app.start_game(false)
		# Montar OUT, deixando o ramo da lâmpada desligado.
		for value in app.level_data["reference_path"]:
			var index := int(value)
			var cell: Dictionary = app.session.board.cells[index]
			for turn in range(4):
				if app.session.board.mask_at(index) == Board.rotate_mask(Board.BASE_MASKS[cell["kind"]], cell["solution"]):
					break
				app._on_cell_pressed(index)
		check.call(app.session.board.target_connected() and not app.session.board.solved, "OUT conectado aguarda lâmpada na interface")
		check.call(app.session.state == Session.State.PLAYING and app.resolution_elapsed == 0, "Nenhum choque prematuro com objetivo pendente")
		check.call(app.feedback.contains("Falta acender") and app.session.board.lit_required_count() == 0, "Feedback explica pendência da lâmpada")
		var badge: Rect2 = app.board_view.lamp_rect(6)
		check.call(app.board_view.cell_rect(6).encloses(badge) and badge.size.x >= 27, "Ícone de lâmpada cabe na célula")
		app.pause_game()
		var cells: Array = app.session.board.cells.duplicate(true)
		app._on_cell_pressed(6)
		check.call(app.session.board.cells == cells, "Pausa bloqueia ramo da lâmpada")
		app.resume_game()
		app.use_free_hint()
		check.call(app.session.board.solved and app.session.state == Session.State.RESOLVING, "Dica completa ramo pendente e inicia descarga")
		app._process(app.RESOLUTION_DURATION + 0.01)
		check.call(app.profile.level_record(11)["rules_revision"] == 2, "Vitória pela interface salva revisão nova")
	app.level_index = 11
	app.start_game(false)
	check.call(app.session.board.required_nodes.is_empty(), "Fase seguinte volta à regra clássica")
