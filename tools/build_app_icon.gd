extends SceneTree
## Empacota a arte aprovada nos tamanhos nativos do launcher, sem redesenhá-la.

const DIRECTORY := "res://assets/icon/"


func _initialize() -> void:
	var art := Image.load_from_file(DIRECTORY + "goblin.png")
	if art == null or art.is_empty() or not art.detect_alpha():
		push_error("O goblin deve ser um PNG com transparência real.")
		quit(1)
		return
	art.convert(Image.FORMAT_RGBA8)
	art = art.get_region(art.get_used_rect())
	var background := Image.new()
	var error := background.load_svg_from_string(FileAccess.get_file_as_string(DIRECTORY + "background.svg"))
	if error != OK:
		push_error(error_string(error))
		quit(1)
		return
	background.convert(Image.FORMAT_RGBA8)
	var main := background.duplicate() as Image
	var main_art := art.duplicate() as Image
	var scale := 860.0 / maxf(art.get_width(), art.get_height())
	main_art.resize(roundi(art.get_width() * scale), roundi(art.get_height() * scale), Image.INTERPOLATE_LANCZOS)
	main.blend_rect(main_art, Rect2i(Vector2i.ZERO, main_art.get_size()), (main.get_size() - main_art.get_size()) / 2)
	if not _save(main, DIRECTORY + "app.png"):
		return
	# Toda a silhueta opaca cabe no círculo seguro de 66 dp, em uma tela de 108 dp.
	var radius := 0.0
	var center := Vector2(art.get_size()) * 0.5
	for y in range(art.get_height()):
		for x in range(art.get_width()):
			if art.get_pixel(x, y).a > 0.05:
				radius = maxf(radius, Vector2(x + 0.5, y + 0.5).distance_to(center))
	scale = 130.0 / radius
	var adaptive_art := art.duplicate() as Image
	adaptive_art.resize(roundi(art.get_width() * scale), roundi(art.get_height() * scale), Image.INTERPOLATE_LANCZOS)
	var foreground := Image.create(432, 432, false, Image.FORMAT_RGBA8)
	foreground.fill(Color.TRANSPARENT)
	foreground.blend_rect(adaptive_art, Rect2i(Vector2i.ZERO, adaptive_art.get_size()), (foreground.get_size() - adaptive_art.get_size()) / 2)
	background.resize(432, 432, Image.INTERPOLATE_LANCZOS)
	if not _save(foreground, DIRECTORY + "adaptive_foreground.png") or not _save(background, DIRECTORY + "adaptive_background.png"):
		return
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var preview := background.duplicate() as Image
	preview.blend_rect(foreground, Rect2i(0, 0, 432, 432), Vector2i.ZERO)
	# Máscara circular equivalente ao launcher: área visível de 72 dp em 108 dp.
	preview = preview.get_region(Rect2i(72, 72, 288, 288))
	for y in range(288):
		for x in range(288):
			if Vector2(x + 0.5, y + 0.5).distance_to(Vector2(144, 144)) > 144.0:
				preview.set_pixel(x, y, Color.TRANSPARENT)
	if not _save(preview, "res://builds/previews/icon-android.png"):
		return
	preview.resize(64, 64, Image.INTERPOLATE_LANCZOS)
	if not _save(preview, "res://builds/previews/icon-64.png"):
		return
	print("Ícone: principal 1024 px; camadas adaptativas 432 px; silhueta dentro do raio seguro de 132 px.")
	quit()


func _save(image: Image, path: String) -> bool:
	var error := image.save_png(path)
	if error != OK:
		push_error("Falha ao salvar " + path + ": " + error_string(error))
		quit(1)
		return false
	return true
