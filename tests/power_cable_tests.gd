extends RefCounted


func run_ui(app, check: Callable) -> void:
	for viewport in [Vector2(720, 1280), Vector2(360, 800), Vector2(720, 1600)]:
		app.size = viewport
		for index in range(app.levels.size()):
			app.level_index = index
			app.start_game(false)
			var paths: Array[Curve2D] = app.cable_view.connection_paths()
			check.call(app.cable_view.visible and paths.size() == 2, "Fase %d tem dois cabos na dimensão %s" % [index + 1, viewport])
			if paths.size() != 2:
				continue
			var cable_transform: Transform2D = app.cable_view.get_global_transform()
			var input: Vector2 = app.board_view.get_global_transform() * app.board_view.terminal_position(app.session.board.source_index, Vector2.LEFT)
			var output: Vector2 = app.board_view.get_global_transform() * app.board_view.terminal_position(app.session.board.target_index, Vector2.RIGHT)
			var generator: Vector2 = app.operator_view.get_global_transform() * app.operator_view.cable_connection_point()
			var chair: Vector2 = app.room_view.get_global_transform() * app.room_view.cable_connection_point()
			check.call((cable_transform * paths[0].get_point_position(0)).is_equal_approx(generator) and (cable_transform * paths[0].get_point_position(paths[0].point_count - 1)).is_equal_approx(input), "Mangueira de entrada liga o gerador ao IN real")
			check.call((cable_transform * paths[1].get_point_position(0)).is_equal_approx(output) and (cable_transform * paths[1].get_point_position(paths[1].point_count - 1)).is_equal_approx(chair), "Mangueira de saída liga o OUT real à cadeira")
			for route in range(2):
				var path: Curve2D = paths[route]
				var terminal: Vector2 = input if route == 0 else output
				var scale: float = app.stage.scale.x
				var grid: Rect2 = app.board_view.get_global_rect().grow(12 * scale)
				var clear := true
				var inside := true
				var distance := 0.0
				while distance <= path.get_baked_length():
					var point: Vector2 = cable_transform * path.sample_baked(distance, true)
					if grid.has_point(point) and point.distance_to(terminal) > 34 * scale:
						clear = false
					var extent := Vector2.ONE * 14 * scale
					if not app.get_global_rect().encloses(Rect2(point - extent, extent * 2)):
						inside = false
					distance += 6
				check.call(clear, "Cabo %d da fase %d mantém as células livres fora do encaixe" % [route, index + 1])
				check.call(inside, "Cabo %d da fase %d cabe na tela" % [route, index + 1])
	var original = app.execution_character
	var cells: Array = app.session.board.cells.duplicate(true)
	var replacement = original.duplicate()
	replacement.cable_anchor = Vector2(0.66, 0.72)
	var previous: Vector2 = app.cable_view.connection_paths()[1].get_point_position(4)
	app.execution_character = replacement
	app._sync_controls()
	var current: Vector2 = app.cable_view.connection_paths()[1].get_point_position(4)
	check.call(not current.is_equal_approx(previous) and app.session.board.cells == cells, "Outro ocupante pode mudar o encaixe do cabo sem alterar o puzzle")
	app.execution_character = original
	app.show_menu()
	check.call(not app.cable_view.visible, "Menu não recebe as mangueiras da partida")
	app.show_levels()
	check.call(not app.cable_view.visible, "Seletor não recebe as mangueiras da partida")
	print("Cabos: IN/OUT, curvas fora da matriz e encaixe substituível em 24 fases e três dimensões.")
