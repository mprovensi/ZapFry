extends TextureRect
## Material exclusivo: roupa, expressão localizada e transição entre poses.

const Character = preload("res://scripts/execution_character.gd")
const PALETTE_SHADER = preload("res://assets/characters/clothing_palette.gdshader")
const MASK = preload("res://assets/characters/body_mask.svg")
var _palette_material := ShaderMaterial.new()
var _recolor := false
var _moving := false
var _blending := false


func _init() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_palette_material.shader = PALETTE_SHADER
	_palette_material.set_shader_parameter("clothing_mask", MASK)


func set_frame(value: Texture2D, character: Character = null) -> void:
	texture = value
	visible = value != null
	_moving = false
	_blending = false
	_palette_material.set_shader_parameter("head_offset", Vector2.ZERO)
	_palette_material.set_shader_parameter("blink", 0.0)
	_palette_material.set_shader_parameter("pose_blend", 0.0)
	_recolor = character != null and character.palette_index > 0 and character.palette_index < character.palette_colors.size()
	_palette_material.set_shader_parameter("recolor", _recolor)
	if _recolor:
		_palette_material.set_shader_parameter("source_hue", character.clothing_hue)
		_palette_material.set_shader_parameter("target_color", character.palette_colors[character.palette_index])
	_update_material()


func set_motion(region: Rect2, offset: Vector2, left: Rect2 = Rect2(), right: Rect2 = Rect2(), blink_value: float = 0.0) -> void:
	_palette_material.set_shader_parameter("face_region", Vector4(region.position.x, region.position.y, region.size.x, region.size.y))
	_palette_material.set_shader_parameter("head_offset", offset)
	_palette_material.set_shader_parameter("left_eye", Vector4(left.position.x, left.position.y, left.size.x, left.size.y))
	_palette_material.set_shader_parameter("right_eye", Vector4(right.position.x, right.position.y, right.size.x, right.size.y))
	_palette_material.set_shader_parameter("blink", clampf(blink_value, 0.0, 1.0))
	_moving = offset != Vector2.ZERO or blink_value > 0
	_update_material()


func set_pose_blend(next: Texture2D, weight: float) -> void:
	var amount := clampf(weight, 0.0, 1.0) if next != null else 0.0
	_palette_material.set_shader_parameter("next_pose", next)
	_palette_material.set_shader_parameter("pose_blend", amount)
	_blending = amount > 0
	_update_material()


func _update_material() -> void:
	material = _palette_material if _recolor or _moving or _blending else null
