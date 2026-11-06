extends Control
## Coordenação da interface. A arte é substituível e separada das regras.

const Session = preload("res://scripts/game_session.gd")
const BoardView = preload("res://scripts/board_view.gd")
const Profile = preload("res://scripts/player_profile.gd")
const LevelCard = preload("res://scripts/level_card.gd")
const ArtPack = preload("res://scripts/art_pack.gd")
const RoomView = preload("res://scripts/room_view.gd")
const PowerCableView = preload("res://scripts/power_cable_view.gd")
const ExecutionCharacter = preload("res://scripts/execution_character.gd")
const GameAudio = preload("res://scripts/game_audio.gd")
const CharacterRoster = preload("res://scripts/character_roster.gd")
const DialogueView = preload("res://scripts/dialogue_view.gd")
const Stories = preload("res://scripts/encounter_stories.gd")
const Portrait = preload("res://scripts/character_portrait.gd")
@export var art_pack: ArtPack = preload("res://assets/art/concept_v3.tres"):
	set(value):
		art_pack = value
		if is_instance_valid(board_view):
			board_view.art_pack = value
			board_view.queue_redraw()
		if is_instance_valid(room_view):
			room_view.art_pack = value
			room_view.queue_redraw()
		if is_instance_valid(operator_view):
			operator_view.art_pack = value
			operator_view.queue_redraw()
		_apply_art_icons()
@export var execution_character: ExecutionCharacter = preload("res://assets/characters/knight.tres"):
	set(value):
		execution_character = value
		if is_instance_valid(room_view):
			room_view.execution_character = value
			room_view.queue_redraw()
const LEVEL_PATHS := ["res://levels/level_01.json", "res://levels/level_02.json",
	"res://levels/level_03.json", "res://levels/level_04.json", "res://levels/level_05.json",
	"res://levels/level_06.json", "res://levels/level_07.json", "res://levels/level_08.json",
	"res://levels/level_09.json", "res://levels/level_10.json", "res://levels/level_11.json",
	"res://levels/level_12.json", "res://levels/level_13.json", "res://levels/level_14.json",
	"res://levels/level_15.json", "res://levels/level_16.json",
	"res://levels/level_17.json", "res://levels/level_18.json", "res://levels/level_19.json",
	"res://levels/level_20.json", "res://levels/level_21.json", "res://levels/level_22.json",
	"res://levels/level_23.json", "res://levels/level_24.json"]
const DESIGN := Vector2(720, 1280)
const GAME_DESIGN := Vector2(720, 1600)
const SWITCH_PULL_TIME := 0.4
const ZAP_END_TIME := 1.75
const RESOLUTION_DURATION := 2.4
const INK := Color("09141e")
const PANEL := Color("172a37")
const EDGE := Color("34505f")
const CREAM := Color("f1eee1")
const MUTED := Color("94adb8")
const ROOM_SHADE := Color(0.015, 0.03, 0.045, 0.38)
const YELLOW := Color("ffce49")
const MINT := Color("6ce1c4")
const CORAL := Color("fa8e74")

var session := Session.new()
var level_data: Dictionary
var levels: Array[Dictionary] = []
var level_index := 0
var profile := Profile.new()
var character_roster := CharacterRoster.new()
var unlocked_level: int:
	get:
		return profile.unlocked_level
	set(value):
		profile.unlocked_level = value
var sector_index := 0
var level_cards: Array[Button] = []
var screen := "menu"
var stage: Control
var board_view: Control
var phase_label: Label
var feedback_label: Label
var room_view: Control
var operator_view: Control
var cable_view: Node2D
var shock_flash: ColorRect
var overlay: Control
var settings: Control
var dialogue: Control
var result_portrait: TextureRect
var campaign_ending: Control
var ending_title: Label
var ending_message: Label
var music_slider: HSlider
var effects_slider: HSlider
var buttons: Dictionary = {}
var reduced_flashes: bool:
	get:
		return profile.reduced_flashes
	set(value):
		profile.reduced_flashes = value
var sound_enabled: bool:
	get:
		return profile.sound_enabled
	set(value):
		profile.sound_enabled = value
		if is_instance_valid(audio):
			audio.set_enabled(value)
var best_score: int:
	get:
		return profile.best_score
	set(value):
		profile.best_score = value
var feedback := "Toque nos fios para girar 90°."
var resolution_elapsed := 0.0
var last_tick_msec := 0
var ticks_msec: Callable = Time.get_ticks_msec
var pulse := 0.0
var audio: Node
var _audio_state := -1
var _applied_art_pack: Resource
var _styles: Array[StyleBoxFlat] = []
var persistence_enabled := true


func _ready() -> void:
	get_tree().quit_on_go_back = false
	persistence_enabled = not "--test" in OS.get_cmdline_user_args()
	for path in LEVEL_PATHS:
		levels.append(JSON.parse_string(FileAccess.get_file_as_string(path)))
	_load_preferences()
	stage = Control.new()
	stage.name = "Stage"
	stage.size = DESIGN
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage)
	phase_label = Label.new()
	phase_label.name = "CurrentPhase"
	phase_label.position = Vector2(28, 12)
	phase_label.size = Vector2(232, 48)
	phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	phase_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	phase_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	phase_label.add_theme_font_size_override("font_size", 30)
	phase_label.add_theme_color_override("font_color", YELLOW)
	phase_label.add_theme_color_override("font_outline_color", INK)
	phase_label.add_theme_constant_override("outline_size", 4)
	stage.add_child(phase_label)
	feedback_label = Label.new()
	feedback_label.name = "GameFeedback"
	feedback_label.position = Vector2(40, 1378)
	feedback_label.size = Vector2(640, 80)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 28)
	feedback_label.max_lines_visible = 2
	feedback_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	feedback_label.add_theme_color_override("font_color", CREAM)
	feedback_label.add_theme_color_override("font_outline_color", INK)
	feedback_label.add_theme_constant_override("outline_size", 4)
	feedback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(feedback_label)
	cable_view = PowerCableView.new()
	cable_view.name = "PowerCables"
	stage.add_child(cable_view)
	room_view = RoomView.new()
	room_view.name = "Room"
	room_view.art_pack = art_pack
	room_view.execution_character = execution_character
	stage.add_child(room_view)
	operator_view = RoomView.new()
	operator_view.name = "GoblinOperator"
	operator_view.is_operator = true
	operator_view.embedded = true
	operator_view.art_pack = art_pack
	operator_view.position = Vector2(64, 114)
	operator_view.size = Vector2(336, 290)
	stage.add_child(operator_view)
	board_view = BoardView.new()
	board_view.name = "Board"
	board_view.art_pack = art_pack
	board_view.position = Vector2(48, 408)
	board_view.size = Vector2(624, 624)
	board_view.cell_pressed.connect(_on_cell_pressed)
	stage.add_child(board_view)
	cable_view.generator = operator_view
	cable_view.subject = room_view
	cable_view.board = board_view
	# Acima da matriz e dos atores; a área útil deixa cabeçalho e rodapé intactos.
	shock_flash = ColorRect.new()
	shock_flash.name = "ShockFlash"
	shock_flash.position = Vector2(0, 122)
	shock_flash.size = Vector2(720, 1252)
	shock_flash.color = Color(0.58, 0.84, 1.0, 0.0)
	shock_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shock_flash.visible = false
	stage.add_child(shock_flash)
	_make_button("start", "JOGAR", Rect2(112, 924, 496, 104), continue_campaign, true)
	_make_button("levels", "FASES", Rect2(112, 1052, 496, 96), show_levels)
	_make_button("settings", "AJUSTES", Rect2(112, 1200, 496, 96), show_settings)
	for key in ["start", "levels", "settings"]:
		buttons[key].add_theme_font_size_override("font_size", 28)
	_make_button("back", "MENU", Rect2(578, 52, 110, 52), show_menu)
	_make_button("restart", "↻ REINICIAR", Rect2(40, 1474, 308, 96), start_game.bind(false))
	_make_button("hint", "DICA GRÁTIS", Rect2(372, 1474, 308, 96), use_free_hint, true)
	_make_button("pause", "Ⅱ", Rect2(600, 14, 96, 96), pause_game)
	buttons["pause"].tooltip_text = "Pausar jogo"
	for key in ["restart", "hint", "back"]:
		buttons[key].add_theme_font_size_override("font_size", 26)
	for key in ["restart", "hint"]:
		buttons[key].add_theme_font_size_override("font_size", 28)
	buttons["pause"].add_theme_font_size_override("font_size", 38)
	for sector in range(3):
		_make_button("sector_%d" % sector, "%d × %d" % [sector + 4, sector + 4], Rect2(32 + sector * 224, 176, 208, 56), _open_sector.bind(sector))
	for slot in range(8):
		var card := LevelCard.new()
		card.name = "LevelCard%d" % slot
		card.position = Vector2(32 + (slot % 2) * 344, 270 + (slot / 2) * 184)
		card.size = Vector2(312, 168)
		card.pressed.connect(_on_card_pressed.bind(slot))
		stage.add_child(card)
		level_cards.append(card)
	_make_button("selector_continue", "CONTINUAR", Rect2(52, 1106, 296, 96), continue_campaign, true)
	_make_button("start_over", "COMEÇAR DE NOVO", Rect2(372, 1106, 296, 96), restart_campaign)
	buttons["start_over"].add_theme_font_size_override("font_size", 22)
	buttons["start_over"].tooltip_text = "Voltar à fase 1 e ao menu, mantendo recordes e desbloqueios"
	dialogue = DialogueView.new()
	stage.add_child(dialogue)
	dialogue.finished.connect(_on_intro_finished)
	dialogue.advanced.connect(func():
		_cue("ui")
		_update_room())
	_style_button(dialogue.advance_button, true)
	_style_button(dialogue.skip_button, false)
	dialogue.advance_button.add_theme_font_size_override("font_size", 28)
	dialogue.skip_button.add_theme_font_size_override("font_size", 24)
	overlay = Control.new()
	overlay.name = "Overlay"
	overlay.size = GAME_DESIGN
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.draw.connect(_draw_overlay)
	stage.add_child(overlay)
	result_portrait = Portrait.new()
	result_portrait.position = Vector2(150, 352)
	result_portrait.size = Vector2(420, 420)
	overlay.add_child(result_portrait)
	_make_campaign_ending()
	_make_button("continue", "CONTINUAR", Rect2(112, 1098, 496, 104), _overlay_primary, true, overlay)
	_make_button("exit", "MENU", Rect2(112, 1226, 496, 96), show_menu, false, overlay)
	_make_button("pause_settings", "AJUSTES", Rect2(112, 1354, 496, 96), show_settings, false, overlay)
	buttons["continue"].add_theme_font_size_override("font_size", 28)
	buttons["exit"].add_theme_font_size_override("font_size", 26)
	buttons["pause_settings"].add_theme_font_size_override("font_size", 26)
	_make_settings()
	audio = GameAudio.new()
	audio.name = "GameAudio"
	add_child(audio)
	audio.set_enabled(sound_enabled)
	audio.set_volumes(profile.music_volume, profile.effects_volume)
	resized.connect(_layout_stage)
	_layout_stage()
	show_menu()
	set_process(true)


func _make_campaign_ending() -> void:
	campaign_ending = Control.new()
	campaign_ending.name = "CampaignEnding"
	campaign_ending.size = GAME_DESIGN
	campaign_ending.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(campaign_ending)
	ending_title = Label.new()
	ending_title.name = "EndingThanks"
	ending_title.position = Vector2(48, 260)
	ending_title.size = Vector2(624, 64)
	ending_title.text = "OBRIGADO POR JOGAR!"
	ending_title.add_theme_font_size_override("font_size", 44)
	ending_message = Label.new()
	ending_message.name = "MoreLevels"
	ending_message.position = Vector2(64, 982)
	ending_message.size = Vector2(592, 92)
	ending_message.text = "Mais fases virão pela frente.\nAté a próxima descarga!"
	ending_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ending_message.add_theme_font_size_override("font_size", 28)
	for label in [ending_title, ending_message]:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", CREAM)
		campaign_ending.add_child(label)


func _layout_stage() -> void:
	if stage == null:
		return
	var design := DESIGN if screen == "levels" else GAME_DESIGN
	stage.size = design
	var ratio := minf(size.x / design.x, size.y / design.y)
	stage.scale = Vector2.ONE * ratio
	stage.position = (size - design * ratio) * 0.5
	queue_redraw()


func _process(delta: float) -> void:
	dialogue.advance_presentation(delta)
	if screen != "game" or session.state != Session.State.PAUSED:
		pulse += delta
	if screen == "game":
		_advance_clock()
		if session.state == Session.State.RESOLVING:
			var previous_resolution := resolution_elapsed
			resolution_elapsed += delta
			if previous_resolution < SWITCH_PULL_TIME and resolution_elapsed >= SWITCH_PULL_TIME:
				_cue("zap")
				if profile.vibration_enabled:
					Input.vibrate_handheld(800)
			if resolution_elapsed >= RESOLUTION_DURATION:
				session.finish_resolution()
				profile.record_win(level_index + 1, session.score(), session.stars(), session.elapsed, int(level_data.get("rules_revision", 1)))
				_save_preferences()
		_sync_controls()
	_update_room()
	queue_redraw()
	if is_instance_valid(overlay) and overlay.visible:
		overlay.queue_redraw()


func _advance_clock() -> void:
	var now: int = ticks_msec.call()
	if last_tick_msec > 0:
		session.tick(float(now - last_tick_msec) / 1000.0)
	last_tick_msec = now


func start_game(show_intro: bool = true) -> void:
	settings.hide()
	var selected := character_roster.select(level_index, profile.appearance)
	execution_character = selected["character"]
	profile.appearance = selected["snapshot"]
	if not show_intro:
		profile.appearance["intro_seen"] = true
	level_data = levels[level_index]
	profile.current_level = level_index
	_save_preferences()
	session.start(level_data)
	screen = "game"
	resolution_elapsed = 0.0
	last_tick_msec = ticks_msec.call()
	feedback = str(level_data["instruction"])
	board_view.model = session.board
	board_view.hovered = -1
	board_view.activated = -1
	board_view.hint_index = -1
	board_view.newly_energized.clear()
	board_view.energy_time = 1.0
	_update_guidance()
	board_view.queue_redraw()
	if show_intro and not profile.appearance["intro_seen"]:
		dialogue.begin(Stories.CASES[profile.appearance["story"]], execution_character.display_name, execution_character.dialogue_color)
	else:
		dialogue.close()
	_sync_controls()
	queue_redraw()


func continue_campaign() -> void:
	level_index = profile.current_level
	start_game()


func _on_intro_finished() -> void:
	profile.appearance["intro_seen"] = true
	_save_preferences()
	last_tick_msec = ticks_msec.call()
	_sync_controls()


func restart_campaign() -> void:
	level_index = 0
	profile.current_level = 0
	_save_preferences()
	show_menu()


func _update_guidance() -> void:
	board_view.guide_index = -1
	if not bool(level_data.get("guided", false)) or session.board.solved:
		return
	for index_value in level_data["reference_path"]:
		var index := int(index_value)
		var cell: Dictionary = session.board.cells[index]
		var goal := CircuitBoard.rotate_mask(int(CircuitBoard.BASE_MASKS[cell["kind"]]), int(cell["solution"]))
		if session.board.can_rotate(index) and session.board.mask_at(index) != goal:
			board_view.guide_index = index
			return


func show_menu() -> void:
	if settings.visible:
		_save_preferences()
		settings.hide()
	screen = "menu"
	session.pause()
	_sync_controls()
	queue_redraw()


func show_levels() -> void:
	session.pause()
	screen = "levels"
	sector_index = clampi(unlocked_level / 8, 0, 2)
	_refresh_level_cards()
	_sync_controls()
	queue_redraw()


func _make_settings() -> void:
	settings = Control.new()
	settings.name = "Settings"
	settings.size = GAME_DESIGN
	settings.mouse_filter = Control.MOUSE_FILTER_STOP
	settings.visible = false
	settings.draw.connect(_draw_settings)
	stage.add_child(settings)
	_make_button("sound", "SOM GERAL: LIGADO", Rect2(112, 350, 496, 96), _toggle_sound, false, settings)
	music_slider = _make_volume_slider("MusicVolume", 512, _set_music_volume)
	effects_slider = _make_volume_slider("EffectsVolume", 674, _set_effects_volume)
	_make_button("vibration", "VIBRAÇÃO: LIGADA", Rect2(112, 836, 496, 96), _toggle_vibration, false, settings)
	_make_button("flashes", "FLASHES: NORMAIS", Rect2(112, 956, 496, 96), _toggle_flashes, false, settings)
	_make_button("settings_back", "VOLTAR", Rect2(112, 1160, 496, 104), close_settings, true, settings)
	for key in ["sound", "vibration", "flashes", "settings_back"]:
		buttons[key].add_theme_font_size_override("font_size", 26)


func _make_volume_slider(node_name: String, top: float, changed: Callable) -> HSlider:
	var slider := HSlider.new()
	slider.name = node_name
	slider.position = Vector2(112, top)
	slider.size = Vector2(496, 96)
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = 100
	slider.tooltip_text = "Volume da música" if node_name == "MusicVolume" else "Volume dos efeitos"
	var track := StyleBoxFlat.new()
	track.bg_color = EDGE
	track.set_corner_radius_all(5)
	track.content_margin_top = 5
	track.content_margin_bottom = 5
	slider.add_theme_stylebox_override("slider", track)
	var fill := track.duplicate() as StyleBoxFlat
	fill.bg_color = MINT
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0, 0.8, 0.9, 1])
	gradient.colors = PackedColorArray([YELLOW, YELLOW, INK, Color.TRANSPARENT])
	var handle := GradientTexture2D.new()
	handle.gradient = gradient
	handle.width = 48
	handle.height = 48
	handle.fill = GradientTexture2D.FILL_RADIAL
	handle.fill_from = Vector2(0.5, 0.5)
	handle.fill_to = Vector2(1, 0.5)
	for state in ["grabber", "grabber_highlight", "grabber_disabled"]:
		slider.add_theme_icon_override(state, handle)
	settings.add_child(slider)
	slider.value_changed.connect(changed)
	slider.drag_ended.connect(func(was_changed: bool):
		if was_changed:
			_save_preferences())
	slider.focus_exited.connect(_save_preferences)
	return slider


func show_settings() -> void:
	if screen != "menu" and not (screen == "game" and session.state == Session.State.PAUSED):
		return
	settings.show()
	_sync_controls()
	buttons["sound"].grab_focus()


func close_settings() -> void:
	_save_preferences()
	settings.hide()
	_sync_controls()
	buttons["pause_settings" if screen == "game" else "settings"].grab_focus()


func _set_music_volume(value: float) -> void:
	profile.music_volume = value / 100.0
	_sync_controls()


func _set_effects_volume(value: float) -> void:
	profile.effects_volume = value / 100.0
	_sync_controls()


func _toggle_vibration() -> void:
	profile.vibration_enabled = not profile.vibration_enabled
	_save_preferences()
	_sync_controls()


func _open_sector(index: int) -> void:
	if screen != "levels" or index < 0 or index > 2:
		return
	sector_index = index
	_refresh_level_cards()
	queue_redraw()


func _refresh_level_cards() -> void:
	for slot in range(level_cards.size()):
		var index := sector_index * 8 + slot
		level_cards[slot].configure(levels[index], profile.level_record(index + 1), index <= unlocked_level)


func _on_card_pressed(slot: int) -> void:
	if screen == "levels" and slot >= 0 and slot < 8:
		play_selected_level(sector_index * 8 + slot)


func play_selected_level(index: int) -> bool:
	if screen != "levels" or index < 0 or index >= levels.size() or index > unlocked_level:
		return false
	level_index = index
	start_game()
	return true


func use_free_hint() -> void:
	if screen != "game" or dialogue.active:
		return
	_advance_clock()
	var previous_energy: Array = session.board.energized.keys()
	var index := session.use_hint()
	if index < 0:
		_sync_controls()
		return
	feedback = "Dica: linha %d, coluna %d. Fio marcado em verde e preso." % [index / session.board.width + 1, index % session.board.width + 1]
	board_view.hint_index = index
	board_view.activated = index
	board_view.activation_time = 0.3
	board_view.animate_energy(previous_energy)
	_cue("hint")
	if session.state == Session.State.RESOLVING:
		feedback = "CIRCUITO FECHADO. Segure o penteado!"
		resolution_elapsed = 0.0
	_update_guidance()
	board_view.queue_redraw()
	_sync_controls()


func _on_cell_pressed(index: int) -> void:
	if screen != "game" or dialogue.active:
		return
	_advance_clock()
	if session.state not in [Session.State.READY, Session.State.PLAYING]:
		return
	var previous_energy: Array = session.board.energized.keys()
	if not session.rotate_cell(index):
		_cue("denied")
		feedback = "Gire o fio com a seta; os outros já estão prontos." if bool(level_data.get("guided", false)) else "Os espaços vazios não precisam de fios."
		if index >= 0 and index < session.board.cells.size():
			var cell: Dictionary = session.board.cells[index]
			if cell["kind"] == "blocker":
				feedback = "Fusível queimado: a energia precisa contorná-lo."
			elif bool(cell.get("fixed", false)) and not bool(level_data.get("guided", false)):
				feedback = "Este fio está preso. Gire as outras peças."
	else:
		feedback = str(level_data["instruction"])
		if session.board.target_connected() and not session.board.solved and not session.board.required_nodes.is_empty():
			feedback = "OUT conectado. Falta acender a lâmpada marcada."
		board_view.animate_energy(previous_energy)
		_cue("rotate")
		if session.state == Session.State.RESOLVING:
			feedback = "CIRCUITO FECHADO. Segure o penteado!"
			resolution_elapsed = 0.0
	_update_guidance()
	board_view.queue_redraw()
	_sync_controls()


func pause_game() -> void:
	_advance_clock()
	session.pause()
	_sync_controls()


func resume_game() -> void:
	session.resume()
	last_tick_msec = ticks_msec.call()
	_sync_controls()


func _overlay_primary() -> void:
	if session.state == Session.State.PAUSED:
		resume_game()
	elif session.state == Session.State.WON:
		level_index = level_index + 1 if level_index < levels.size() - 1 else 0
		start_game()
	else:
		start_game(false)


func _is_final_result() -> bool:
	return screen == "game" and session.state == Session.State.WON and level_index == levels.size() - 1


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if is_instance_valid(settings) and settings.visible:
			_save_preferences()
		if is_instance_valid(stage) and screen == "game":
			pause_game()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_back()


func _handle_back() -> void:
	if settings.visible:
		close_settings()
	elif screen == "menu":
		get_tree().quit()
	elif screen == "levels":
		show_menu()
	elif session.state == Session.State.PAUSED:
		resume_game()
	elif session.state in [Session.State.WON, Session.State.LOST]:
		show_menu()
	else:
		pause_game()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and (settings.visible or screen in ["game", "levels"]):
			_handle_back()
			get_viewport().set_input_as_handled()


func _sync_controls() -> void:
	if not is_instance_valid(overlay):
		return
	if stage.size != (DESIGN if screen == "levels" else GAME_DESIGN):
		_layout_stage()
	_apply_art_icons()
	_sync_audio()
	var in_game := screen == "game"
	var introducing: bool = in_game and dialogue.active
	dialogue.visible = introducing and session.state != Session.State.PAUSED and not settings.visible
	var flash := shock_flash_alpha()
	shock_flash.color = Color(0.58, 0.84, 1.0, flash)
	shock_flash.visible = in_game and flash > 0.0
	_update_room()
	phase_label.visible = in_game
	feedback_label.visible = in_game and not introducing
	feedback_label.text = feedback
	phase_label.text = "FASE %02d / %02d" % [level_index + 1, levels.size()]
	for key in ["start", "settings", "levels"]:
		buttons[key].visible = screen == "menu" and not settings.visible
	buttons["start"].text = "JOGAR" if profile.current_level == 0 else "CONTINUAR · FASE %d" % (profile.current_level + 1)
	if profile.completed_count() >= levels.size() and profile.current_level == 0:
		buttons["start"].text = "JOGAR NOVAMENTE"
	for key in ["restart", "pause", "hint"]:
		buttons[key].visible = in_game and not settings.visible and (key == "pause" or not introducing)
	buttons["back"].visible = screen == "levels"
	for sector in range(3):
		buttons["sector_%d" % sector].visible = screen == "levels"
	for card in level_cards:
		card.visible = screen == "levels"
	buttons["selector_continue"].visible = screen == "levels"
	buttons["start_over"].visible = screen == "levels"
	board_view.visible = in_game
	board_view.interactive = in_game and not introducing and session.state in [Session.State.READY, Session.State.PLAYING]
	overlay.visible = in_game and not settings.visible and session.state in [Session.State.PAUSED, Session.State.WON, Session.State.LOST]
	campaign_ending.visible = overlay.visible and _is_final_result()
	buttons["continue"].text = "CONTINUAR" if session.state == Session.State.PAUSED else "REPETIR FASE"
	if session.state == Session.State.WON:
		buttons["continue"].text = "PRÓXIMA FASE" if level_index < levels.size() - 1 else "JOGAR DO INÍCIO"
	buttons["pause_settings"].visible = session.state == Session.State.PAUSED
	buttons["sound"].text = "SOM GERAL: LIGADO" if sound_enabled else "SOM GERAL: DESLIGADO"
	buttons["vibration"].text = "VIBRAÇÃO: LIGADA" if profile.vibration_enabled else "VIBRAÇÃO: DESLIGADA"
	buttons["flashes"].text = "FLASHES: SUAVES" if reduced_flashes else "FLASHES: NORMAIS"
	music_slider.set_value_no_signal(profile.music_volume * 100)
	effects_slider.set_value_no_signal(profile.effects_volume * 100)
	music_slider.editable = sound_enabled
	effects_slider.editable = sound_enabled
	if settings.visible:
		settings.queue_redraw()
	buttons["pause"].disabled = session.state not in [Session.State.READY, Session.State.PLAYING]
	buttons["restart"].disabled = session.state == Session.State.RESOLVING
	buttons["hint"].disabled = not in_game or session.hint_candidate() < 0
	buttons["hint"].text = "DICA USADA" if session.hints_used > 0 else "DICA GRÁTIS"


func _apply_art_icons() -> void:
	if not is_instance_valid(stage) or not buttons.has("restart"):
		return
	if is_same(_applied_art_pack, art_pack):
		return
	_applied_art_pack = art_pack
	for key in buttons:
		_style_button(buttons[key], bool(buttons[key].get_meta("primary", false)))
	if is_instance_valid(dialogue):
		_style_button(dialogue.advance_button, true)
		_style_button(dialogue.skip_button, false)
	var icon: Texture2D = art_pack.restart_icon if art_pack != null else null
	buttons["restart"].icon = icon
	buttons["restart"].expand_icon = true
	buttons["restart"].add_theme_constant_override("icon_max_width", 24)
	buttons["restart"].text = "REINICIAR" if icon != null else "↻ REINICIAR"


func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	_save_preferences()
	_sync_controls()


func _toggle_flashes() -> void:
	reduced_flashes = not reduced_flashes
	_save_preferences()
	_sync_controls()


func _make_button(key: String, caption: String, rect: Rect2, action: Callable,
		primary: bool = false, parent: Control = null) -> void:
	var button := Button.new()
	button.name = key.capitalize()
	button.text = caption
	button.position = rect.position
	button.size = rect.size
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 22 if primary else 18)
	button.set_meta("primary", primary)
	_style_button(button, primary)
	button.pressed.connect(func():
		_cue("ui")
		action.call())
	(parent if parent != null else stage).add_child(button)
	buttons[key] = button


func _style_button(button: Button, primary: bool) -> void:
	for variant in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(16)
		style.set_border_width_all(2)
		style.border_color = Color("b18c2b") if primary else EDGE
		style.bg_color = YELLOW if primary else PANEL
		if variant == "hover" or variant == "focus":
			style.bg_color = Color("ffdf7b") if primary else Color("2e4758")
		if variant == "pressed":
			style.bg_color = Color("d8a738") if primary else Color("102331")
		if variant == "disabled":
			style.bg_color = Color("172632")
			style.border_color = Color("243b49")
		style.shadow_color = INK
		style.shadow_size = 1
		style.shadow_offset = Vector2(0, 5)
		button.add_theme_stylebox_override(variant, style)
		if primary and art_pack != null and art_pack.primary_button != null:
			var painted := StyleBoxTexture.new()
			painted.texture = art_pack.primary_button
			painted.content_margin_left = 12
			painted.content_margin_right = 12
			painted.content_margin_top = 8
			painted.content_margin_bottom = 8
			painted.texture_margin_left = art_pack.primary_button.get_width() * 0.09
			painted.texture_margin_right = painted.texture_margin_left
			painted.texture_margin_top = art_pack.primary_button.get_height() * 0.24
			painted.texture_margin_bottom = painted.texture_margin_top
			painted.modulate_color = Color(0.78, 0.78, 0.78) if variant == "pressed" else Color(0.5, 0.5, 0.5, 0.6) if variant == "disabled" else Color(1.13, 1.13, 1.13) if variant in ["hover", "focus"] else Color.WHITE
			button.add_theme_stylebox_override(variant, painted)
	for variant in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(variant, INK if primary and (art_pack == null or art_pack.primary_button == null) else CREAM)
	button.add_theme_color_override("font_disabled_color", Color("5e7887"))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), INK)
	if not is_instance_valid(stage):
		return
	_styles.clear()
	if art_pack != null and art_pack.ui_background != null and (screen == "levels" or art_pack.game_background == null):
		draw_texture_rect(art_pack.ui_background, Rect2(Vector2.ZERO, size), false)
	draw_set_transform(stage.position, 0.0, stage.scale)
	if art_pack == null or art_pack.ui_background == null:
		for x in range(-1280, 720, 60):
			draw_line(Vector2(x, 0), Vector2(x + 1280, 1280), Color("101f2b"), 1, true)
	if screen == "menu":
		if art_pack != null and art_pack.game_background != null:
			draw_texture_rect(art_pack.game_background, Rect2(Vector2.ZERO, GAME_DESIGN), false)
		_draw_floor_strip(self, 768, 80)
		_draw_menu()
	elif screen == "levels":
		_draw_selector()
	else:
		if art_pack != null and art_pack.game_background != null:
			# Mesmo enquadramento do cabeçalho. A base cobre as bordas quando
			# o cenário se desloca durante o choque, sem ampliar a textura.
			var background := Rect2(Vector2.ZERO, GAME_DESIGN)
			draw_texture_rect(art_pack.game_background, background, false)
			var offset := background_shake_offset()
			if offset != Vector2.ZERO:
				background.position += offset
				draw_texture_rect(art_pack.game_background, background, false)
		_draw_floor_strip(self, 344, 64)
		_draw_floor_strip(self, 1298, 76)
		_draw_game()
	draw_set_transform(Vector2.ZERO)


func _draw_floor_strip(canvas: CanvasItem, top: float, height: float) -> void:
	if art_pack != null and art_pack.room_floor != null:
		canvas.draw_texture_rect(art_pack.room_floor, Rect2(0, top, GAME_DESIGN.x, height), false)


func _shock_time() -> float:
	if screen != "game" or session.state != Session.State.RESOLVING:
		return -1.0
	if resolution_elapsed < SWITCH_PULL_TIME or resolution_elapsed >= ZAP_END_TIME:
		return -1.0
	return resolution_elapsed - SWITCH_PULL_TIME


func background_shake_offset() -> Vector2:
	var time := _shock_time()
	if time < 0 or reduced_flashes:
		return Vector2.ZERO
	var envelope := 1.0 - time / (ZAP_END_TIME - SWITCH_PULL_TIME)
	return Vector2(sin(time * 79.0) * 5.0, cos(time * 97.0) * 3.0) * envelope


func shock_flash_alpha() -> float:
	var time := _shock_time()
	if time < 0:
		return 0.0
	if reduced_flashes:
		return sin(PI * time / (ZAP_END_TIME - SWITCH_PULL_TIME)) * 0.07
	var pulse_strength := 0.0
	for center in [0.08, 0.58, 1.08]:
		var pulse_value := maxf(0, 1.0 - absf(time - float(center)) / 0.13)
		pulse_strength = maxf(pulse_strength, pulse_value * pulse_value)
	return pulse_strength * 0.18


func _draw_menu() -> void:
	draw_rect(Rect2(Vector2.ZERO, GAME_DESIGN), Color(0.015, 0.03, 0.045, 0.2))
	_center("ZAP & FRY", 326, 86, YELLOW)
	_center("UM PUZZLE DE ALTA TENSÃO", 372, 22, CREAM)
	_center("Gire os fios. Feche o circuito.", 876, 26, CREAM)


func _draw_selector() -> void:
	_text("PROGRESSO DA FORTALEZA", Vector2(32, 34), 14, MUTED)
	_text("ESCOLHA SUA FASE", Vector2(30, 110), 44, YELLOW)
	_text("%d / %d concluídas   ·   %d / %d estrelas" % [profile.completed_count(), levels.size(), profile.total_stars(), levels.size() * 3], Vector2(32, 148), 20, MUTED)
	draw_line(Vector2(52 + sector_index * 224, 242), Vector2(220 + sector_index * 224, 242), YELLOW, 4, true)
	var note := "Toque em uma fase disponível para jogar ou repetir."
	if profile.has_legacy_records():
		note = "Progresso antigo preservado. Rejogue para registrar estrelas."
	_text(note, Vector2(32, 261), 16, MUTED)
	_center("Verde: concluída   ·   Amarelo: disponível", 1038, 19, MUTED)
	_center("Uma dica grátis por tentativa corrige e prende um fio.", 1074, 19, CREAM)
	_center("Seus desbloqueios e recordes ficam salvos.", 1236, 17, MUTED)


func _draw_game() -> void:
	_draw_game_chrome(Rect2(0, 0, 720, 122))
	_draw_game_chrome(Rect2(0, 1374, 720, 226))
	if session.board.required_nodes.is_empty():
		_hud_text("PAINEL %d × %d" % [session.board.width, session.board.width], Vector2(28, 94), 20, MUTED)
	else:
		_hud_text("LÂMPADA %d/%d" % [session.board.lit_required_count(), session.board.required_nodes.size()], Vector2(28, 94), 20, YELLOW)
	_hud_text("TEMPO" if session.has_time_limit() else "SEM TEMPO", Vector2(294, 30), 18, MUTED)
	var seconds := int(ceil(session.remaining))
	var clock_text := "%02d:%02d" % [seconds / 60, seconds % 60]
	if not session.has_time_limit():
		clock_text = "LIVRE"
	_hud_text(clock_text, Vector2(290, 84), 42, CORAL if session.has_time_limit() and seconds <= 15 else CREAM)
	_hud_text("GIROS", Vector2(480, 30), 18, MUTED)
	_hud_text("%02d" % session.moves, Vector2(478, 84), 38, CREAM)
	var wire_count := 0
	for cell in session.board.cells:
		if cell["kind"] not in ["empty", "blocker"]:
			wire_count += 1
	var charge := float(session.board.energized.size()) / float(maxi(wire_count, 1))
	_draw_charge_meter(Vector2(544, 238), charge, session.board.energized.size(), wire_count)


func _draw_game_chrome(rect: Rect2) -> void:
	# Mesmo recorte e sombreamento da pausa, sem herdar o tremor da sala.
	if art_pack != null and art_pack.game_background != null:
		var texture := art_pack.game_background
		var ratio := texture.get_size() / GAME_DESIGN
		draw_texture_rect_region(texture, rect, Rect2(rect.position * ratio, rect.size * ratio))
	else:
		draw_rect(rect, PANEL)
	draw_rect(rect, ROOM_SHADE)


func _hud_text(caption: String, point: Vector2, font_size: int, color: Color) -> void:
	draw_string_outline(ThemeDB.fallback_font, point, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, INK)
	_text(caption, point, font_size, color)


func _draw_charge_meter(center: Vector2, fraction: float, active: int, total: int) -> void:
	draw_circle(center, 69, INK)
	draw_circle(center, 64, Color("54616b"))
	draw_circle(center, 57, Color("17262d"))
	for index in range(9):
		var angle := PI + index * PI / 8.0
		draw_line(center + Vector2.from_angle(angle) * 43, center + Vector2.from_angle(angle) * 51, MUTED, 2, true)
	draw_arc(center, 48, PI, PI * 1.5, 24, Color("708555"), 7, true)
	draw_arc(center, 48, PI * 1.5, TAU, 24, YELLOW, 7, true)
	draw_line(center, center + Vector2.from_angle(PI + clampf(fraction, 0, 1) * PI) * 42, CORAL, 4, true)
	draw_circle(center, 6, CREAM)
	var label := "%d/%d fios" % [active, total]
	var width := ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
	_text(label, center + Vector2(-width * 0.5, 31), 17, CREAM)
	_text("CARGA", center + Vector2(-28, 91), 16, YELLOW)


func _update_room() -> void:
	if not is_instance_valid(room_view):
		return
	room_view.visible = screen in ["menu", "game"]
	room_view.embedded = true
	room_view.position = Vector2(150, 420) if screen == "menu" else Vector2(198, 1038)
	room_view.size = Vector2(420, 410) if screen == "menu" else Vector2(324, 324)
	operator_view.visible = screen == "game"
	cable_view.visible = screen == "game"
	room_view.state = &"idle"
	room_view.is_menu = screen == "menu"
	room_view.animation_time = pulse
	room_view.phase_progress = 0.0
	var talking: bool = screen == "game" and dialogue.active
	room_view.speaking = talking and dialogue.step == 1
	operator_view.speaking = talking and dialogue.step == 0
	room_view.speech_time = dialogue.presentation_time
	operator_view.speech_time = dialogue.presentation_time
	room_view.soft_flashes = reduced_flashes
	room_view.line_one = "O painel precisa de uma revisão."
	room_view.line_two = "Ache o fio certo e ligue a energia."
	if screen == "game":
		room_view.line_one = str(level_data["tip_lines"][0])
		room_view.line_two = str(level_data["tip_lines"][1])
		if session.state == Session.State.RESOLVING:
			if resolution_elapsed < SWITCH_PULL_TIME:
				room_view.state = &"anticipation"
				room_view.animation_time = resolution_elapsed
				room_view.phase_progress = resolution_elapsed / SWITCH_PULL_TIME
			elif resolution_elapsed < ZAP_END_TIME:
				room_view.state = &"zap"
				room_view.animation_time = resolution_elapsed - SWITCH_PULL_TIME
				room_view.phase_progress = (resolution_elapsed - SWITCH_PULL_TIME) / (ZAP_END_TIME - SWITCH_PULL_TIME)
			else:
				room_view.state = &"recover"
				room_view.animation_time = resolution_elapsed - ZAP_END_TIME
				room_view.phase_progress = (resolution_elapsed - ZAP_END_TIME) / (RESOLUTION_DURATION - ZAP_END_TIME)
		elif session.state == Session.State.WON:
			room_view.state = &"win"
		elif session.state == Session.State.LOST:
			room_view.state = &"lose"
		elif session.has_time_limit() and session.remaining <= 15:
			room_view.state = &"worried"
	room_view.queue_redraw()
	operator_view.state = room_view.state
	operator_view.animation_time = room_view.animation_time
	operator_view.phase_progress = room_view.phase_progress
	operator_view.queue_redraw()
	cable_view.queue_redraw()


func _draw_settings() -> void:
	if art_pack != null and art_pack.game_background != null:
		settings.draw_texture_rect(art_pack.game_background, Rect2(Vector2.ZERO, GAME_DESIGN), false)
	else:
		settings.draw_rect(Rect2(Vector2.ZERO, GAME_DESIGN), INK)
	settings.draw_rect(Rect2(Vector2.ZERO, GAME_DESIGN), Color(0.015, 0.03, 0.045, 0.55))
	_center("AJUSTES", 240, 50, YELLOW, settings)
	_center("A partida continua pausada." if screen == "game" else "Áudio e resposta do jogo", 292, 22, CREAM, settings)
	_text("MÚSICA", Vector2(112, 492), 26, CREAM, settings)
	_text("%d%%" % roundi(profile.music_volume * 100), Vector2(540, 492), 26, MINT, settings)
	_text("EFEITOS", Vector2(112, 654), 26, CREAM, settings)
	_text("%d%%" % roundi(profile.effects_volume * 100), Vector2(540, 654), 26, MINT, settings)
	_center("Ative o som geral para ajustar os volumes." if not sound_enabled else "Os ajustes ficam salvos neste aparelho.", 1330, 20, MUTED, settings)


func _draw_overlay() -> void:
	if art_pack != null and art_pack.game_background != null:
		overlay.draw_texture_rect(art_pack.game_background, Rect2(Vector2.ZERO, GAME_DESIGN), false)
	_draw_floor_strip(overlay, 710, 74)
	overlay.draw_rect(Rect2(Vector2.ZERO, GAME_DESIGN), ROOM_SHADE)
	var title := "PAUSADO"
	var accent := YELLOW
	var summary := "O tempo está parado."
	var next := "Continue quando estiver pronto."
	if session.state == Session.State.WON:
		title = "FASE CONCLUÍDA"
		accent = MINT
		summary = "%d PONTOS" % session.score()
		if session.has_time_limit():
			summary += "  ·  " + Profile.format_time(session.elapsed)
		next = "A SEGUIR · FASE %02d" % (level_index + 2)
		if level_index == levels.size() - 1:
			next = "%d FASES CONCLUÍDAS" % levels.size()
	elif session.state == Session.State.LOST:
		title = "DEU PANE!"
		accent = CORAL
		summary = "O tempo acabou."
		next = "Mais uma tentativa?"
	var heading := "MISSÃO CUMPRIDA" if _is_final_result() else "FASE %02d / %02d" % [level_index + 1, levels.size()]
	_center(heading, 240, 24, accent, overlay)
	if not _is_final_result():
		_center(title, 310, 50, CREAM, overlay)
	var portrait: Texture2D = room_view.portrait_texture()
	result_portrait.set_frame(portrait, execution_character)
	if portrait == null:
		_bolt(Vector2(360, 560), 2.0, accent, overlay)
	if session.state == Session.State.WON:
		for index in range(3):
			_draw_star(Vector2(280 + index * 80, 824), 28, YELLOW if index < session.stars() else EDGE, overlay)
	_center(summary, 904, 28, CREAM, overlay)
	_center(next, 964, 24, MUTED, overlay)


func _bolt(center: Vector2, scale_factor: float, color: Color, canvas: CanvasItem = null) -> void:
	var points := PackedVector2Array()
	for offset in [Vector2(9, -35), Vector2(-18, 5), Vector2(-2, 5), Vector2(-9, 35), Vector2(22, -8), Vector2(6, -8)]:
		points.append(center + offset * scale_factor)
	(canvas if canvas != null else self).draw_colored_polygon(points, color)


func _draw_star(center: Vector2, radius: float, color: Color, canvas: CanvasItem) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var angle := -PI * 0.5 + i * PI / 5.0
		var length := radius if i % 2 == 0 else radius * 0.45
		points.append(center + Vector2(cos(angle), sin(angle)) * length)
	canvas.draw_colored_polygon(points, color)


func _panel(rect: Rect2, fill: Color, border: Color, radius: int = 18, canvas: CanvasItem = null) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	_styles.append(style)
	(canvas if canvas != null else self).draw_style_box(style, rect)


func _text(caption: String, point: Vector2, font_size: int, color: Color = CREAM, canvas: CanvasItem = null) -> void:
	(canvas if canvas != null else self).draw_string(ThemeDB.fallback_font, point, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _center(caption: String, baseline: float, font_size: int, color: Color = CREAM, canvas: CanvasItem = null) -> void:
	var width := ThemeDB.fallback_font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	_text(caption, Vector2((DESIGN.x - width) * 0.5, baseline), font_size, color, canvas)


func _cue(cue: String) -> void:
	if is_instance_valid(audio):
		audio.set_enabled(sound_enabled)
		audio.play_cue(cue)


func _sync_audio() -> void:
	if not is_instance_valid(audio):
		return
	audio.set_enabled(sound_enabled)
	audio.set_volumes(profile.music_volume, profile.effects_volume)
	if screen == "game" and int(session.state) != _audio_state:
		if session.state == Session.State.WON:
			_cue("win")
		elif session.state == Session.State.LOST:
			_cue("lose")
	_audio_state = int(session.state) if screen == "game" else -1
	var active := screen == "game" and session.state == Session.State.PLAYING
	var fraction := float(session.board.energized.size()) / maxi(1, session.board.cells.size())
	audio.update_context(active, fraction, int(ceil(session.remaining)) if session.has_time_limit() else -1,
		screen == "game" and session.state == Session.State.PAUSED,
		screen == "game" and session.state == Session.State.RESOLVING)


func _load_preferences() -> void:
	if not persistence_enabled:
		return
	profile.load_profile("user://prototype.cfg", levels.size())


func _save_preferences() -> void:
	if not persistence_enabled:
		return
	var error := profile.save_profile("user://prototype.cfg")
	if error != OK:
		push_warning("Não foi possível salvar as preferências: %s" % error_string(error))
