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
	_add_organic_verges()
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

func _add_organic_verges() -> void:
	# Organic dark-green beds replace the old giant geometric forest wedges and leave
	# the central route visually open.
	_patch(PackedVector2Array([Vector2(0,560),Vector2(180,525),Vector2(350,548),Vector2(520,530),Vector2(690,555),Vector2(815,610),Vector2(835,690),Vector2(790,745),Vector2(620,725),Vector2(430,750),Vector2(225,730),Vector2(0,755)]),Color(0.055,0.086,0.058,0.58),-4)
	_patch(PackedVector2Array([Vector2(1165,545),Vector2(1290,520),Vector2(1420,540),Vector2(1540,520),Vector2(1650,545),Vector2(1770,530),Vector2(1900,555),Vector2(2048,535),Vector2(2048,790),Vector2(1870,775),Vector2(1700,795),Vector2(1535,770),Vector2(1390,790),Vector2(1240,760),Vector2(1175,700)]),Color(0.048,0.074,0.052,0.60),-4)
	for c in [Vector2(900,390),Vector2(955,515),Vector2(985,650),Vector2(1000,805),Vector2(985,970),Vector2(975,1140)]:
		_ellipse(c,Vector2(78,100),Color(0.34,0.245,0.145,0.07),-3)

func _add_east_corruption() -> void:
	# Localized dead soil hugs the chapel instead of covering the entire eastern screen.
	_patch(PackedVector2Array([Vector2(1450,270),Vector2(1540,220),Vector2(1660,235),Vector2(1780,210),Vector2(1905,250),Vector2(1980,350),Vector2(1960,520),Vector2(2000,650),Vector2(1940,805),Vector2(1830,860),Vector2(1695,835),Vector2(1580,865),Vector2(1490,790),Vector2(1440,675),Vector2(1465,555),Vector2(1425,430)]),Color(0.045,0.038,0.048,0.72),-3)
	for d in [[Vector2(1530,390),.36,-.10],[Vector2(1785,455),.40,.06],[Vector2(1595,650),.34,.04],[Vector2(1840,710),.42,-.05],[Vector2(1710,805),.32,.08]]:
		_sprite(CORRUPT,d[0],d[1],Color(0.67,0.30,0.79,0.64),d[2],3)
	for d in [[Vector2(1485,575),.25],[Vector2(1570,780),.23],[Vector2(1880,610),.24],[Vector2(1790,825),.22]]:
		_sprite(FLOWERS,d[0],d[1],Color(0.55,0.31,0.64,0.68),0.0,4)

func _add_landmarks() -> void:
	# Board scale is our prop anchor; chapel is deliberately much smaller than the old pass.
	_sprite(BOARD,Vector2(1260,650),.43,Color(0.92,0.88,0.77,1.0),0.0,55)
	_ellipse(Vector2(1260,704),Vector2(48,16),Color(0.02,0.025,0.02,0.22),-1)

	_sprite(CHAPEL,Vector2(1715,480),.38,Color(0.72,0.72,0.70,0.96),0.01,58)
	_ellipse(Vector2(1715,575),Vector2(82,22),Color(0.01,0.01,0.015,0.34),-1)

	# Broken masonry/fence fragments make the chapel feel embedded in a ruined site.
	for d in [[Vector2(1510,565),.27,-.05],[Vector2(1435,690),.24,.04],[Vector2(1880,650),.25,-.03]]:
		_sprite(FENCE,d[0],d[1],Color(0.50,0.43,0.35,0.75),d[2],4)
	for d in [[Vector2(1490,510),.25,-.03],[Vector2(1850,735),.23,.04]]:
		_sprite(WALL,d[0],d[1],Color(0.45,0.45,0.41,0.74),d[2],3)
	for d in [[Vector2(1470,610),.14],[Vector2(1900,570),.13],[Vector2(1830,780),.12]]:
		_sprite(STONE,d[0],d[1],Color(0.62,0.62,0.59,0.74),0.0,2)

	# Warm lights mark the safe route and contrast with the eastern violet corruption.
	for d in [[Vector2(860,590),.44],[Vector2(1085,405),.39],[Vector2(920,930),.42]]:
		_ellipse(d[0]+Vector2(0,28),Vector2(52,23),Color(1.0,0.61,0.24,0.07),-1)
		_sprite(LANTERN,d[0],d[1],Color(1.0,0.91,0.70,0.98),0.0,40)

func _add_foreground() -> void:
	# Dense edge clusters frame the route without filling the player's corridor.
	for d in [[Vector2(700,620),.46],[Vector2(760,675),.34],[Vector2(1210,575),.36],[Vector2(1320,720),.40],[Vector2(720,880),.40],[Vector2(1260,920),.36]]:
		_sprite(FOLIAGE,d[0],d[1],Color(0.67,0.76,0.62,0.82),0.0,4)
	for d in [[Vector2(735,650),.25],[Vector2(1290,690),.24],[Vector2(755,900),.22],[Vector2(1235,895),.22]]:
		_sprite(FLOWERS,d[0],d[1],Color(0.86,0.81,0.66,0.84),0.0,6)

	for d in [[Vector2(125,1190),1.22,-.04],[Vector2(330,1270),1.08,.03],[Vector2(1815,1210),1.20,.04],[Vector2(1990,1275),1.06,-.03]]:
		_sprite(PINE,d[0],d[1],Color(0.25,0.36,0.28,0.94),d[2],260)
