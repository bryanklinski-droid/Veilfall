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
	_add_corruption_transition()

func _sprite(texture: Texture2D, pos: Vector2, scale_value := 1.0, mod := Color.WHITE) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = texture
	s.position = pos
	s.scale = Vector2.ONE * scale_value
	s.modulate = mod
	add_child(s)
	return s

func _add_cobbles() -> void:
	# Broken old-road cobbling: staggered, muted and partly buried instead of repeated white piles.
	var road_stones := [
		[Vector2(968, 120), 0.46, -0.10, 0.55], [Vector2(1008, 245), 0.42, 0.08, 0.50],
		[Vector2(955, 390), 0.50, -0.05, 0.62], [Vector2(1005, 535), 0.39, 0.12, 0.48],
		[Vector2(967, 665), 0.47, -0.08, 0.58], [Vector2(1015, 825), 0.42, 0.05, 0.50],
		[Vector2(958, 975), 0.48, 0.10, 0.57], [Vector2(1007, 1135), 0.38, -0.12, 0.45],
		[Vector2(970, 1290), 0.46, 0.04, 0.54], [Vector2(1000, 1440), 0.34, -0.06, 0.40],
		[Vector2(770, 755), 0.40, 0.04, 0.44], [Vector2(595, 770), 0.32, -0.10, 0.34],
		[Vector2(1215, 755), 0.39, -0.04, 0.43], [Vector2(1390, 770), 0.30, 0.09, 0.31]
	]
	for data in road_stones:
		var stone := _sprite(COBBLES, data[0], data[1], Color(0.72, 0.70, 0.64, data[3]))
		stone.rotation = data[2]

func _add_foliage() -> void:
	# Intentional clusters leave breathing room around the crossroads/player route.
	var spots := [
		[Vector2(170, 430), 0.72, Color(0.82, 0.91, 0.78, 0.88)],
		[Vector2(365, 500), 0.86, Color(0.88, 0.95, 0.82, 0.90)],
		[Vector2(590, 610), 0.66, Color(0.78, 0.88, 0.72, 0.84)],
		[Vector2(245, 950), 0.90, Color(0.86, 0.94, 0.80, 0.90)],
		[Vector2(490, 1040), 0.72, Color(0.80, 0.90, 0.74, 0.86)],
		[Vector2(700, 925), 0.62, Color(0.74, 0.84, 0.68, 0.82)],
		[Vector2(1260, 1030), 0.70, Color(0.68, 0.76, 0.62, 0.82)],
		[Vector2(1450, 930), 0.58, Color(0.55, 0.62, 0.50, 0.76)],
		[Vector2(1780, 920), 0.68, Color(0.48, 0.54, 0.45, 0.72)],
		[Vector2(1320, 570), 0.54, Color(0.55, 0.61, 0.49, 0.72)],
		[Vector2(1435, 625), 0.46, Color(0.43, 0.47, 0.39, 0.66)]
	]
	for data in spots:
		_sprite(FOLIAGE, data[0], data[1], data[2])

func _add_roadside_props() -> void:
	for data in [[Vector2(835, 360), 0.66], [Vector2(1135, 510), 0.56], [Vector2(830, 1120), 0.60], [Vector2(1160, 1240), 0.66]]:
		_sprite(PINE, data[0], data[1])
	for data in [[Vector2(785, 690), 0.64], [Vector2(1190, 850), 0.54], [Vector2(1380, 650), 0.48], [Vector2(1515, 870), 0.36]]:
		_sprite(STONE, data[0], data[1], Color(0.82, 0.84, 0.78, 0.92))
	for pos in [Vector2(865, 690), Vector2(1115, 690), Vector2(865, 875), Vector2(1115, 875)]:
		var lantern := _sprite(LANTERN, pos, 0.62, Color(0.92, 0.88, 0.76, 0.88))
		lantern.z_index = 2

func _add_corruption_transition() -> void:
	# Vegetation loses saturation before purple contamination becomes obvious.
	for data in [
		[Vector2(1365, 430), 0.48, Color(0.48, 0.50, 0.42, 0.66)],
		[Vector2(1465, 380), 0.44, Color(0.43, 0.42, 0.38, 0.62)],
		[Vector2(1515, 650), 0.40, Color(0.42, 0.35, 0.40, 0.60)],
		[Vector2(1590, 720), 0.38, Color(0.48, 0.30, 0.45, 0.58)]
	]:
		_sprite(FOLIAGE, data[0], data[1], data[2])
