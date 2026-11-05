extends Resource
## Apenas apresentação. Texturas/SpriteFrames podem ser substituídos no Inspector.

@export var pack_name := "Cartoon inicial"
@export var character: SpriteFrames
@export var chair: SpriteFrames
@export var room_background: Texture2D
@export var ui_background: Texture2D
@export var game_background: Texture2D
@export var room_floor: Texture2D
@export var tile_background: Texture2D
@export var live_color := Color("ffcd4d")
@export var restart_icon: Texture2D
@export var portrait: SpriteFrames
@export var menu_portrait: Texture2D
@export var primary_button: Texture2D
@export var engineer: SpriteFrames
@export var engineer_cable_anchor := Vector2(0.16, 0.66)
@export_group("Painel — orientação base: reto NS, curva NE, T NEW")
@export var straight: Texture2D
@export var straight_live: Texture2D
@export var curve: Texture2D
@export var curve_live: Texture2D
@export var tee: Texture2D
@export var tee_live: Texture2D
@export var blocker: Texture2D


func frame_texture(layer: StringName, state: StringName, seconds: float, soft: bool = false) -> Texture2D:
	if layer not in [&"character", &"chair", &"portrait", &"engineer"]:
		return null
	var frames := character if layer == &"character" else portrait if layer == &"portrait" else engineer if layer == &"engineer" else chair
	return sample_frames(frames, state, seconds, soft)


static func sample_frames(frames: SpriteFrames, state: StringName, seconds: float, soft: bool = false) -> Texture2D:
	if frames == null:
		return null
	var animation := state
	if soft and state == &"zap":
		animation = &"zap_soft"
	if not frames.has_animation(animation) or frames.get_frame_count(animation) == 0:
		animation = &"idle"
	if not frames.has_animation(animation) or frames.get_frame_count(animation) == 0:
		return null
	var speed := frames.get_animation_speed(animation)
	if speed <= 0.0:
		return frames.get_frame_texture(animation, 0)
	var duration := 0.0
	for index in range(frames.get_frame_count(animation)):
		duration += frames.get_frame_duration(animation, index) / speed
	var time := maxf(0.0, seconds) if is_finite(seconds) else 0.0
	if frames.get_animation_loop(animation):
		time = fmod(time, duration)
	else:
		time = minf(time, maxf(0.0, duration - 0.000001))
	for index in range(frames.get_frame_count(animation)):
		var frame_duration := frames.get_frame_duration(animation, index) / speed
		if time < frame_duration:
			return frames.get_frame_texture(animation, index)
		time -= frame_duration
	return frames.get_frame_texture(animation, frames.get_frame_count(animation) - 1)


func wire_texture(kind: String, live: bool) -> Texture2D:
	# Cada entrada é opcional: a ausência mantém o desenho geométrico legível.
	match kind:
		"straight": return straight_live if live else straight
		"curve": return curve_live if live else curve
		"tee": return tee_live if live else tee
		"blocker": return blocker
	return null


static func contain_rect(texture_size: Vector2, bounds: Rect2) -> Rect2:
	if texture_size.x <= 0 or texture_size.y <= 0:
		return Rect2(bounds.position, Vector2.ZERO)
	var ratio := minf(bounds.size.x / texture_size.x, bounds.size.y / texture_size.y)
	var extent := texture_size * ratio
	return Rect2(bounds.position + (bounds.size - extent) * 0.5, extent)
