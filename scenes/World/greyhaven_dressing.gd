extends Node2D

const FOLIAGE := preload("res://assets/art/world/greyhaven_foliage_cluster.svg")
const LANTERN := preload("res://assets/art/world/greyhaven_lantern.svg")
const PINE := preload("res://assets/art/world/greyhaven_pine.svg")
const STONE := preload("res://assets/art/world/greyhaven_stone.svg")

func _ready() -> void:
	z_index = 1
	_add_cobbles()
	_add_road_edge_growth()
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

func _embedded_stone(pos: Vector2, size: Vector2, rotation_value: float, stone_color: Color) -> void:
	# Two flat polygons read as a stone pressed into the road rather than a sprite sitting on top of it.
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([
		Vector2(-0.52, -0.25), Vector2(-0.24, -0.50), Vector2(0.24, -0.47),
		Vector2(0.53, -0.16), Vector2(0.43, 0.30), Vector2(0.08, 0.49),
		Vector2(-0.38, 0.35)
	])
	shadow.position = pos + Vector2(1.5, 2.0)
	shadow.scale = size
	shadow.rotation = rotation_value
	shadow.color = Color(0.08, 0.07, 0.06, 0.22)
	add_child(shadow)

	var stone := Polygon2D.new()
	stone.polygon = PackedVector2Array([
		Vector2(-0.52, -0.28), Vector2(-0.25, -0.50), Vector2(0.23, -0.46),
		Vector2(0.52, -0.14), Vector2(0.41, 0.28), Vector2(0.07, 0.47),
		Vector2(-0.39, 0.33)
	])
	stone.position = pos
	stone.scale = size
	stone.rotation = rotation_value
	stone.color = stone_color
	add_child(stone)

func _add_cobbles() -> void:
	# Individual, incomplete cobbling. Dirt remains visible between every stone and coverage thins toward the outskirts.
	var stones := [
		[Vector2(956, 130), Vector2(18, 11), -0.18, Color(0.34, 0.34, 0.31, 0.72)],
		[Vector2(989, 145), Vector2(15, 10), 0.10, Color(0.39, 0.38, 0.34, 0.68)],
		[Vector2(1020, 124), Vector2(17, 9), -0.06, Color(0.31, 0.32, 0.30, 0.66)],
		[Vector2(969, 205), Vector2(14, 9), 0.17, Color(0.36, 0.36, 0.33, 0.62)],
		[Vector2(1007, 232), Vector2(19, 11), -0.12, Color(0.30, 0.31, 0.29, 0.66)],
		[Vector2(950, 330), Vector2(16, 10), 0.08, Color(0.38, 0.37, 0.34, 0.64)],
		[Vector2(986, 350), Vector2(19, 12), -0.04, Color(0.32, 0.33, 0.31, 0.70)],
		[Vector2(1021, 329), Vector2(14, 9), 0.14, Color(0.40, 0.39, 0.35, 0.58)],
		[Vector2(965, 430), Vector2(13, 8), -0.15, Color(0.35, 0.35, 0.32, 0.56)],
		[Vector2(1004, 466), Vector2(18, 10), 0.05, Color(0.29, 0.30, 0.28, 0.62)],
		[Vector2(948, 555), Vector2(17, 10), 0.11, Color(0.37, 0.36, 0.32, 0.66)],
		[Vector2(987, 574), Vector2(15, 9), -0.08, Color(0.32, 0.33, 0.30, 0.60)],
		[Vector2(1022, 548), Vector2(20, 11), 0.18, Color(0.41, 0.39, 0.35, 0.58)],
		[Vector2(957, 665), Vector2(15, 9), -0.04, Color(0.31, 0.32, 0.29, 0.62)],
		[Vector2(995, 688), Vector2(18, 11), 0.12, Color(0.37, 0.36, 0.33, 0.68)],
		[Vector2(1030, 674), Vector2(13, 8), -0.17, Color(0.29, 0.30, 0.28, 0.56)],
		[Vector2(926, 744), Vector2(17, 10), 0.06, Color(0.35, 0.35, 0.32, 0.66)],
		[Vector2(966, 760), Vector2(20, 12), -0.10, Color(0.30, 0.31, 0.29, 0.72)],
		[Vector2(1009, 742), Vector2(16, 10), 0.15, Color(0.40, 0.39, 0.35, 0.68)],
		[Vector2(1044, 773), Vector2(18, 11), -0.02, Color(0.33, 0.34, 0.31, 0.64)],
		[Vector2(1092, 754), Vector2(15, 9), 0.13, Color(0.36, 0.35, 0.32, 0.58)],
		[Vector2(838, 768), Vector2(16, 9), -0.14, Color(0.33, 0.34, 0.31, 0.54)],
		[Vector2(751, 749), Vector2(14, 8), 0.09, Color(0.38, 0.37, 0.33, 0.48)],
		[Vector2(645, 775), Vector2(12, 7), -0.10, Color(0.31, 0.32, 0.29, 0.40)],
		[Vector2(1180, 766), Vector2(16, 9), -0.06, Color(0.33, 0.33, 0.30, 0.52)],
		[Vector2(1285, 748), Vector2(13, 8), 0.12, Color(0.39, 0.37, 0.34, 0.45)],
		[Vector2(1405, 776), Vector2(11, 7), -0.14, Color(0.30, 0.31, 0.29, 0.36)],
		[Vector2(958, 860), Vector2(16, 9), 0.10, Color(0.37, 0.36, 0.33, 0.60)],
		[Vector2(1000, 884), Vector2(19, 11), -0.05, Color(0.31, 0.32, 0.30, 0.66)],
		[Vector2(1025, 970), Vector2(14, 8), 0.15, Color(0.39, 0.38, 0.34, 0.56)],
		[Vector2(970, 1012), Vector2(18, 10), -0.11, Color(0.33, 0.34, 0.31, 0.62)],
		[Vector2(950, 1120), Vector2(14, 9), 0.06, Color(0.36, 0.35, 0.32, 0.54)],
		[Vector2(1008, 1146), Vector2(17, 10), -0.15, Color(0.30, 0.31, 0.29, 0.58)],
		[Vector2(974, 1272), Vector2(16, 9), 0.12, Color(0.38, 0.37, 0.34, 0.50)],
		[Vector2(1018, 1325), Vector2(13, 8), -0.08, Color(0.32, 0.33, 0.30, 0.44)],
		[Vector2(962, 1440), Vector2(12, 7), 0.09, Color(0.35, 0.35, 0.32, 0.36)]
	]
	for data in stones:
		_embedded_stone(data[0], data[1], data[2], data[3])

func _add_road_edge_growth() -> void:
	# Low weeds soften the hard terrain boundary without obscuring the playable route.
	var edge_growth := [
		[Vector2(900, 315), 0.22], [Vector2(1070, 405), 0.18], [Vector2(895, 590), 0.20],
		[Vector2(1080, 625), 0.16], [Vector2(888, 930), 0.20], [Vector2(1082, 1035), 0.18],
		[Vector2(900, 1260), 0.17], [Vector2(1078, 1360), 0.15],
		[Vector2(530, 680), 0.18], [Vector2(700, 820), 0.16], [Vector2(1260, 680), 0.17],
		[Vector2(1440, 825), 0.15], [Vector2(1640, 690), 0.14]
	]
	for data in edge_growth:
		_sprite(FOLIAGE, data[0], data[1], Color(0.58, 0.68, 0.52, 0.56))

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
		[Vector2(1435, 625), 0.46, Color(0.43, 0.47, 0.39, 0.66)],
		[Vector2(1185, 420), 0.40, Color(0.68, 0.77, 0.62, 0.72)],
		[Vector2(1240, 530), 0.34, Color(0.61, 0.70, 0.55, 0.66)],
		[Vector2(1325, 965), 0.38, Color(0.57, 0.65, 0.51, 0.66)],
		[Vector2(1580, 995), 0.42, Color(0.48, 0.55, 0.44, 0.62)]
	]
	for data in spots:
		_sprite(FOLIAGE, data[0], data[1], data[2])

func _add_roadside_props() -> void:
	for data in [[Vector2(835, 360), 0.66], [Vector2(1135, 510), 0.56], [Vector2(830, 1120), 0.60], [Vector2(1160, 1240), 0.66]]:
		_sprite(PINE, data[0], data[1])
	for data in [[Vector2(785, 690), 0.64], [Vector2(1190, 850), 0.54], [Vector2(1380, 650), 0.48], [Vector2(1515, 870), 0.36]]:
		_sprite(STONE, data[0], data[1], Color(0.82, 0.84, 0.78, 0.92))
	for pos in [Vector2(865, 690), Vector2(1115, 690), Vector2(865, 875), Vector2(1115, 875)]:
		var lantern := _sprite(LANTERN, pos, 0.56, Color(0.90, 0.86, 0.74, 0.82))
		lantern.z_index = 2

func _add_corruption_transition() -> void:
	# Vegetation loses saturation before purple contamination becomes obvious.
	for data in [
		[Vector2(1365, 430), 0.48, Color(0.48, 0.50, 0.42, 0.66)],
		[Vector2(1465, 380), 0.44, Color(0.43, 0.42, 0.38, 0.62)],
		[Vector2(1515, 650), 0.40, Color(0.42, 0.35, 0.40, 0.60)],
		[Vector2(1590, 720), 0.38, Color(0.48, 0.30, 0.45, 0.58)],
		[Vector2(1670, 670), 0.34, Color(0.52, 0.27, 0.48, 0.52)]
	]:
		_sprite(FOLIAGE, data[0], data[1], data[2])
