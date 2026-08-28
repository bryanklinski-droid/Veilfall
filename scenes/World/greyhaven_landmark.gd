extends Node2D

const HOUSE := preload("res://assets/art/world/greyhaven_house.svg")
const PINE := preload("res://assets/art/world/greyhaven_pine.svg")
const FOLIAGE := preload("res://assets/art/world/greyhaven_foliage_cluster.svg")
const FLOWER_BED := preload("res://assets/art/world/greyhaven_flower_bed.svg")
const MOSSY_WALL := preload("res://assets/art/world/greyhaven_mossy_wall.svg")
const FENCE := preload("res://assets/art/world/greyhaven_fence.svg")
const LANTERN := preload("res://assets/art/world/greyhaven_lantern.svg")
const STONE := preload("res://assets/art/world/greyhaven_stone.svg")
const ROADSIDE_CLUTTER := preload("res://assets/art/world/greyhaven_roadside_clutter.svg")

func _ready() -> void:
	z_index = 0
	_add_house_composition()
	_add_intersection_light_pools()
	_add_roadside_clusters()

func _depth_for(pos: Vector2, offset := 0) -> int:
	return clampi(int(pos.y) + offset, 0, 2000)

func _sprite(texture: Texture2D, pos: Vector2, scale_value: float, modulate_color := Color.WHITE, rotation_value := 0.0, depth_offset := 0) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = Vector2.ONE * scale_value
	sprite.modulate = modulate_color
	sprite.rotation = rotation_value
	sprite.z_index = _depth_for(pos, depth_offset)
	add_child(sprite)
	return sprite

func _patch(points: PackedVector2Array, color: Color, patch_z := 0) -> void:
	var patch := Polygon2D.new()
	patch.polygon = points
	patch.color = color
	patch.z_index = patch_z
	add_child(patch)

func _ellipse(center: Vector2, radius: Vector2, color: Color, ellipse_z := 0, segments := 30) -> void:
	var points := PackedVector2Array()
	for i in range(segments):
		var angle := TAU * float(i) / float(segments)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	_patch(points, color, ellipse_z)

func _add_static_box(name_value: String, pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = name_value
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)

func _add_static_circle(name_value: String, pos: Vector2, radius: float) -> void:
	var body := StaticBody2D.new()
	body.name = name_value
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	body.add_child(shape)
	add_child(body)

func _add_house_composition() -> void:
	# Layered, irregular floor tones blend the cottage clearing into the surrounding forest.
	_patch(PackedVector2Array([
		Vector2(245,265),Vector2(325,226),Vector2(420,238),Vector2(500,216),Vector2(590,232),Vector2(680,215),Vector2(780,250),
		Vector2(842,315),Vector2(852,400),Vector2(825,475),Vector2(785,535),Vector2(700,575),Vector2(615,585),Vector2(535,572),
		Vector2(455,592),Vector2(370,570),Vector2(300,525),Vector2(255,455),Vector2(235,365)
	]), Color(0.052,0.073,0.054,0.34), -7)
	_patch(PackedVector2Array([
		Vector2(292,420),Vector2(365,397),Vector2(435,412),Vector2(500,398),Vector2(565,410),Vector2(635,397),Vector2(710,415),Vector2(785,452),
		Vector2(802,510),Vector2(770,555),Vector2(700,588),Vector2(620,600),Vector2(555,590),Vector2(490,608),Vector2(420,594),Vector2(350,565),Vector2(305,510)
	]), Color(0.145,0.115,0.077,0.15), -6)
	_patch(PackedVector2Array([
		Vector2(278,505),Vector2(345,488),Vector2(408,500),Vector2(466,488),Vector2(520,500),Vector2(565,492),Vector2(620,500),Vector2(680,493),
		Vector2(742,507),Vector2(790,532),Vector2(770,566),Vector2(706,580),Vector2(650,570),Vector2(590,582),Vector2(530,570),Vector2(468,583),
		Vector2(405,570),Vector2(342,580),Vector2(292,555)
	]), Color(0.23,0.17,0.105,0.10), -5)

	# A narrow worn approach replaces the old hard geometric/V-shaped path language.
	_patch(PackedVector2Array([
		Vector2(523,494),Vector2(590,494),Vector2(594,530),Vector2(582,562),Vector2(592,596),Vector2(610,632),Vector2(607,668),
		Vector2(585,697),Vector2(551,707),Vector2(518,695),Vector2(501,668),Vector2(505,632),Vector2(520,596),Vector2(512,560),Vector2(516,528)
	]), Color(0.29,0.215,0.14,0.27), -4)
	_patch(PackedVector2Array([
		Vector2(539,501),Vector2(576,501),Vector2(578,536),Vector2(568,565),Vector2(576,600),Vector2(592,635),Vector2(587,666),
		Vector2(568,687),Vector2(544,690),Vector2(525,675),Vector2(520,648),Vector2(532,607),Vector2(527,570),Vector2(532,536)
	]), Color(0.43,0.33,0.22,0.12), -3)

	# Soft contact shadows visually seat the building, walls, and garden beds into the soil.
	_ellipse(Vector2(555,503), Vector2(188,34), Color(0.015,0.022,0.016,0.24), -2, 36)
	_ellipse(Vector2(403,565), Vector2(94,19), Color(0.02,0.026,0.019,0.16), -2)
	_ellipse(Vector2(704,573), Vector2(87,18), Color(0.02,0.026,0.019,0.15), -2)
	_ellipse(Vector2(334,625), Vector2(103,15), Color(0.02,0.026,0.019,0.13), -2)
	_ellipse(Vector2(766,642), Vector2(91,14), Color(0.02,0.026,0.019,0.12), -2)

	# Sparse leaf-litter/soil tongues break the flat green field without filling the walkable center.
	for patch_data in [
		[PackedVector2Array([Vector2(290,540),Vector2(338,523),Vector2(370,540),Vector2(356,562),Vector2(310,568)]),Color(0.19,0.14,0.085,0.12)],
		[PackedVector2Array([Vector2(430,615),Vector2(470,602),Vector2(497,616),Vector2(485,635),Vector2(443,638)]),Color(0.18,0.13,0.08,0.10)],
		[PackedVector2Array([Vector2(676,607),Vector2(719,595),Vector2(752,610),Vector2(738,632),Vector2(693,634)]),Color(0.18,0.13,0.08,0.10)],
		[PackedVector2Array([Vector2(758,548),Vector2(805,536),Vector2(831,553),Vector2(812,575),Vector2(770,574)]),Color(0.19,0.14,0.085,0.11)]
	]:
		_patch(patch_data[0], patch_data[1], -3)

	for stone_data in [
		[Vector2(550,544),0.105,-0.10],[Vector2(575,576),0.075,0.08],[Vector2(535,616),0.08,0.04],
		[Vector2(586,649),0.065,-0.06],[Vector2(554,684),0.065,0.05],[Vector2(764,566),0.105,-0.08]
	]:
		_sprite(STONE, stone_data[0], stone_data[1], Color(0.76,0.77,0.70,0.48), stone_data[2], -2)

	# Trees frame rather than intersect the cottage.
	_sprite(PINE, Vector2(270,330), 1.18, Color(0.70,0.80,0.70,0.96), -0.04, 55)
	_sprite(PINE, Vector2(825,320), 1.05, Color(0.66,0.76,0.67,0.94), 0.04, 50)
	_sprite(PINE, Vector2(245,470), 0.82, Color(0.58,0.69,0.61,0.92), 0.03, 38)
	_sprite(HOUSE, Vector2(555,405), 1.18, Color(0.92,0.94,0.90,1.0), 0.0, 112)

	# Short, separated wall remnants avoid the old horizontal barricade look.
	_sprite(MOSSY_WALL, Vector2(392,560), 0.43, Color(0.72,0.75,0.66,0.82), -0.035, 5)
	_sprite(MOSSY_WALL, Vector2(704,568), 0.38, Color(0.69,0.73,0.64,0.79), 0.045, 5)

	# Beds overlap the masonry so its bases disappear naturally into growth.
	_sprite(FOLIAGE, Vector2(315,526), 0.70, Color(0.72,0.80,0.67,0.87), -0.05, 4)
	_sprite(FLOWER_BED, Vector2(365,573), 0.48, Color(0.88,0.85,0.69,0.88), -0.035, 8)
	_sprite(FOLIAGE, Vector2(424,584), 0.34, Color(0.68,0.76,0.63,0.76), 0.055, 6)
	_sprite(FOLIAGE, Vector2(752,526), 0.62, Color(0.69,0.78,0.64,0.84), 0.05, 5)
	_sprite(FLOWER_BED, Vector2(724,584), 0.41, Color(0.81,0.79,0.65,0.84), -0.045, 8)
	_sprite(FOLIAGE, Vector2(784,601), 0.31, Color(0.66,0.74,0.60,0.70), 0.06, 7)

	# Fence fragments are smaller, offset, and partially swallowed by plants.
	_sprite(FENCE, Vector2(298,623), 0.35, Color(0.68,0.62,0.51,0.73), -0.07, 5)
	_sprite(FENCE, Vector2(367,638), 0.25, Color(0.64,0.59,0.49,0.63), 0.04, 5)
	_sprite(FENCE, Vector2(742,638), 0.27, Color(0.64,0.59,0.49,0.66), -0.045, 5)
	_sprite(FENCE, Vector2(795,647), 0.19, Color(0.60,0.56,0.47,0.58), 0.035, 5)
	_sprite(FOLIAGE, Vector2(320,642), 0.24, Color(0.62,0.71,0.58,0.60), 0.02, 8)
	_sprite(FOLIAGE, Vector2(765,653), 0.22, Color(0.61,0.70,0.57,0.58), -0.02, 8)

	# Story props and warm light remain one compact working corner.
	_sprite(ROADSIDE_CLUTTER, Vector2(770,582), 0.41, Color(0.88,0.80,0.67,0.91), 0.02, 8)
	_sprite(STONE, Vector2(824,612), 0.20, Color(0.78,0.80,0.75,0.69), -0.04, 3)
	_ellipse(Vector2(815,590), Vector2(82,34), Color(0.95,0.58,0.25,0.07), -1)
	_ellipse(Vector2(815,590), Vector2(42,20), Color(1.0,0.72,0.36,0.06), -1)
	_sprite(LANTERN, Vector2(810,535), 0.58, Color(1.0,0.90,0.72,0.98), 0.0, 45)

	# Fine edge growth keeps the open approach readable while breaking up bare ground.
	_sprite(FOLIAGE, Vector2(468,648), 0.19, Color(0.64,0.72,0.59,0.49), -0.03, 1)
	_sprite(FLOWER_BED, Vector2(646,660), 0.16, Color(0.73,0.72,0.58,0.45), 0.04, 1)
	_sprite(FOLIAGE, Vector2(508,699), 0.13, Color(0.59,0.68,0.55,0.42), 0.02, 1)
	_sprite(FOLIAGE, Vector2(612,697), 0.12, Color(0.59,0.68,0.55,0.40), -0.02, 1)

	# Keep the collision setup conservative and aligned to the tested visual objects.
	_add_static_box("HouseCollision", Vector2(555,466), Vector2(286,70))
	_add_static_box("LeftFoundationWallCollision", Vector2(392,562), Vector2(98,20))
	_add_static_box("RightFoundationWallCollision", Vector2(704,570), Vector2(88,20))
	_add_static_box("FenceCollision", Vector2(312,628), Vector2(88,16))
	_add_static_box("ClutterCollision", Vector2(770,590), Vector2(62,30))
	_add_static_circle("LanternCollision", Vector2(810,572), 13.0)

func _add_intersection_light_pools() -> void:
	for center in [Vector2(865,718),Vector2(1115,718),Vector2(865,902),Vector2(1115,902)]:
		_ellipse(center, Vector2(82,34), Color(0.96,0.58,0.24,0.055), -1)
		_ellipse(center, Vector2(42,20), Color(1.0,0.72,0.35,0.050), -1)

func _add_roadside_clusters() -> void:
	for data in [
		[Vector2(760,682),0.45,-0.05],[Vector2(812,660),0.36,0.04],
		[Vector2(1190,675),0.42,0.03],[Vector2(1245,700),0.34,-0.05],
		[Vector2(785,865),0.42,0.05],[Vector2(1218,872),0.38,-0.04]
	]:
		_sprite(FOLIAGE, data[0], data[1], Color(0.72,0.80,0.66,0.72), data[2], 3)
	for data in [
		[Vector2(790,706),0.30,-0.04],[Vector2(1220,720),0.28,0.03],
		[Vector2(805,892),0.27,0.04],[Vector2(1200,900),0.25,-0.03]
	]:
		_sprite(FLOWER_BED, data[0], data[1], Color(0.82,0.80,0.65,0.70), data[2], 4)
