extends Node2D

const FOLIAGE := preload("res://assets/art/world/greyhaven_foliage_cluster.svg")
const COBBLES := preload("res://assets/art/world/greyhaven_cobble_patch.svg")
const LANTERN := preload("res://assets/art/world/greyhaven_lantern.svg")
const PINE := preload("res://assets/art/world/greyhaven_pine.svg")
const STONE := preload("res://assets/art/world/greyhaven_stone.svg")

func _ready() -> void:
	z_index = 1
	_add_cobbles()
	_add_foliage()
	_add_roadside_props()

func _sprite(texture: Texture2D, pos: Vector2, scale_value := 1.0, mod := Color.WHITE) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = texture
	s.position = pos
	s.scale = Vector2.ONE * scale_value
	s.modulate = mod
	add_child(s)
	return s

func _add_cobbles() -> void:
	var spots := [Vector2(970, 250), Vector2(990, 520), Vector2(980, 760), Vector2(995, 1030), Vector2(975, 1300), Vector2(700, 760), Vector2(1280, 755)]
	for i in spots.size():
		var s := _sprite(COBBLES, spots[i], 0.72 if i % 2 == 0 else 0.58, Color(1, 1, 1, 0.72))
		s.rotation = -0.12 + float(i % 3) * 0.11

func _add_foliage() -> void:
	var spots := [Vector2(180, 430), Vector2(390, 500), Vector2(610, 610), Vector2(250, 950), Vector2(500, 1040), Vector2(720, 920), Vector2(1260, 1040), Vector2(1450, 930), Vector2(1780, 920)]
	for i in spots.size():
		_sprite(FOLIAGE, spots[i], 0.82 + float(i % 3) * 0.12, Color(0.95, 1.0, 0.95, 0.92))

func _add_roadside_props() -> void:
	for data in [[Vector2(835, 360), 0.72], [Vector2(1135, 510), 0.62], [Vector2(830, 1120), 0.66], [Vector2(1160, 1240), 0.74]]:
		_sprite(PINE, data[0], data[1])
	for data in [[Vector2(785, 690), 0.72], [Vector2(1190, 850), 0.62], [Vector2(1380, 650), 0.55]]:
		_sprite(STONE, data[0], data[1])
	for pos in [Vector2(865, 690), Vector2(1115, 690), Vector2(865, 875), Vector2(1115, 875)]:
		var lantern := _sprite(LANTERN, pos, 0.78)
		lantern.z_index = 2
