extends Resource
## Aparência de quem ocupa a cadeira, independente do painel e do operador.

const ArtPack = preload("res://scripts/art_pack.gd")

@export var display_name := "Visitante"
@export var character_id := ""
@export var aliases := PackedStringArray()
@export var portrait: SpriteFrames
@export var clothing_hue := 0.92
@export var palette_colors := PackedColorArray([Color.WHITE, Color("3fa77d"), Color("bf3d4b"), Color("3c76c7")])
var palette_index := 0
## Ponto de entrada do cabo na imagem, em coordenadas normalizadas do canvas.
@export var cable_anchor := Vector2(0.74, 0.69)


func frame_texture(state: StringName, seconds: float, soft: bool = false) -> Texture2D:
	return ArtPack.sample_frames(portrait, state, seconds, soft)
