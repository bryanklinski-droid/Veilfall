extends Node2D

const FOLIAGE := preload("res://assets/art/world/greyhaven_foliage_cluster.svg")
const GROUND_DETAIL := preload("res://assets/art/world/greyhaven_ground_detail.svg")
const FENCE := preload("res://assets/art/world/greyhaven_fence.svg")
const CORRUPT_GROWTH := preload("res://assets/art/world/greyhaven_corrupt_growth.svg")
const ROADSIDE_CLUTTER := preload("res://assets/art/world/greyhaven_roadside_clutter.svg")
const LANTERN := preload("res://assets/art/world/greyhaven_lantern.svg")
const PINE := preload("res://assets/art/world/greyhaven_pine.svg")
const STONE := preload("res://assets/art/world/greyhaven_stone.svg")

func _ready() -> void:
	z_index = 1
	_add_ground_layers()
	_add_road_wear()
	_add_cobbles()
	_add_boundaries()
	_add_road_edge_growth()
	_add_foliage()
	_add_roadside_props()
	_add_roadside_story_props()
	_add_corruption_transition()
	_add_foreground_frame()

func _sprite(texture: Texture2D, pos: Vector2, scale_value := 1.0, mod := Color.WHITE, rotation_value := 0.0) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = texture
	s.position = pos
	s.scale = Vector2.ONE * scale_value
	s.modulate = mod
	s.rotation = rotation_value
	add_child(s)
	return s

func _patch(points: PackedVector2Array, color: Color) -> void:
	var p := Polygon2D.new()
	p.polygon = points
	p.color = color
	add_child(p)

func _add_ground_layers() -> void:
	var normal_detail := [
		[Vector2(180, 300), 0.62, -0.08], [Vector2(410, 405), 0.78, 0.05],
		[Vector2(650, 310), 0.58, -0.03], [Vector2(230, 700), 0.70, 0.06],
		[Vector2(505, 825), 0.82, -0.05], [Vector2(720, 1080), 0.62, 0.08],
		[Vector2(1250, 350), 0.55, -0.04], [Vector2(1320, 1080), 0.60, 0.05]
	]
	for data in normal_detail:
		_sprite(GROUND_DETAIL, data[0], data[1], Color(0.82, 0.88, 0.72, 0.72), data[2])
	var sick_detail := [
		[Vector2(1450, 380), 0.62, 0.04], [Vector2(1510, 610), 0.72, -0.06],
		[Vector2(1580, 875), 0.66, 0.07], [Vector2(1740, 990), 0.58, -0.03]
	]
	for data in sick_detail:
		_sprite(GROUND_DETAIL, data[0], data[1], Color(0.50, 0.48, 0.42, 0.58), data[2])

func _embedded_stone(pos: Vector2, size: Vector2, rotation_value: float, stone_color: Color) -> void:
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([Vector2(-0.52,-0.25),Vector2(-0.24,-0.50),Vector2(0.24,-0.47),Vector2(0.53,-0.16),Vector2(0.43,0.30),Vector2(0.08,0.49),Vector2(-0.38,0.35)])
	shadow.position = pos + Vector2(1.0, 1.5)
	shadow.scale = size
	shadow.rotation = rotation_value
	shadow.color = Color(0.07, 0.06, 0.05, 0.16)
	add_child(shadow)
	var stone := Polygon2D.new()
	stone.polygon = PackedVector2Array([Vector2(-0.52,-0.28),Vector2(-0.25,-0.50),Vector2(0.23,-0.46),Vector2(0.52,-0.14),Vector2(0.41,0.28),Vector2(0.07,0.47),Vector2(-0.39,0.33)])
	stone.position = pos
	stone.scale = size
	stone.rotation = rotation_value
	stone.color = stone_color
	add_child(stone)

func _add_road_wear() -> void:
	var patches := [
		[PackedVector2Array([Vector2(928,250),Vector2(1018,238),Vector2(1042,325),Vector2(947,344)]), Color(0.18,0.12,0.08,0.10)],
		[PackedVector2Array([Vector2(934,500),Vector2(1024,486),Vector2(1055,590),Vector2(945,612)]), Color(0.12,0.09,0.07,0.09)],
		[PackedVector2Array([Vector2(920,665),Vector2(1040,650),Vector2(1060,740),Vector2(925,755)]), Color(0.22,0.16,0.10,0.09)],
		[PackedVector2Array([Vector2(725,718),Vector2(905,715),Vector2(912,802),Vector2(735,810)]), Color(0.16,0.11,0.08,0.08)],
		[PackedVector2Array([Vector2(1090,713),Vector2(1320,705),Vector2(1328,790),Vector2(1098,798)]), Color(0.14,0.10,0.07,0.08)],
		[PackedVector2Array([Vector2(936,980),Vector2(1030,968),Vector2(1050,1080),Vector2(942,1092)]), Color(0.18,0.12,0.08,0.09)]
	]
	for data in patches:
		_patch(data[0], data[1])
	for data in [[PackedVector2Array([Vector2(954,0),Vector2(962,260),Vector2(956,520),Vector2(966,790),Vector2(958,1060),Vector2(968,1536)]),2.0,Color(0.10,0.07,0.05,0.12)],[PackedVector2Array([Vector2(1010,0),Vector2(1004,270),Vector2(1014,540),Vector2(1006,795),Vector2(1018,1070),Vector2(1010,1536)]),2.0,Color(0.10,0.07,0.05,0.10)]]:
		var line := Line2D.new()
		line.points = data[0]
		line.width = data[1]
		line.default_color = data[2]
		add_child(line)

func _add_cobbles() -> void:
	var stones := [
		[Vector2(956,130),Vector2(14,8),-0.18],[Vector2(989,145),Vector2(12,8),0.10],[Vector2(1007,232),Vector2(15,8),-0.12],
		[Vector2(950,330),Vector2(13,8),0.08],[Vector2(986,350),Vector2(15,9),-0.04],[Vector2(1004,466),Vector2(14,8),0.05],
		[Vector2(948,555),Vector2(13,8),0.11],[Vector2(987,574),Vector2(12,7),-0.08],[Vector2(957,665),Vector2(12,7),-0.04],
		[Vector2(995,688),Vector2(14,8),0.12],[Vector2(926,744),Vector2(13,8),0.06],[Vector2(966,760),Vector2(15,9),-0.10],
		[Vector2(1009,742),Vector2(12,8),0.15],[Vector2(1044,773),Vector2(14,8),-0.02],[Vector2(838,768),Vector2(12,7),-0.14],
		[Vector2(751,749),Vector2(10,6),0.09],[Vector2(1180,766),Vector2(12,7),-0.06],[Vector2(1285,748),Vector2(10,6),0.12],
		[Vector2(958,860),Vector2(12,7),0.10],[Vector2(1000,884),Vector2(14,8),-0.05],[Vector2(970,1012),Vector2(13,8),-0.11],
		[Vector2(1008,1146),Vector2(13,8),-0.15],[Vector2(974,1272),Vector2(12,7),0.12]
	]
	for data in stones:
		_embedded_stone(data[0], data[1], data[2], Color(0.25, 0.25, 0.22, 0.44))

func _add_boundaries() -> void:
	for data in [
		[Vector2(570,620),0.48,-0.08,Color(0.82,0.78,0.68,0.82)],
		[Vector2(1325,610),0.44,0.07,Color(0.68,0.64,0.56,0.72)],
		[Vector2(520,1010),0.42,0.05,Color(0.72,0.70,0.62,0.72)],
		[Vector2(1420,1040),0.40,-0.06,Color(0.48,0.43,0.42,0.62)]
	]:
		var fence := _sprite(FENCE, data[0], data[1], data[3], data[2])
		fence.z_index = 1

func _add_road_edge_growth() -> void:
	var edge_growth := [[Vector2(900,315),0.22],[Vector2(1070,405),0.18],[Vector2(895,590),0.20],[Vector2(1080,625),0.16],[Vector2(888,930),0.20],[Vector2(1082,1035),0.18],[Vector2(530,680),0.18],[Vector2(700,820),0.16],[Vector2(1260,680),0.17],[Vector2(1440,825),0.15],[Vector2(1640,690),0.14]]
	for data in edge_growth:
		_sprite(FOLIAGE, data[0], data[1], Color(0.52,0.62,0.47,0.50))

func _add_foliage() -> void:
	var spots := [
		[Vector2(170,430),0.72],[Vector2(365,500),0.86],[Vector2(590,610),0.66],[Vector2(245,950),0.90],
		[Vector2(490,1040),0.72],[Vector2(700,925),0.62],[Vector2(1260,1030),0.70],[Vector2(1450,930),0.58],
		[Vector2(1320,570),0.54],[Vector2(1185,420),0.40],[Vector2(1240,530),0.34],[Vector2(1170,610),0.28]
	]
	for data in spots:
		_sprite(FOLIAGE, data[0], data[1], Color(0.76,0.86,0.70,0.82))

func _add_roadside_props() -> void:
	for data in [[Vector2(835,360),0.66],[Vector2(1135,510),0.56],[Vector2(830,1120),0.60],[Vector2(1160,1240),0.66]]:
		_sprite(PINE, data[0], data[1])
	for data in [[Vector2(785,690),0.64],[Vector2(1190,850),0.54],[Vector2(1380,650),0.48],[Vector2(1515,870),0.36]]:
		_sprite(STONE, data[0], data[1], Color(0.76,0.78,0.72,0.88))
	for pos in [Vector2(865,690),Vector2(1115,690),Vector2(865,875),Vector2(1115,875)]:
		var lantern := _sprite(LANTERN, pos, 0.53, Color(0.88,0.83,0.70,0.78))
		lantern.z_index = 2

func _add_roadside_story_props() -> void:
	for data in [
		[Vector2(670,780),0.44,-0.04,Color(0.86,0.80,0.68,0.88)],
		[Vector2(1280,910),0.40,0.05,Color(0.74,0.68,0.58,0.82)]
	]:
		var clutter := _sprite(ROADSIDE_CLUTTER, data[0], data[1], data[3], data[2])
		clutter.z_index = 2

func _add_corruption_transition() -> void:
	for data in [
		[Vector2(1365,430),0.48,Color(0.48,0.50,0.42,0.66)],[Vector2(1465,380),0.44,Color(0.43,0.42,0.38,0.62)],
		[Vector2(1515,650),0.40,Color(0.42,0.35,0.40,0.60)],[Vector2(1590,720),0.38,Color(0.48,0.30,0.45,0.58)],
		[Vector2(1670,670),0.34,Color(0.52,0.27,0.48,0.52)],[Vector2(1740,735),0.28,Color(0.56,0.23,0.50,0.46)]
	]:
		_sprite(FOLIAGE, data[0], data[1], data[2])
	for data in [
		[Vector2(1505,525),0.58,-0.16,Color(0.72,0.52,0.72,0.58)],
		[Vector2(1630,650),0.72,0.10,Color(0.88,0.62,0.90,0.72)],
		[Vector2(1740,790),0.86,-0.08,Color(1.0,0.72,1.0,0.84)],
		[Vector2(1810,960),0.74,0.16,Color(0.90,0.58,0.92,0.76)]
	]:
		var growth := _sprite(CORRUPT_GROWTH, data[0], data[1], data[3], data[2])
		growth.z_index = 1

func _add_foreground_frame() -> void:
	# Larger edge silhouettes create foreground depth without covering the central playable space.
	for data in [
		[Vector2(85,1390),1.48,-0.04,Color(0.70,0.78,0.70,0.90)],
		[Vector2(260,1460),1.15,0.02,Color(0.66,0.74,0.66,0.86)],
		[Vector2(1890,1410),1.52,0.04,Color(0.48,0.50,0.47,0.82)],
		[Vector2(2020,1320),1.18,-0.03,Color(0.43,0.44,0.42,0.80)]
	]:
		var tree := _sprite(PINE, data[0], data[1], data[3], data[2])
		tree.z_index = 4
