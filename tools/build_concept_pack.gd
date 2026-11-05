extends SceneTree
## Montagem de recursos nativos. Não altera os pixels dos PNGs gerados.

const ArtPack = preload("res://scripts/art_pack.gd")
const ExecutionCharacter = preload("res://scripts/execution_character.gd")
const DIRECTORY := "res://assets/art/concept_v3/"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var pack: ArtPack = load("res://assets/art/cartoon_v2.tres").duplicate()
	pack.pack_name = "Conceito industrial v3"
	for kind in ["straight", "curve", "tee", "blocker"]:
		var suffix := "_uniform" if kind in ["curve", "tee"] else ""
		pack.set(kind, load(DIRECTORY + kind + suffix + ".png"))
		if kind != "blocker":
			pack.set(kind + "_live", load(DIRECTORY + kind + "_live" + suffix + ".png"))
	pack.tile_background = _trimmed("tile_plate")
	pack.restart_icon = _trimmed("restart_icon")
	pack.primary_button = _trimmed("primary_button")
	pack.room_background = load(DIRECTORY + "room_background.png")
	pack.game_background = load(DIRECTORY + "game_room.png")
	# O trecho central elimina as pontas inclinadas do recorte e prolonga o andar até as paredes.
	var floor_texture := _trimmed("actor_floor") as AtlasTexture
	floor_texture.region = Rect2(floor_texture.region.position + Vector2(floor_texture.region.size.x * 0.2, 0), floor_texture.region.size * Vector2(0.6, 1))
	pack.room_floor = floor_texture
	pack.menu_portrait = load(DIRECTORY + "menu_chair_wires.png")
	pack.live_color = Color("79ecff")
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for state in [&"idle", &"worried", &"anticipation", &"zap", &"zap_soft", &"recover", &"win", &"lose"]:
		frames.add_animation(state)
		var file := "portrait_zap" if state in [&"zap", &"zap_soft"] else "portrait_recover" if state in [&"recover", &"win"] else "portrait_idle"
		frames.add_frame(state, load(DIRECTORY + file + ".png"))
		frames.set_animation_loop(state, false)
		frames.set_animation_speed(state, 1.0)
	pack.portrait = frames
	var engineer := SpriteFrames.new()
	engineer.remove_animation(&"default")
	for state in [&"idle", &"worried", &"anticipation", &"zap", &"zap_soft", &"recover", &"win", &"lose"]:
		engineer.add_animation(state)
		engineer.set_animation_loop(state, false)
		engineer.set_animation_speed(state, 7.5)
		if state == &"anticipation":
			for file in ["engineer", "engineer_middle", "engineer_down"]:
				engineer.add_frame(state, load(DIRECTORY + file + ".png"))
		else:
			var file := "engineer_down" if state in [&"zap", &"zap_soft", &"recover", &"win"] else "engineer"
			engineer.add_frame(state, load(DIRECTORY + file + ".png"))
	pack.engineer = engineer
	DirAccess.make_dir_recursive_absolute("res://assets/characters")
	# Não sobrescrever ajustes manuais de um personagem já criado.
	if not ResourceLoader.exists("res://assets/characters/knight.tres"):
		var character := ExecutionCharacter.new()
		character.display_name = "Cavaleiro"
		character.portrait = frames
		var character_error := ResourceSaver.save(character, "res://assets/characters/knight.tres")
		if character_error != OK:
			push_error("Falha ao salvar personagem: " + error_string(character_error))
			quit(1)
			return
	var error := ResourceSaver.save(pack, "res://assets/art/concept_v3.tres")
	if error != OK:
		push_error("Falha ao salvar pacote: " + error_string(error))
		quit(1)
		return
	print("Pacote concept_v3.tres montado, com placa fixa e fios independentes.")
	quit()


func _trimmed(name: String) -> Texture2D:
	var texture: Texture2D = load(DIRECTORY + name + ".png")
	var image := texture.get_image()
	var left := image.get_width()
	var top := image.get_height()
	var right := 0
	var bottom := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.12:
				left = mini(left, x)
				top = mini(top, y)
				right = maxi(right, x)
				bottom = maxi(bottom, y)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(left, top, right - left + 1, bottom - top + 1)
	return atlas
