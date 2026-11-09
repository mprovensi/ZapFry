extends RefCounted

const Board = preload("res://scripts/circuit_board.gd")
const Session = preload("res://scripts/game_session.gd")
const Solution = preload("res://scripts/circuit_solution.gd")


func alarm_fixture() -> Dictionary:
	return {"id": 1, "size": 2, "time_limit": 90, "source_index": 0, "source_port": 8,
		"target_index": 1, "target_port": 2, "forbidden_nodes": [2], "cells": [
			{"kind": "tee", "rotation": 2, "fixed": true}, {"kind": "straight", "rotation": 1, "fixed": true},
			{"kind": "straight", "rotation": 0}, {"kind": "empty", "rotation": 0}]}


func pair_fixture(turns: int = 1) -> Dictionary:
	var cells: Array = []
	for index in range(9):
		cells.append({"kind": "empty", "rotation": 0})
	cells[0] = {"kind": "curve", "rotation": 2, "fixed": true}
	cells[3] = {"kind": "curve", "rotation": posmod(-turns, 4)}
	cells[4] = {"kind": "straight", "rotation": 1, "fixed": true}
	cells[5] = {"kind": "curve", "rotation": posmod(2 - turns, 4)}
	cells[8] = {"kind": "curve", "rotation": 0, "fixed": true}
	return {"id": 1, "size": 3, "time_limit": 90, "source_index": 0, "source_port": 8,
		"target_index": 8, "target_port": 2, "linked_groups": [[3, 5]], "cells": cells}


func switch_fixture() -> Dictionary:
	return {"id": 1, "size": 2, "time_limit": 90, "source_index": 0, "source_port": 8,
		"target_index": 3, "target_port": 2, "cells": [
			{"kind": "curve", "rotation": 2, "fixed": true}, {"kind": "empty", "rotation": 0},
			{"kind": "switch", "rotation": 1, "switch_masks": [3, 9]},
			{"kind": "straight", "rotation": 1, "fixed": true}]}


func run(check: Callable) -> void:
	var session := Session.new()
	var alarm := alarm_fixture()
	session.start(alarm)
	check.call(session.board.target_connected() and not session.board.solved, "OUT ligado aguarda alarme desligado")
	check.call(session.use_hint() == 2 and session.moves == 1 and session.board.solved, "Dica pode corrigir fio fora do caminho OUT para desligar alarme")
	alarm["cells"][2]["fixed"] = true
	session.start(alarm)
	check.call(Solution.new().solve(session.board).is_empty() and session.use_hint() == -1 and session.hints_used == 0, "Alarme impossível não consome dica")
	alarm = alarm_fixture()
	alarm["cells"][3] = {"kind": "curve", "rotation": 0}
	session.start(alarm)
	session.rotate_cell(3)
	session.tick(3)
	check.call(session.state == Session.State.PLAYING and session.remaining == 87 and session.board.energized.has(2), "Alarme mantém tentativa ativa e relógio normal")
	session.rotate_cell(2)
	check.call(session.state == Session.State.RESOLVING, "Desligar alarme permite recuperação e descarga normal")
	session.start(switch_fixture())
	check.call(Solution.new().solve(session.board)["taps"] == 1 and session.use_hint() == 2 and session.moves == 1, "Interruptor B para A custa um toque, inclusive na dica")
	check.call(session.board.cells[2]["rotation"] == 0 and session.board.solved, "Interruptor só usa dois estados estáveis")
	for turns in range(1, 4):
		for index in [3, 5]:
			session.start(pair_fixture(turns))
			check.call(Solution.new().solve(session.board)["taps"] == turns, "Dupla mede custo em ações, não em peças giradas")
			var revision: int = session.board.revision
			session.rotate_cell(index)
			check.call(session.board.revision == revision + 1 and session.moves == 1, "Dupla recalcula uma vez e conta uma ação por toque")
			check.call(session.board.cells[3]["rotation"] == posmod(1 - turns, 4) and session.board.cells[5]["rotation"] == posmod(3 - turns, 4), "Toque em qualquer membro gira ambos atomicamente")
		session.start(pair_fixture(turns))
		var revision: int = session.board.revision
		check.call(session.use_hint() in [3, 5] and session.board.solved and session.moves == turns, "Dica da dupla produz solução consistente")
		check.call(not session.board.can_rotate(3) and not session.board.can_rotate(5) and session.board.revision == revision + 1, "Dica trava toda a dupla numa única alteração")
	var equipment := alarm_fixture()
	equipment.erase("forbidden_nodes")
	equipment["required_outputs"] = [{"index": 2, "port": 8}]
	equipment["cells"][2] = {"kind": "curve", "rotation": 0}
	session.start(equipment)
	check.call(session.board.energized.has(2) and not session.board.solved and session.board.lit_required_count() == 0, "Equipamento exige porta de saída, além de energia")
	check.call(session.use_hint() == 2 and session.board.solved and session.moves == 3, "Dica respeita terminal do segundo equipamento")
	_test_invalid(check)


func _test_invalid(check: Callable) -> void:
	var board := Board.new()
	for field in ["required_outputs", "forbidden_nodes", "linked_groups"]:
		var data := alarm_fixture()
		data[field] = "inválido"
		board.load_level(data)
		check.call(not board.objectives_valid and not board.solved and Solution.new().solve(board).is_empty(), "Dados novos inválidos falham fechados: " + field)
	for nodes in [[-1], [4], [2, 2], [true], [1.5], [0], [3]]:
		var data := alarm_fixture()
		data["forbidden_nodes"] = nodes
		board.load_level(data)
		check.call(not board.objectives_valid, "Índice de alarme inválido rejeitado: " + str(nodes))
	var conflict := alarm_fixture()
	conflict["required_nodes"] = [2]
	board.load_level(conflict)
	check.call(not board.objectives_valid, "Não se pode exigir e proibir energia na mesma célula")
	for groups in [[[3, 3]], [[3, 5], [5, 3]], [[0, 3]], [[3, 4]], [[3]], [[3, 10]]]:
		var data := pair_fixture()
		data["linked_groups"] = groups
		board.load_level(data)
		check.call(not board.objectives_valid, "Dupla inválida, sobreposta ou fixa rejeitada")
	for masks in [[3], [3, 3], [3, 12], [0, 3], [true, 9], [3, 17]]:
		var data := switch_fixture()
		data["cells"][2]["switch_masks"] = masks
		board.load_level(data)
		check.call(not board.objectives_valid, "Contatos inválidos de interruptor rejeitados")


func _reference_except(app, number: int) -> void:
	app.level_index = number - 1
	app.start_game(false)
	for cell in app.session.board.cells:
		cell["rotation"] = cell["solution"]
	app.session.board.recompute()


func run_ui(app, check: Callable) -> void:
	for dimensions in [Vector2(360, 800), Vector2(720, 1280), Vector2(720, 1600)]:
		app.size = dimensions
		app._layout_stage()
		_reference_except(app, 18)
		app.session.board.cells[4]["rotation"] = 2
		app.session.board.recompute()
		app._on_cell_pressed(4)
		app.session.tick(3)
		check.call(app.session.state == Session.State.PLAYING and app.session.board.target_connected() and app.session.board.active_alarm_count() == 1, "Alarme na interface bloqueia descarga, sem derrota")
		check.call(app.feedback.contains("Alarme ligado") and app.shock_flash_alpha() == 0 and app.session.remaining == 207, "Alarme explica correção e preserva regra do relógio")
		app.pause_game()
		var snapshot: Array = app.session.board.cells.duplicate(true)
		app._on_cell_pressed(4)
		app.use_free_hint()
		check.call(app.session.board.cells == snapshot and app.session.hints_used == 0, "Pausa bloqueia correção e dica do alarme")
		app.resume_game()
		app.use_free_hint()
		check.call(app.session.state == Session.State.RESOLVING and app.session.board.active_alarm_count() == 0, "Dica desliga o alarme e libera a descarga")
		app._process(app.RESOLUTION_DURATION + 0.01)
		check.call(app.profile.level_record(18)["rules_revision"] == 2, "Vitória com alarme registra revisão de regras nova")
		_reference_except(app, 21)
		app.session.board.cells[13]["rotation"] = 0
		app.session.board.recompute()
		app._on_cell_pressed(13)
		check.call(app.session.moves == 1 and app.session.board.cells[13]["rotation"] == 1 and app.session.state == Session.State.RESOLVING, "Interruptor alterna A/B e fecha circuito com uma ação")
		_reference_except(app, 23)
		for index in [2, 22]:
			app.session.board.cells[index]["rotation"] = posmod(int(app.session.board.cells[index]["solution"]) - 1, 4)
		app.session.board.recompute()
		app.board_view._press_at(app.board_view.cell_rect(22).get_center())
		check.call(app.session.moves == 1 and app.session.state == Session.State.RESOLVING and app.board_view.activated == 22, "Toque no segundo fio aciona toda a dupla")
		_reference_except(app, 23)
		for index in [2, 22]:
			app.session.board.cells[index]["rotation"] = posmod(int(app.session.board.cells[index]["solution"]) - 2, 4)
		app.session.board.recompute()
		app.use_free_hint()
		check.call(app.session.moves == 2 and app.feedback.contains("Dupla") and app.session.board.solved, "Dica da dupla conta ações e explica a correção conjunta")
		check.call(not app.session.board.can_rotate(2) and not app.session.board.can_rotate(22) and app.session.board.action_members(app.board_view.hint_index).has(22), "Dica destaca e trava os dois membros")
		_reference_except(app, 24)
		app.session.board.cells[5]["rotation"] = 3
		app.session.board.recompute()
		app._on_cell_pressed(15)
		check.call(app.session.board.target_connected() and app.session.board.lit_required_count() == 0 and app.session.state == Session.State.PLAYING, "Cadeira ligada aguarda saída do ventilador")
		check.call(app.feedback.contains("ventilador"), "Feedback diferencia equipamento de lâmpada")
		app.use_free_hint()
		check.call(app.session.board.solved and app.session.board.lit_required_count() == 1, "Dica conecta a porta do segundo equipamento")
		app.board_view._process(0.5)
		check.call(app.board_view.equipment_time > 0, "Ventilador energizado recebe animação de funcionamento")
		app._process(app.RESOLUTION_DURATION + 0.01)
		check.call(app.campaign_ending.visible and app.profile.level_record(24)["rules_revision"] == 2, "Último equipamento mantém agradecimento e registro da fase 24")
