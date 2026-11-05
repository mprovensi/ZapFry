extends RefCounted

const Roster = preload("res://scripts/character_roster.gd")
const Profile = preload("res://scripts/player_profile.gd")


func run(check: Callable) -> void:
	var previous := ""
	var roster := Roster.new(7281)
	var count := Roster.TEMPLATES.size()
	check.call(count == 7, "Catálogo inclui as cinco bases, o zumbi e a elfa")
	for cycle in range(20):
		var seen: Dictionary = {}
		for index in range(count):
			var level_index := cycle * count + index
			var choice: Dictionary = roster.select(level_index, {})
			var snapshot: Dictionary = choice["snapshot"]
			check.call(not seen.has(snapshot["id"]) and snapshot["id"] != previous, "Sorteio mostra todas as bases sem repetição, inclusive entre rodadas")
			seen[snapshot["id"]] = true
			previous = snapshot["id"]
			var repeated: Dictionary = roster.select(level_index, snapshot)
			check.call(repeated["snapshot"] == snapshot and repeated["character"] == choice["character"], "Reiniciar mantém personagem, nome e instância")
	for template in Roster.TEMPLATES:
		check.call(template.aliases.size() == 5 and template.display_name in template.aliases, "Cada base tem cinco nomes válidos")
		var paths: Dictionary = {}
		for state in [&"idle", &"zap", &"recover"]:
			var texture: Texture2D = template.frame_texture(state, 0)
			var expected := "res://assets/characters/%s/%s.png" % [template.character_id, state]
			check.call(texture != null and texture.resource_path == expected, "Pose pertence ao próprio condenado: " + expected)
			check.call(texture.get_width() <= 512 and texture.get_height() <= 512 and texture.get_image().detect_alpha() != Image.ALPHA_NONE, "Pose importada leve e transparente")
			paths[texture.resource_path] = true
		check.call(paths.size() == 3, "Espera, esqueleto e recuperação são artes distintas")
		var idle_data: PackedByteArray = template.frame_texture(&"idle", 0).get_image().get_data()
		check.call(template.frame_texture(&"zap", 0).get_image().get_data() != idle_data and template.frame_texture(&"recover", 0).get_image().get_data() != idle_data, "Choque e recuperação não são cópias da espera")
		check.call(template.frame_texture(&"zap", 0, true) == template.frame_texture(&"zap", 0), "Modo suave também usa o esqueleto próprio")
		check.call(template.frame_texture(&"win", 0) == template.frame_texture(&"recover", 0), "Resultado preserva o personagem na recuperação")
	var selected := roster.select(0, {})
	var profile := Profile.new()
	profile.appearance = selected["snapshot"]
	var path := "res://builds/character-profile.cfg"
	check.call(profile.save_profile(path) == OK, "Personagem atual salva com o progresso")
	var restored := Profile.new()
	check.call(restored.load_profile(path) == OK and restored.appearance == profile.appearance, "Personagem e nome sobrevivem à reabertura")
	var reload_roster := Roster.new(123)
	var restored_choice := reload_roster.select(0, restored.appearance)
	check.call(restored_choice["snapshot"] == profile.appearance, "Outra instância não troca o condenado da fase pendente")
	for seed_value in range(25):
		var next_choice := Roster.new(seed_value).select(1, profile.appearance)
		check.call(next_choice["snapshot"]["id"] != profile.appearance["id"], "Abrir outra fase após reabrir não repete o último condenado")
	var bad := reload_roster.select(0, {"level": 0, "id": "removed-character", "name": "unknown"})
	check.call(bad["character"] != null and bad["snapshot"]["id"] != "removed-character", "ID removido usa personagem válido")
	var invalid_name := reload_roster.select(0, {"level": 0, "id": "cavaleira", "name": "not a valid alias"})
	check.call(invalid_name["character"].display_name == Roster.TEMPLATES[0].display_name, "Nome inválido não entra na interface")
	check.call(Roster.TEMPLATES[0].display_name == "Zefa do Trovão", "Sorteio nunca modifica o template compartilhado")
	var config := ConfigFile.new()
	config.load(path)
	config.set_value("appearance", "current", {"level": "bad", "id": [], "name": 99})
	config.save(path)
	check.call(restored.load_profile(path) == OK and restored.appearance.is_empty(), "Aparência malformada é descartada sem invalidar o progresso")
	print("Condenados: sete bases, poses próprias, sorteio sem repetição, aliases e persistência verificados.")


func run_ui(app, check: Callable) -> void:
	app.level_index = 0
	app.start_game(false)
	var selected = app.execution_character
	var snapshot: Dictionary = app.profile.appearance.duplicate()
	var cells: Array = app.session.board.cells.duplicate(true)
	app.pause_game()
	app.show_settings()
	app._process(10)
	app.close_settings()
	app.resume_game()
	check.call(app.execution_character == selected and app.profile.appearance == snapshot and app.session.board.cells == cells, "Pausa e ajustes não sorteiam nem alteram a tentativa")
	app.start_game(false)
	check.call(app.execution_character == selected and app.profile.appearance == snapshot, "Reiniciar preserva o condenado")
	check.call(not _has_floating_name(app), "Partida não exibe nome avulso ao lado da cadeira")
	app.level_index = 1
	app.start_game(false)
	check.call(app.execution_character.character_id != selected.character_id, "Fase seguinte recebe outro condenado")
	for dimensions in [Vector2(360, 800), Vector2(720, 1280), Vector2(720, 1600)]:
		app.size = dimensions
		app._layout_stage()
		for template in Roster.TEMPLATES:
			for soft in [false, true]:
				app.profile.appearance = {"level": 0, "id": template.character_id, "name": template.display_name}
				app.reduced_flashes = soft
				app.level_index = 0
				app.start_game(false)
				check.call(not _has_floating_name(app), "Nome avulso permanece removido em todas as proporções e personagens")
				app._on_cell_pressed(1)
				app._process(0.6)
				check.call(app.room_view.portrait_texture() == template.frame_texture(&"zap", 0, soft) and not app.overlay.visible, "Cada condenado exibe o próprio esqueleto durante o choque")
				app._process(1.3)
				check.call(app.room_view.portrait_texture() == template.frame_texture(&"recover", 0) and not app.overlay.visible, "Recuperação própria antecede resultado em ambos os modos")
				app._process(0.6)
				check.call(app.room_view.portrait_texture() == template.frame_texture(&"win", 0), "Resultado mantém a identidade do condenado")


func _has_floating_name(app) -> bool:
	for child in app.stage.get_children():
		if child is Label and child.visible and child.text == app.execution_character.display_name:
			return true
	return false
