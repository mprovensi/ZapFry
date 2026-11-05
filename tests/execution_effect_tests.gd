extends RefCounted

const Session = preload("res://scripts/game_session.gd")


func run_ui(app, check: Callable) -> void:
	check.call(app.RESOLUTION_DURATION >= 2.3 and app.ZAP_END_TIME - app.SWITCH_PULL_TIME >= 1.2, "Choque e sequência têm mais tempo para leitura")
	var original: Dictionary = app.levels[0]
	var timed: Dictionary = original.duplicate(true)
	timed["time_limit"] = 120
	app.levels[0] = timed
	app.sound_enabled = false
	check.call(app.shock_flash.get_index() > app.board_view.get_index() and app.shock_flash.get_index() > app.room_view.get_index() and app.shock_flash.get_index() < app.overlay.get_index(), "Clarão fica acima da matriz e dos atores, antes do resultado")
	check.call(app.shock_flash.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Clarão não intercepta toques")
	for soft in [false, true]:
		app.reduced_flashes = soft
		app.level_index = 0
		app.start_game(false)
		check.call(app.shock_flash_alpha() == 0 and app.background_shake_offset() == Vector2.ZERO, "Partida nova não herda impacto visual")
		app._on_cell_pressed(1)
		var cells: Array = app.session.board.cells.duplicate(true)
		var remaining: float = app.session.remaining
		var records: Dictionary = app.profile.records.duplicate(true)
		var visible_throughout := true
		var bounded := true
		var still_before_result := true
		var observed_shake := false
		var flash_count := 0
		var previous_flash := false
		var extended_zap := false
		var flash_during_haptic := false
		var skeleton_throughout := true
		var flash_presented := true
		var skeleton: Texture2D = app.execution_character.frame_texture(&"zap", 0.0)
		for frame in range(int(ceil(app.RESOLUTION_DURATION * 120))):
			var time := float(frame) / 120.0
			app.resolution_elapsed = time
			app._sync_controls()
			var flash: float = app.shock_flash_alpha()
			flash_presented = flash_presented and is_equal_approx(app.shock_flash.color.a, flash) and app.shock_flash.visible == (flash > 0)
			var offset: Vector2 = app.background_shake_offset()
			var lit := flash > 0.01
			if time >= app.SWITCH_PULL_TIME and time < app.ZAP_END_TIME:
				skeleton_throughout = skeleton_throughout and app.room_view.portrait_texture() == skeleton
			if time >= app.SWITCH_PULL_TIME and time < app.SWITCH_PULL_TIME + 0.8:
				flash_during_haptic = flash_during_haptic or flash > 0.03
			if lit and not previous_flash:
				flash_count += 1
			previous_flash = lit
			observed_shake = observed_shake or offset.length() > 0.1
			bounded = bounded and offset.is_finite() and absf(offset.x) <= 5 and absf(offset.y) <= 3 and flash >= 0 and flash <= (0.071 if soft else 0.181)
			still_before_result = still_before_result and not app.overlay.visible and app.session.state == Session.State.RESOLVING
			visible_throughout = visible_throughout and app.room_view.visible and app.room_view.modulate.a == 1 and app.room_view.self_modulate.a == 1 and app.room_view.portrait_texture() != null
			if time < app.SWITCH_PULL_TIME or time >= app.ZAP_END_TIME:
				bounded = bounded and flash == 0 and offset == Vector2.ZERO
			if absf(time - 1.65) < 0.001:
				extended_zap = app.room_view.state == &"zap"
		check.call(visible_throughout and still_before_result, "Ocupante permanece visível sem resultado cobrir a animação; suave=%s" % soft)
		check.call(skeleton_throughout, "Sprite do esqueleto é exibido em toda a janela de choque; suave=%s" % soft)
		check.call(flash_presented, "Clarão é apresentado pela camada da partida em todos os frames; suave=%s" % soft)
		check.call(bounded, "Impacto respeita limites, bordas e momento do choque; suave=%s" % soft)
		check.call(extended_zap, "O choque ainda aparece no antigo instante de encerramento")
		check.call(flash_count == (1 if soft else 3), "Modo suave tem brilho contínuo; normal tem três clarões separados")
		check.call(flash_during_haptic, "Clarão ou brilho ocorre durante os 800 ms de vibração física; suave=%s" % soft)
		check.call(observed_shake != soft, "Modo normal vibra o fundo; modo suave mantém o cenário estável")
		check.call(app.session.board.cells == cells and app.session.moves == 1 and app.session.remaining == remaining and app.profile.records == records, "Animação prolongada não consome relógio nem altera puzzle ou recordes antes do resultado")
		app._process(0.02)
		check.call(app.session.state == Session.State.WON and app.overlay.visible, "Resultado só aparece depois dos 2,4 segundos")
		check.call(app.shock_flash_alpha() == 0 and app.background_shake_offset() == Vector2.ZERO, "Vitória encerra flashes e tremor")
	app.levels[0] = original
	app.show_menu()
	check.call(app.shock_flash_alpha() == 0 and app.background_shake_offset() == Vector2.ZERO, "Menu não recebe efeito residual")
	app.start_game(false)
	check.call(app.shock_flash_alpha() == 0 and app.background_shake_offset() == Vector2.ZERO, "Reinício limpa completamente a sequência")
	_test_frame_rates(app, check)
	print("Impacto: clarão sobre a partida, tremor limitado, modo suave e esqueleto visível em toda a sequência.")


func _test_frame_rates(app, check: Callable) -> void:
	app.sound_enabled = true
	app.profile.music_volume = 1
	app.profile.effects_volume = 1
	app.audio._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	for fps in [30, 60, 120]:
		for soft in [false, true]:
			for vibration in [false, true]:
				var context := "%d FPS, suave=%s, vibração=%s" % [fps, soft, vibration]
				app.profile.vibration_enabled = vibration
				app.reduced_flashes = soft
				app.level_index = 0
				app.start_game(false)
				var skeleton: Texture2D = app.execution_character.frame_texture(&"zap", 0.0)
				app._on_cell_pressed(1)
				var cells: Array = app.session.board.cells.duplicate(true)
				var remaining: float = app.session.remaining
				var wins := int(app.profile.level_record(1).get("completions", 0))
				var transforms: Array = []
				var controls: Array = [app.stage, app.board_view, app.room_view, app.operator_view, app.phase_label, app.buttons["pause"], app.buttons["hint"]]
				for control in controls:
					transforms.append(control.get_global_transform())
				var minimum := Vector2.ZERO
				var maximum := Vector2.ZERO
				var early_peak := 0.0
				var late_peak := 0.0
				var saw_zap := false
				var zap_cues := 0
				var stable := true
				var duration := float(app.ZAP_END_TIME - app.SWITCH_PULL_TIME)
				for frame in range(int(ceil(app.RESOLUTION_DURATION * fps)) + 2):
					if app.session.state != Session.State.RESOLVING:
						break
					var serial: int = app.audio.cue_serial
					app._process(1.0 / fps)
					if app.audio.cue_serial > serial and app.audio.last_cue == "zap":
						zap_cues += 1
					var offset: Vector2 = app.background_shake_offset()
					minimum = minimum.min(offset)
					maximum = maximum.max(offset)
					var time: float = app.resolution_elapsed
					if time >= app.SWITCH_PULL_TIME and time < app.ZAP_END_TIME:
						saw_zap = true
						check.call(app.room_view.portrait_texture() == skeleton and not app.overlay.visible, "Esqueleto visível antes do resultado; " + context)
						if time < app.SWITCH_PULL_TIME + duration / 3.0:
							early_peak = maxf(early_peak, offset.length())
						if time > app.ZAP_END_TIME - duration / 3.0:
							late_peak = maxf(late_peak, offset.length())
					for index in range(controls.size()):
						stable = stable and controls[index].get_global_transform().is_equal_approx(transforms[index])
					check.call(offset.is_finite() and absf(offset.x) <= 5 and absf(offset.y) <= 3, "Tremor limitado a cada passo; " + context)
				check.call(saw_zap and zap_cues == 1, "Choque e áudio único atravessam a sequência; " + context)
				if soft:
					check.call(minimum == Vector2.ZERO and maximum == Vector2.ZERO, "Modo suave permanece sem tremor; " + context)
				else:
					check.call(minimum.x < -0.1 and maximum.x > 0.1 and minimum.y < -0.1 and maximum.y > 0.1, "Tremor alterna direção nos dois eixos; " + context)
					check.call(early_peak > 1 and late_peak < early_peak * 0.6, "Tremor perde força antes de terminar; " + context)
				check.call(stable, "Matriz, atores e controles não mudam de posição com o fundo; " + context)
				check.call(app.session.board.cells == cells and app.session.remaining == remaining and app.session.moves == 1, "Efeitos não alteram a tentativa; " + context)
				check.call(app.session.state == Session.State.WON and app.profile.level_record(1)["completions"] == wins + 1, "Conclusão registrada uma vez; " + context)
				app._process(1.0)
				check.call(app.profile.level_record(1)["completions"] == wins + 1 and app.background_shake_offset() == Vector2.ZERO and not app.shock_flash.visible, "Resultado não repete conclusão nem deixa impacto residual; " + context)
	# Um quadro demorado pode cruzar o instante da chave ou toda a resolução.
	for delta in [0.8, 3.0]:
		app.start_game(false)
		app._on_cell_pressed(1)
		app._process(delta)
		check.call(app.resolution_elapsed >= delta and app.session.state in [Session.State.RESOLVING, Session.State.WON], "Quadro demorado não trava a conclusão: %.1f s" % delta)
		app.start_game(false)
		check.call(app.background_shake_offset() == Vector2.ZERO and not app.shock_flash.visible and app.room_view.state == &"idle", "Reinício durante/depois do choque limpa o efeito: %.1f s" % delta)
	app.reduced_flashes = false
	app.profile.vibration_enabled = true
	app.sound_enabled = false
	app.start_game(false)
	app._on_cell_pressed(1)
	app._process(0.5)
	app.show_menu()
	check.call(app.background_shake_offset() == Vector2.ZERO and not app.shock_flash.visible, "Sair ao menu durante o choque limpa o impacto")
