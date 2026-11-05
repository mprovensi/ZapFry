extends RefCounted

const Session = preload("res://scripts/game_session.gd")
const Solution = preload("res://scripts/circuit_solution.gd")


func run(check: Callable) -> void:
	var input: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://builds/hint-states-input.json"))
	var results: Array = []
	for case in input["cases"]:
		var session := Session.new()
		session.start(case["state"])
		var plan := Solution.new().solve(session.board)
		var expected := int(case["minimum_before"])
		check.call((-1 if plan.is_empty() else int(plan["taps"])) == expected, "Solução nativa concorda com auditor independente: " + case["name"])
		var cells: Array = session.board.cells.duplicate(true)
		var started := Time.get_ticks_usec()
		var index := session.hint_candidate()
		var solve_ms := float(Time.get_ticks_usec() - started) / 1000.0
		var cached: Dictionary = session._hint_plan
		session.hint_candidate()
		check.call(is_same(cached, session._hint_plan), "Dica reutiliza cache sem recalcular a cada quadro")
		var remaining := session.remaining
		check.call(session.use_hint() == index, "Dica aplica a peça anunciada: " + case["name"])
		check.call(session.remaining == remaining, "Dica não altera o cronômetro")
		var snapshot: Dictionary = session.level.duplicate(true)
		snapshot["cells"] = session.board.cells.duplicate(true)
		var unchanged := true
		for other in range(cells.size()):
			if other != index and cells[other] != session.board.cells[other]:
				unchanged = false
		check.call(unchanged, "Dica altera somente um fio: " + case["name"])
		if expected < 0:
			check.call(index == -1 and session.hints_used == 0, "Estado impossível não gasta dica")
			results.append({"name": case["name"], "index": index, "state_after_hint": snapshot})
			continue
		check.call(index >= 0 and session.hints_used == 1 and not session.board.can_rotate(index), "Dica útil fixa exatamente um fio")
		if index < 0:
			continue
		check.call(index != int(case["valid_tee"]), "Dica preserva T já conectado")
		var actual_turns := posmod(int(session.board.cells[index]["rotation"]) - int(cells[index]["rotation"]), 4)
		check.call(session.moves == actual_turns and actual_turns > 0, "Dica contabiliza giros reais")
		var after := Solution.new().solve(session.board)
		check.call(not after.is_empty() and int(after["taps"]) < expected, "Dica reduz os giros restantes: " + case["name"])
		if after.is_empty():
			continue
		for value in after["path"]:
			var cell_index := int(value)
			var goal: int = after["rotations"][cell_index]
			var turns := posmod(goal - int(session.board.cells[cell_index]["rotation"]), 4)
			for turn in range(turns):
				session.tick(2.0)
				check.call(session.rotate_cell(cell_index), "Plano após dica usa rotações permitidas")
		check.call(session.state == Session.State.RESOLVING and session.board.solved, "Estado conclui após dica: " + case["name"])
		check.call(session.elapsed == 0 or not session.has_time_limit() or session.remaining > 0, "Solução após dica cabe no cronômetro integral simulado")
		results.append({"name": case["name"], "index": index, "state_after_hint": snapshot,
			"minimum_after_native": after["taps"], "unchanged_others": unchanged,
			"completed": session.board.solved, "in_time": not session.has_time_limit() or session.remaining > 0,
			"solve_ms": solve_ms})
		# Qualquer rotação posterior invalida o plano, inclusive após reiniciar.
		session.start(case["state"])
		session.hint_candidate()
		for next in range(session.board.cells.size()):
			if session.board.can_rotate(next):
				session.rotate_cell(next)
				if not session.board.solved:
					session.hint_candidate()
					check.call(session._hint_revision == session.board.revision, "Giro invalida cache da dica")
				break
	var output := FileAccess.open("res://builds/hint-states-output.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"cases": results}, "\t"))
	output.close()
	print("Dicas em estados variados: %d casos executados pela engine." % results.size())
