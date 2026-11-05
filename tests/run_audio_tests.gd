extends SceneTree
## Integração e decodificação real do OGG, isoladas do progresso do jogador.

const PolishTests = preload("res://tests/polish_tests.gd")
var checks := 0
var failures := 0


func _initialize() -> void:
	if not "--test" in OS.get_cmdline_user_args():
		push_error("Executar com -- --test para proteger o perfil do jogador.")
		quit(1)
		return
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func _run() -> void:
	await _exercise_audio()
	print("Áudio: %d verificações; %d falhas." % [checks, failures])
	call_deferred("quit", 1 if failures > 0 else 0)


func _exercise_audio() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.set_process(false)
	app.ticks_msec = func(): return 1000
	PolishTests.new().run_ui(app, _check)
	app.show_menu()
	app.sound_enabled = true
	app.audio.update_context(false, 0)
	var player: AudioStreamPlayer = app.audio.music
	var stream := player.stream
	# Acelera apenas o teste: três ciclos de 64 s são decodificados em cerca de 24 s.
	player.pitch_scale = 8.0
	player.stop()
	player.play()
	var loops := 0
	var previous := 0.0
	var paused := false
	var deadline := Time.get_ticks_msec() + 35000
	while loops < 3 and Time.get_ticks_msec() < deadline:
		await create_timer(0.05).timeout
		var position := player.get_playback_position()
		if position < previous - 1.0:
			loops += 1
		if loops == 1 and not paused:
			app.audio.update_context(false, 0, -1, true)
			var pause_position := player.get_playback_position()
			await create_timer(0.3).timeout
			_check(absf(player.get_playback_position() - pause_position) < 0.15, "Pausa conserva a posição real do decoder")
			app.audio.update_context(false, 0)
			paused = true
		previous = player.get_playback_position()
	_check(loops == 3, "OGG atravessa três emendas sem encerrar a reprodução")
	_check(player.playing and player.stream == stream, "Após três ciclos o mesmo stream continua ativo")
	app.audio.set_enabled(false)
	await create_timer(0.1).timeout
	_check(not player.playing, "SOM desliga a reprodução após os ciclos completos")
	player.pitch_scale = 1.0
	var output := FileAccess.open("res://builds/audio-loop-results.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"loops": loops, "rate": 8, "stream_seconds": stream.get_length(), "checks": checks, "failures": failures}, "\t"))
	output.close()
	print("OGG: %d ciclos de %.2f segundos, decoder a 8×; pausa e silêncio verificados." % [loops, stream.get_length()])
	app.free()
	app = null
	await create_timer(0.15).timeout
