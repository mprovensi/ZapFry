extends RefCounted

const ArtPack = preload("res://scripts/art_pack.gd")
const Board = preload("res://scripts/circuit_board.gd")
const Session = preload("res://scripts/game_session.gd")


func run(check: Callable) -> void:
	var pack: ArtPack = load("res://assets/art/default_art.tres")
	check.call(pack != null, "Pacote visual padrão carrega como recurso Godot")
	for layer in [&"character", &"chair"]:
		var frames: SpriteFrames = pack.character if layer == &"character" else pack.chair
		for state in [&"idle", &"worried", &"anticipation", &"zap", &"zap_soft", &"recover", &"win", &"lose"]:
			check.call(frames.has_animation(state) and frames.get_frame_count(state) > 0, "Pacote tem pose %s / %s" % [layer, state])
			for index in range(frames.get_frame_count(state)):
				var texture := frames.get_frame_texture(state, index)
				check.call(texture != null and texture.get_width() > 0 and texture.get_height() > 0, "Pose tem canvas válido em qualquer resolução")
		check.call(pack.frame_texture(layer, &"missing", 0.0) == pack.frame_texture(layer, &"idle", 0.0), "Pose ausente usa idle")
		check.call(pack.frame_texture(layer, &"zap", 0.2, true) == pack.frame_texture(layer, &"zap_soft", 0.2), "Flashes suaves selecionam a animação própria")
	check.call(pack.frame_texture(&"unknown", &"idle", 0.0) == null, "Camada desconhecida não usa outra arte")
	var bounds := Rect2(12, 8, 230, 164)
	for extent in [Vector2(256, 256), Vector2(512, 512), Vector2(1024, 512)]:
		var fitted := ArtPack.contain_rect(extent, bounds)
		check.call(bounds.encloses(fitted) and fitted.get_center().is_equal_approx(bounds.get_center()), "Resoluções diferentes cabem na mesma área e preservam proporção")
	check.call(ArtPack.contain_rect(Vector2.ZERO, bounds).size == Vector2.ZERO, "Textura vazia não causa divisão por zero")
	_test_wire_ports(pack, check)
	var empty := ArtPack.new()
	check.call(empty.frame_texture(&"character", &"zap", 0.0) == null and empty.wire_texture("curve", true) == null, "Pacote vazio permite fallback geométrico")
	_test_frame_timing(check)
	print("Arte: poses, resoluções, animações, fallback e portas dos sprites verificados.")


func _test_wire_ports(pack: ArtPack, check: Callable) -> void:
	if pack == null:
		return
	# O sprite precisa desenhar as mesmas portas usadas pelo modelo, em cada giro.
	for kind in ["straight", "curve", "tee"]:
		for live in [false, true]:
			var texture := pack.wire_texture(kind, live)
			if texture == null:
				continue
			var image := texture.get_image()
			check.call(image != null and image.get_width() == image.get_height() and image.get_width() > 8, "Textura de fio disponível para leitura")
			if image == null:
				continue
			for turns in range(4):
				var mask := Board.rotate_mask(Board.BASE_MASKS[kind], turns)
				var middle: int = image.get_width() / 2
				var edge := image.get_width() - 3
				var probes := [Vector2i(middle, 2), Vector2i(edge, middle), Vector2i(middle, edge), Vector2i(2, middle)]
				for direction in range(4):
					check.call((image.get_pixelv(probes[direction]).a > 0.5) == bool(mask & Board.PORTS[direction]), "Sprite %s/%s/giro %d corresponde às portas do circuito" % [kind, live, turns])
				image.rotate_90(CLOCKWISE)


func _test_frame_timing(check: Callable) -> void:
	var pack := ArtPack.new()
	var red := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	red.fill(Color.RED)
	var blue := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	blue.fill(Color.BLUE)
	var first := ImageTexture.create_from_image(red)
	var second := ImageTexture.create_from_image(blue)
	pack.character = SpriteFrames.new()
	pack.character.add_animation(&"idle")
	pack.character.set_animation_speed(&"idle", 10)
	pack.character.add_frame(&"idle", first, 0.5)
	pack.character.add_frame(&"idle", second, 2.0)
	check.call(pack.frame_texture(&"character", &"idle", 0.049) == first, "Duração individual do primeiro frame é respeitada")
	check.call(pack.frame_texture(&"character", &"idle", 0.051) == second, "Avanço usa a duração de SpriteFrames")
	check.call(pack.frame_texture(&"character", &"idle", 0.26) == first, "Animação em loop recomeça")
	pack.character.set_animation_loop(&"idle", false)
	check.call(pack.frame_texture(&"character", &"idle", 20.0) == second, "Animação sem loop mantém última pose")
	check.call(pack.frame_texture(&"character", &"idle", -1.0) == first, "Tempo negativo mantém primeira pose")
	check.call(pack.frame_texture(&"character", &"zap", 10.0, true) == second, "Pacote sem zap suave usa idle")


func _test_wire_gauge(pack: ArtPack, check: Callable) -> void:
	# Medir a silhueta real nas pontas, não apenas a presença do pixel central.
	for kind in ["straight", "curve", "tee"]:
		for live in [false, true]:
			var image := pack.wire_texture(kind, live).get_image()
			var extent := image.get_width()
			for turns in range(4):
				var mask := Board.rotate_mask(Board.BASE_MASKS[kind], turns)
				for direction in range(4):
					if not (mask & Board.PORTS[direction]):
						continue
					var first := extent
					var last := -1
					for offset in range(extent):
						var point: Vector2i = [Vector2i(offset, 2), Vector2i(extent - 3, offset), Vector2i(offset, extent - 3), Vector2i(2, offset)][direction]
						if image.get_pixelv(point).a > 0.5:
							first = mini(first, offset)
							last = maxi(last, offset)
					var width := float(last - first + 1) / extent
					var center := float(first + last + 1) / (2.0 * extent)
					check.call(absf(width - 0.26) <= 0.02, "Espessura padronizada: %s/%s/giro %d/porta %d" % [kind, live, turns, direction])
					check.call(absf(center - 0.5) <= 0.015, "Ponta centralizada: %s/%s/giro %d/porta %d" % [kind, live, turns, direction])
				image.rotate_90(CLOCKWISE)


func run_ui(app, check: Callable) -> void:
	app.level_index = 10
	app.start_game(false)
	app._on_cell_pressed(5)
	var data: Dictionary = app.level_data.duplicate(true)
	var cells: Array = app.session.board.cells.duplicate(true)
	var moves: int = app.session.moves
	var remaining: float = app.session.remaining
	var record: Dictionary = app.profile.records.duplicate(true)
	var original: ArtPack = app.art_pack
	_test_wire_ports(original, check)
	_test_wire_gauge(original, check)
	check.call(original.tile_background != null and original.menu_portrait != null and original.room_background != null, "Conceito fornece placa, engenheiro e cenário")
	for state in [&"idle", &"worried", &"anticipation", &"zap", &"zap_soft", &"recover", &"win", &"lose"]:
		var texture := original.frame_texture(&"portrait", state, 0.0)
		check.call(texture != null and texture.get_size() == Vector2(512, 512), "Retrato composto mantém canvas em " + state)
	check.call(original.frame_texture(&"portrait", &"zap", 0.3, true) == original.frame_texture(&"portrait", &"zap", 0.3), "Modo suave do conceito preserva o esqueleto sem substituir pela pose de espera")
	check.call(original.frame_texture(&"portrait", &"zap", 0.3) != original.frame_texture(&"portrait", &"idle", 0.0), "Zap normal tem pose própria")
	for replacement in [load("res://assets/art/cartoon_v2.tres"), ArtPack.new(), null, original]:
		app.art_pack = replacement
		app._sync_controls()
		var textured: bool = replacement != null and replacement.primary_button != null
		check.call((app.buttons["hint"].get_theme_stylebox("normal") is StyleBoxTexture) == textured, "Botão acompanha arte atual e restaura fallback")
		check.call(app.buttons["restart"].icon == (replacement.restart_icon if replacement != null else null), "Reiniciar acompanha o ícone do pacote")
		check.call(app.room_view.art_pack == replacement and app.board_view.art_pack == replacement, "Troca do recurso alcança sala e tabuleiro")
		check.call(app.session.board.cells == cells and app.level_data == data and app.session.moves == moves and app.session.remaining == remaining, "Trocar sprites preserva partida e dados da fase")
		check.call(app.profile.records == record, "Trocar sprites preserva recordes")
	for viewport in [Vector2(720, 1280), Vector2(360, 800)]:
		app.size = viewport
		app._layout_stage()
		check.call(app.get_global_rect().encloses(app.room_view.get_global_rect()), "Sala com sprites cabe em tela normal e estreita")
	app.session.remaining = 10.0
	app._sync_controls()
	check.call(app.room_view.state == &"worried", "Tempo baixo seleciona expressão de tensão")
	app.level_index = 0
	app.start_game(false)
	app._on_cell_pressed(1)
	for sample in [[0.08, &"anticipation"], [0.32, &"anticipation"], [0.64, &"zap"], [1.3, &"zap"], [1.95, &"recover"]]:
		app.resolution_elapsed = sample[0]
		app._sync_controls()
		check.call(app.room_view.state == sample[1] and app.session.state == Session.State.RESOLVING, "Pose visual acompanha o zap sem finalizar a fase")
	app._process(app.RESOLUTION_DURATION + 0.1)
	check.call(app.room_view.state == &"win" and app.session.state == Session.State.WON, "Arte acompanha vitória preservando o fluxo")
	app.show_levels()
	check.call(not app.room_view.visible, "Sala não cobre o seletor")
	app.show_menu()
	check.call(app.room_view.visible and app.room_view.state == &"idle", "Menu reutiliza o pacote visual")
	check.call(app.room_view.is_menu, "Menu seleciona o engenheiro sem alterar o retrato da partida")
	app.start_game(false)
	check.call(not app.room_view.is_menu, "Partida seleciona o cliente da cadeira")
