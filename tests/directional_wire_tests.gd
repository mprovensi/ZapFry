extends RefCounted

const Board = preload("res://scripts/circuit_board.gd")
const Session = preload("res://scripts/game_session.gd")
const Solution = preload("res://scripts/circuit_solution.gd")


func run(check: Callable) -> void:
	for route in [[0, 1, 2, 8, 2, 1], [2, 5, 8, 1, 4, 2], [8, 7, 6, 2, 8, 3], [6, 3, 0, 4, 1, 0]]:
		for rotation in range(4):
			var cells: Array = []
			for index in range(9):
				cells.append({"kind": "empty", "rotation": 0})
			for index in [route[0], route[2]]:
				cells[index] = {"kind": "straight", "rotation": route[5] % 2, "fixed": true}
			cells[route[1]] = {"kind": "diode", "rotation": rotation}
			var board := Board.new()
			board.load_level({"size": 3, "cells": cells, "source_index": route[0], "source_port": route[3], "target_index": route[2], "target_port": route[4]})
			check.call(board.solved == (rotation == route[5]), "Seta só conduz da cauda para a ponta: " + str(route) + "/" + str(rotation))
			var plan := Solution.new().solve(board)
			check.call(not plan.is_empty() and plan["taps"] == posmod(route[5] - rotation, 4), "Resolvedor distingue as quatro orientações do fio direcional")
	var fixture := {"id": 1, "size": 2, "time_limit": 90, "source_index": 0, "source_port": 8,
		"target_index": 1, "target_port": 2, "required_nodes": [2], "cells": [
			{"kind": "tee", "rotation": 2, "fixed": true}, {"kind": "straight", "rotation": 1, "fixed": true},
			{"kind": "diode", "rotation": 0}, {"kind": "empty", "rotation": 0}]}
	var session := Session.new()
	session.start(fixture)
	check.call(not session.board.solved and session.board.target_connected(), "Seta invertida impede acender a lâmpada mesmo com OUT ligado")
	check.call(session.hint_candidate() == 2 and session.use_hint() == 2, "Dica encontra seta invertida com a mesma máscara visual")
	check.call(session.moves == 2 and session.board.solved and not session.board.can_rotate(2), "Dica gira 180 graus, trava a seta e vence por ramificação válida")
	session.start(fixture)
	check.call(session.rotate_cell(2) and not session.board.solved, "Primeiro giro de 90 graus ainda não fecha a rede")
	check.call(session.rotate_cell(2) and session.board.solved, "Segundo giro permite corrente pela entrada correta")
	fixture["cells"][2]["fixed"] = true
	session.start(fixture)
	check.call(session.use_hint() == -1 and session.hints_used == 0, "Seta fixa impossível não consome dica")
	var cycle := {"size": 3, "source_index": 0, "source_port": 1, "target_index": 6, "target_port": 4,
		"required_nodes": [1], "cells": []}
	for item in [["tee", 1], ["diode", 0], ["curve", 2], ["straight", 0], ["empty", 0], ["straight", 0], ["tee", 1], ["straight", 1], ["curve", 3]]:
		cycle["cells"].append({"kind": item[0], "rotation": item[1], "fixed": item[0] != "diode"})
	for rotation in range(4):
		cycle["cells"][1]["rotation"] = rotation
		var board := Board.new()
		board.load_level(cycle)
		check.call(board.solved == (rotation in [1, 3]), "Ciclo dirigido termina e aceita entrada válida por qualquer caminho")
		check.call(Solution.new().solve(board)["taps"] == (0 if rotation in [1, 3] else 1), "Resolvedor encontra o ramo de menor custo no ciclo")
	for number in range(1, 25):
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_%02d.json" % number))
		var has_arrow := false
		for cell in data["cells"]:
			has_arrow = has_arrow or cell["kind"] == "diode"
		check.call(has_arrow == (number in [13, 14, 16]), "Seta aparece somente onde foi definida: fase %d" % number)


func run_ui(app, check: Callable) -> void:
	for dimensions in [Vector2(360, 800), Vector2(720, 1280), Vector2(720, 1600)]:
		app.size = dimensions
		app._layout_stage()
		app.level_index = 12
		app.start_game(false)
		var arrow := 10
		var goal := int(app.session.board.cells[arrow]["solution"])
		for cell in app.session.board.cells:
			cell["rotation"] = cell["solution"]
		app.session.board.cells[arrow]["rotation"] = posmod(goal - 3, 4)
		app.session.board.recompute()
		app._on_cell_pressed(arrow)
		check.call(app.session.board.direction_blocked(arrow) and app.feedback.contains("Seta invertida"), "Interface explica corrente bloqueada pela ponta da seta")
		check.call(not app.session.board.solved and app.session.state == Session.State.PLAYING and app.shock_flash_alpha() == 0, "Seta invertida não inicia choque nem resultado")
		app.pause_game()
		var cells: Array = app.session.board.cells.duplicate(true)
		app._on_cell_pressed(arrow)
		check.call(app.session.board.cells == cells, "Pausa impede giro do fio direcional")
		app.resume_game()
		var before: int = app.session.moves
		app.use_free_hint()
		check.call(app.board_view.hint_index == arrow and app.session.moves == before + 2, "Dica da interface corrige exatamente 180 graus")
		check.call(app.session.board.solved and app.session.state == Session.State.RESOLVING and not app.session.board.can_rotate(arrow), "Dica fixa seta correta e inicia a sequência normal")
		app._process(app.RESOLUTION_DURATION + 0.01)
		check.call(app.profile.level_record(13)["rules_revision"] == 2, "Resultado da seta registra revisão nova das regras")
