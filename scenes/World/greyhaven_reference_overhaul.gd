extends Node2D

const PINE := preload("res://assets/art/world/greyhaven_pine.svg")
const STONE := preload("res://assets/art/world/greyhaven_stone.svg")
const FOLIAGE := preload("res://assets/art/world/greyhaven_foliage_cluster.svg")
const FLOWERS := preload("res://assets/art/world/greyhaven_flower_bed.svg")
const FENCE := preload("res://assets/art/world/greyhaven_fence.svg")
const WALL := preload("res://assets/art/world/greyhaven_mossy_wall.svg")
const LANTERN := preload("res://assets/art/world/greyhaven_lantern.svg")
const CORRUPT := preload("res://assets/art/world/greyhaven_corrupt_growth.svg")
const CHAPEL := preload("res://assets/art/world/greyhaven_ruined_chapel.svg")
const BOARD := preload("res://assets/art/world/greyhaven_notice_board.svg")

func _ready() -> void:
	z_index = 0
	_add_road_shoulders()
	_add_dense_verges()
	_add_east_corruption()
	_add_landmarks()
	_add_foreground()

func _sprite(tex: Texture2D, pos: Vector2, sc: float, tint := Color.WHITE, rot := 0.0, zoff := 0) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.position = pos
	s.scale = Vector2.ONE * sc
	s.modulate = tint
	s.rotation = rot
	s.z_index = clampi(int(pos.y) + zoff, 0, 2000)
	add_child(s)
	return s

func _patch(points: PackedVector2Array, color: Color, z := -2) -> void:
	var p := Polygon2D.new()
	p.polygon = points
	p.color = color
	p.z_index = z
	add_child(p)

func _ellipse(c: Vector2, r: Vector2, color: Color, z := -1, n := 28) -> void:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := TAU * float(i) / float(n)
		pts.append(c + Vector2(cos(a) * r.x, sin(a) * r.y))
	_patch(pts, color, z)

func _add_road_shoulders() -> void:
	# Broad irregular shoulders visually narrow the old road and create a hand-built woodland lane.
	_patch(PackedVector2Array([Vector2(0,650),Vector2(210,640),Vector2(390,660),Vector2(570,646),Vector2(745,670),Vector2(855,690),Vector2(905,725),Vector2(892,805),Vector2(810,835),Vector2(650,824),Vector2(470,842),Vector2(280,825),Vector2(110,842),Vector2(0,828)]),Color(0.075,0.105,0.066,0.76),-4)
	_patch(PackedVector2Array([Vector2(1090,690),Vector2(1210,665),Vector2(1390,650),Vector2(1570,668),Vector2(1740,646),Vector2(1900,660),Vector2(2048,650),Vector2(2048,830),Vector2(1880,820),Vector2(1700,838),Vector2(1515,820),Vector2(1340,842),Vector2(1185,825),Vector2(1100,804)]),Color(0.067,0.092,0.063,0.76),-4)
	_patch(PackedVector2Array([Vector2(842,0),Vector2(925,0),Vector2(920,165),Vector2(904,315),Vector2(916,455),Vector2(900,610),Vector2(874,690),Vector2(810,674),Vector2(792,590),Vector2(806,450),Vector2(790,300),Vector2(812,145)]),Color(0.072,0.103,0.065,0.78),-4)
	_patch(PackedVector2Array([Vector2(1055,0),Vector2(1140,0),Vector2(1160,160),Vector2(1142,315),Vector2(1155,465),Vector2(1138,610),Vector2(1100,700),Vector2(1048,680),Vector2(1065,590),Vector2(1050,455),Vector2(1066,300),Vector2(1048,150)]),Color(0.065,0.092,0.061,0.78),-4)
	# Warm soil and embedded-stone ribbons soften the remaining road center.
	for c in [Vector2(975,180),Vector2(985,330),Vector2(970,500),Vector2(980,650),Vector2(980,805),Vector2(975,980),Vector2(980,1180)]:
		_ellipse(c,Vector2(62,105),Color(0.25,0.18,0.105,0.075),-3)
	for c in [Vector2(770,760),Vector2(1210,770),Vector2(570,765),Vector2(1410,760)]:
		_ellipse(c,Vector2(100,48),Color(0.24,0.17,0.10,0.06),-3)

func _add_dense_verges() -> void:
	var foliage_data := [
		[Vector2(690,625),.55],[Vector2(755,660),.42],[Vector2(820,620),.38],[Vector2(1165,625),.43],[Vector2(1230,655),.50],[Vector2(1310,620),.40],
		[Vector2(690,870),.48],[Vector2(770,900),.36],[Vector2(1190,875),.46],[Vector2(1280,900),.38],[Vector2(850,390),.34],[Vector2(1140,410),.36]
	]
	for d in foliage_data:
		_sprite(FOLIAGE,d[0],d[1],Color(0.70,0.79,0.62,0.88),0.0,4)
	for d in [[Vector2(730,650),.30],[Vector2(1260,640),.30],[Vector2(735,885),.29],[Vector2(1240,890),.28],[Vector2(850,530),.25],[Vector2(1135,545),.25]]:
		_sprite(FLOWERS,d[0],d[1],Color(0.91,0.84,0.68,0.88),0.0,6)
	for d in [[Vector2(790,610),.16],[Vector2(1185,610),.17],[Vector2(815,875),.15],[Vector2(1160,875),.15]]:
		_sprite(STONE,d[0],d[1],Color(0.72,0.72,0.65,0.76),0.0,2)

func _add_east_corruption() -> void:
	# Dark dead-soil mass and layered violet growth create a clear healthy-to-corrupt transition.
	_patch(PackedVector2Array([Vector2(1330,180),Vector2(1510,120),Vector2(1710,155),Vector2(1880,110),Vector2(2048,145),Vector2(2048,1110),Vector2(1880,1070),Vector2(1710,1110),Vector2(1535,1050),Vector2(1430,930),Vector2(1375,760),Vector2(1400,610),Vector2(1345,440)]),Color(0.055,0.045,0.057,0.72),-3)
	for d in [[Vector2(1540,330),.65,-.12],[Vector2(1720,510),.78,.08],[Vector2(1575,700),.60,.05],[Vector2(1810,790),.82,-.06],[Vector2(1660,950),.68,.10]]:
		_sprite(CORRUPT,d[0],d[1],Color(0.73,0.38,0.88,0.72),d[2],3)
	for d in [[Vector2(1460,520),.34],[Vector2(1515,850),.30],[Vector2(1860,610),.32],[Vector2(1760,1000),.28]]:
		_sprite(FLOWERS,d[0],d[1],Color(0.58,0.34,0.68,0.70),0.0,4)

func _add_landmarks() -> void:
	# The board creates the strong central-right silhouette of the target composition.
	_sprite(BOARD,Vector2(1215,690),.52,Color(0.92,0.88,0.77,1.0),0.0,70)
	_ellipse(Vector2(1215,745),Vector2(58,20),Color(0.02,0.025,0.02,0.22),-1)
	# Ruined chapel anchors the corrupted eastern third.
	_sprite(CHAPEL,Vector2(1740,540),.74,Color(0.78,0.77,0.75,0.96),0.015,75)
	_ellipse(Vector2(1740,700),Vector2(145,34),Color(0.01,0.01,0.015,0.35),-1)
	for d in [[Vector2(1480,650),.34,-.05],[Vector2(1370,760),.31,.04],[Vector2(1520,850),.30,-.03]]:
		_sprite(FENCE,d[0],d[1],Color(0.57,0.49,0.39,0.78),d[2],4)
	for d in [[Vector2(1430,590),.30,-.03],[Vector2(1470,920),.27,.04]]:
		_sprite(WALL,d[0],d[1],Color(0.48,0.48,0.43,0.74),d[2],3)
	# Additional warm pools lead the eye through the healthy road.
	for d in [[Vector2(860,570),.50],[Vector2(1080,360),.43],[Vector2(900,950),.48]]:
		_ellipse(d[0]+Vector2(0,28),Vector2(58,26),Color(1.0,0.61,0.24,0.07),-1)
		_sprite(LANTERN,d[0],d[1],Color(1.0,0.91,0.70,0.98),0.0,40)

func _add_foreground() -> void:
	# Large dark silhouettes at the bottom corners frame the playable road like the reference.
	for d in [[Vector2(160,1210),1.55,-.04],[Vector2(360,1270),1.28,.03],[Vector2(1810,1230),1.52,.04],[Vector2(1970,1290),1.30,-.03]]:
		_sprite(PINE,d[0],d[1],Color(0.28,0.40,0.31,0.94),d[2],280)
	for d in [[Vector2(90,1070),.72],[Vector2(250,1090),.62],[Vector2(1870,1080),.70],[Vector2(1990,1040),.58]]:
		_sprite(FOLIAGE,d[0],d[1],Color(0.43,0.56,0.42,0.80),0.0,20)
