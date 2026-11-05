extends TextureRect
## Material exclusivo do retrato; não recolore sala, UI, pele ou cadeira.

const Character = preload("res://scripts/execution_character.gd")
const PALETTE_SHADER = preload("res://assets/characters/clothing_palette.gdshader")
const MASK = preload("res://assets/characters/body_mask.svg")
var _palette_material := ShaderMaterial.new()


func _init() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_palette_material.shader = PALETTE_SHADER
	_palette_material.set_shader_parameter("clothing_mask", MASK)


func set_frame(value: Texture2D, character: Character = null) -> void:
	texture = value
	visible = value != null
	material = null
	if character != null and character.palette_index > 0 and character.palette_index < character.palette_colors.size():
		_palette_material.set_shader_parameter("source_hue", character.clothing_hue)
		_palette_material.set_shader_parameter("target_color", character.palette_colors[character.palette_index])
		material = _palette_material
