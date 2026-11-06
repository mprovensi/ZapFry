extends Node
## Música original, ambiente e efeitos em canais independentes.

const SOUNDS := {
	"rotate": preload("res://assets/audio/rotate.wav"),
	"ui": preload("res://assets/audio/ui.wav"),
	"denied": preload("res://assets/audio/denied.wav"),
	"hint": preload("res://assets/audio/hint.wav"),
	"zap": preload("res://assets/audio/zap.wav"),
	"win": preload("res://assets/audio/win.wav"),
	"lose": preload("res://assets/audio/lose.wav"),
	"warning": preload("res://assets/audio/warning.wav")}
const MUSIC_VOLUME_DB := -8.0
const MUSIC_RESOLVING_DB := -16.0
var enabled := true
var music_volume := 1.0
var effects_volume := 1.0
var cue_serial := 0
var last_cue := ""
var last_warning := -1
var effects: Array[AudioStreamPlayer] = []
var hum: AudioStreamPlayer
var music: AudioStreamPlayer
var _suspended := false


func _ready() -> void:
	for index in range(2):
		var player := AudioStreamPlayer.new()
		player.volume_db = -15
		add_child(player)
		effects.append(player)
	hum = AudioStreamPlayer.new()
	var loop: AudioStreamWAV = preload("res://assets/audio/hum.wav").duplicate()
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_begin = 0
	loop.loop_end = loop.data.size() / 2
	hum.stream = loop
	hum.volume_db = -30
	add_child(hum)
	music = AudioStreamPlayer.new()
	var soundtrack: AudioStreamOggVorbis = preload("res://assets/audio/fortress-after-hours.ogg").duplicate()
	soundtrack.loop = true
	music.stream = soundtrack
	music.volume_db = MUSIC_VOLUME_DB
	add_child(music)


func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		_stop()


func set_volumes(music_level: float, effects_level: float) -> void:
	music_volume = clampf(music_level if is_finite(music_level) else 1.0, 0, 1)
	effects_volume = clampf(effects_level if is_finite(effects_level) else 1.0, 0, 1)
	for player in effects:
		player.volume_db = -15.0 + _gain_db(effects_volume)
		if effects_volume == 0:
			player.stop()
	if effects_volume == 0 and hum != null:
		hum.stop()


func _gain_db(value: float) -> float:
	return linear_to_db(value) if value > 0 else -80.0


func play_cue(cue: String) -> void:
	if not enabled or effects_volume == 0 or _suspended or not SOUNDS.has(cue) or effects.is_empty():
		return
	var player := effects[1 if cue in ["hint", "zap", "win", "lose"] else 0]
	player.stream = SOUNDS[cue]
	player.play()
	last_cue = cue
	cue_serial += 1


func update_context(active: bool, charge: float, seconds: int = -1, paused: bool = false, resolving: bool = false) -> void:
	if music != null:
		if not enabled:
			music.stop()
		else:
			var should_pause := paused or _suspended or music_volume == 0
			music.stream_paused = should_pause
			music.volume_db = (MUSIC_RESOLVING_DB if resolving else MUSIC_VOLUME_DB) + _gain_db(music_volume)
			# Sem playback, stream_paused retorna false mesmo após atribuir true.
			if not music.playing and not should_pause:
				music.play()
	if hum == null:
		return
	if not enabled or effects_volume == 0 or not active or paused or _suspended:
		hum.stop()
		last_warning = -1
		return
	hum.volume_db = lerpf(-32.0, -23.0, clampf(charge, 0, 1)) + _gain_db(effects_volume)
	hum.pitch_scale = lerpf(0.95, 1.10, clampf(charge, 0, 1))
	if not hum.playing:
		hum.play()
	if seconds in [10, 5, 4, 3, 2, 1] and seconds != last_warning:
		play_cue("warning")
	last_warning = seconds


func _stop() -> void:
	for player in effects:
		player.stop()
	if hum != null:
		hum.stop()
	if music != null:
		music.stop()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		_suspended = true
		for player in effects:
			player.stop()
		if hum != null:
			hum.stop()
		if music != null:
			music.stream_paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		_suspended = false


func _exit_tree() -> void:
	_stop()
