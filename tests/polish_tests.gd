extends RefCounted

const Session = preload("res://scripts/game_session.gd")


func run_ui(app, check: Callable) -> void:
	check.call(app.art_pack.room_background != null and app.art_pack.ui_background != null, "Pacote v2 fornece cenários substituíveis")
	for name in ["rotate", "ui", "denied", "hint", "zap", "win", "lose", "warning"]:
		var stream: AudioStreamWAV = app.audio.SOUNDS[name]
		check.call(stream != null and stream.mix_rate == 22050 and stream.get_length() > 0, "Efeito próprio disponível: " + name)
	check.call(app.audio.hum.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Ambiente usa loop próprio sem reiniciar a cada quadro")
	check.call(app.audio.music.stream is AudioStreamOggVorbis and app.audio.music.stream.loop and app.audio.music.stream.get_length() > 50, "Trilha original estéreo está disponível em loop")
	app.sound_enabled = true
	_test_volumes(app.audio, check)
	app.audio.update_context(true, 0.5, 10)
	var serial: int = app.audio.cue_serial
	check.call(app.audio.hum.playing and app.audio.last_cue == "warning", "Jogo ativo tem ambiente e aviso de tempo")
	check.call(app.audio.music.playing and app.audio.music != app.audio.effects[0] and app.audio.music != app.audio.hum, "Trilha toca em canal próprio sem substituir efeitos e ambiente")
	var music_volume: float = app.audio.music.volume_db
	var music_stream = app.audio.music.stream
	app.audio.update_context(true, 0.5, 10)
	check.call(app.audio.cue_serial == serial, "Aviso não repete no mesmo segundo")
	check.call(app.audio.music.stream == music_stream and app.audio.music.playing, "Atualizar contexto conserva a mesma trilha")
	app.audio.update_context(false, 0, -1, true)
	check.call(app.audio.music.stream_paused and not app.audio.hum.playing, "Pausa suspende música e ambiente")
	app.audio.update_context(false, 0, -1, false, true)
	check.call(not app.audio.music.stream_paused and app.audio.music.volume_db <= music_volume - 6, "Descarga reduz a música para destacar o zap")
	app.audio._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	app.audio.update_context(false, 0)
	check.call(app.audio.music.stream_paused, "Segundo plano silencia a trilha mesmo no menu")
	app.audio._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	app.audio.update_context(false, 0)
	check.call(app.audio.music.playing and not app.audio.music.stream_paused, "Retorno ao menu retoma a trilha")
	app.audio.play_cue("zap")
	check.call(app.audio.effects[1].playing, "Zap usa canal independente da interface")
	app.sound_enabled = false
	check.call(not app.audio.hum.playing and not app.audio.effects[0].playing and not app.audio.effects[1].playing, "Desligar som interrompe ambiente e efeitos imediatamente")
	check.call(not app.audio.music.playing, "SOM desligado interrompe também a trilha")
	serial = app.audio.cue_serial
	app.audio.play_cue("win")
	check.call(app.audio.cue_serial == serial, "Som desligado impede novos efeitos")
	app.level_index = 0
	app.start_game(false)
	var previous: Array = app.session.board.energized.keys()
	app._on_cell_pressed(1)
	check.call(app.session.state == Session.State.RESOLVING and not app.board_view.newly_energized.is_empty(), "Fechar circuito inicia faíscas nos novos fios")
	for index in app.board_view.newly_energized:
		check.call(app.session.board.energized.has(index) and not previous.has(index), "Faíscas aparecem somente em fios recém-energizados")
	var cells: Array = app.session.board.cells.duplicate(true)
	var moves: int = app.session.moves
	app.board_view._process(0.8)
	check.call(app.board_view.energy_time >= 0.65 and app.session.board.cells == cells and app.session.moves == moves, "Efeito termina sem alterar circuito ou giros")
	app.sound_enabled = true
	app._process(app.RESOLUTION_DURATION + 0.1)
	check.call(app.audio.last_cue == "win", "Vitória toca assinatura sonora")
	serial = app.audio.cue_serial
	app._sync_controls()
	app._sync_controls()
	check.call(app.audio.cue_serial == serial, "Resultado não repete áudio a cada quadro")
	app.level_index = 10
	app.start_game(false)
	app._on_cell_pressed(5)
	check.call(app.audio.hum.playing, "Corrente ativa retoma ambiente")
	app.pause_game()
	var pulse: float = app.pulse
	app._process(0.5)
	check.call(not app.audio.hum.playing and app.pulse == pulse, "Pausa suspende ambiente e animação de fundo")
	check.call(app.audio.music.stream_paused, "Botão de pausa do jogo suspende a música")
	app.resume_game()
	check.call(not app.audio.music.stream_paused, "Continuar retoma a música junto da partida")
	app.session.tick(app.session.time_limit + 1)
	app._sync_controls()
	check.call(app.audio.last_cue == "lose" and not app.audio.hum.playing, "Derrota tem áudio próprio e encerra ambiente")
	app.sound_enabled = false
	print("Acabamento: cenários, sons, pausa, silêncio e faíscas verificados.")


func _test_volumes(audio, check: Callable) -> void:
	var stream = audio.music.stream
	audio.set_volumes(0.5, 0.25)
	audio.update_context(true, 0.5)
	check.call(absf(audio.music.volume_db - (audio.MUSIC_VOLUME_DB - 6.0206)) < 0.01, "Metade do volume da música aplica ganho de amplitude correto")
	check.call(absf(audio.effects[0].volume_db - (-15.0 - 12.0412)) < 0.01, "Volume de efeitos é independente do volume de música")
	audio.set_volumes(0, 1)
	audio.update_context(true, 0.5)
	audio.play_cue("zap")
	check.call(audio.music.stream_paused and audio.effects[1].playing, "Música em zero não silencia os efeitos")
	audio.set_volumes(1, 0)
	audio.update_context(true, 0.5)
	var serial: int = audio.cue_serial
	audio.play_cue("rotate")
	check.call(not audio.music.stream_paused and audio.music.playing and not audio.hum.playing and audio.cue_serial == serial, "Efeitos em zero não silenciam a música nem deixam zumbido ativo")
	check.call(not audio.effects[0].playing and not audio.effects[1].playing, "Silenciar efeitos interrompe os canais em andamento")
	audio.set_volumes(1, 1)
	audio.update_context(true, 0.5)
	check.call(audio.music.stream == stream and not audio.music.stream_paused, "Restaurar volumes conserva o stream da trilha")
	audio.music.stop()
	audio.set_volumes(0, 1)
	audio.update_context(false, 0)
	check.call(not audio.music.playing, "Abrir com música em zero não inicia reprodução")
	audio.set_volumes(1, 1)
	audio.update_context(false, 0, -1, true)
	check.call(not audio.music.playing, "Religar música enquanto pausado aguarda a retomada")
	audio.update_context(false, 0)
	check.call(audio.music.playing and not audio.music.stream_paused, "Sair da pausa inicia a música habilitada")
