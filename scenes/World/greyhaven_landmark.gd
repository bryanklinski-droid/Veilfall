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
	# Irregular clearing and leaf litter keep the cottage embedded in the forest.
	_patch(PackedVector2Array([
		Vector2(250,250),Vector2(350,215),Vector2(485,222),Vector2(645,205),Vector2(790,245),
		Vector2(850,330),Vector2(830,470),Vector2(772,565),Vector2(650,610),Vector2(505,605),
		Vector2(360,565),Vector2(275,485),Vector2(238,350)
	]), Color(0.055,0.075,0.055,0.40), -5)
	_patch(PackedVector2Array([
		Vector2(360,470),Vector2(440,444),Vector2(550,450),Vector2(665,458),Vector2(760,500),
		Vector2(790,555),Vector2(735,615),Vector2(640,628),Vector2(555,615),Vector2(470,630),
		Vector2(385,610),Vector2(335,550)
	]), Color(0.17,0.125,0.082,0.20), -4)

	# Worn footpath widens toward the road and narrows naturally at the doorstep.
	_patch(PackedVector2Array([
		Vector2(520,500),Vector2(594,500),Vector2(604,536),Vector2(594,570),Vector2(606,608),
		Vector2(632,650),Vector2(618,690),Vector2(584,710),Vector2(540,706),Vector2(505,688),
		Vector2(494,652),Vector2(516,607),Vector2(510,568),Vector2(500,535)
	]), Color(0.30,0.225,0.15,0.34), -3)
	_patch(PackedVector2Array([
		Vector2(538,508),Vector2(580,508),Vector2(585,543),Vector2(574,575),Vector2(585,612),
		Vector2(604,655),Vector2(590,682),Vector2(558,691),Vector2(530,680),Vector2(524,650),
		Vector2(538,608),Vector2(530,570)
	]), Color(0.43,0.34,0.23,0.16), -2)

	_ellipse(Vector2(555,505), Vector2(190,38), Color(0.02,0.025,0.02,0.28), -2, 36)

	# Embedded stones stay sparse and irregular.
	for stone_data in [
		[Vector2(548,544),0.12,-0.10],[Vector2(578,574),0.09,0.08],[Vector2(538,615),0.10,0.04],
		[Vector2(588,648),0.08,-0.06],[Vector2(553,684),0.08,0.05],[Vector2(765,565),0.14,-0.08]
	]:
		_sprite(STONE, stone_data[0], stone_data[1], Color(0.82,0.82,0.76,0.62), stone_data[2], -2)

	# Trees frame rather than intersect the cottage.
	_sprite(PINE, Vector2(270,330), 1.18, Color(0.70,0.80,0.70,0.96), -0.04, 55)
	_sprite(PINE, Vector2(825,320), 1.05, Color(0.66,0.76,0.67,0.94), 0.04, 50)
	_sprite(PINE, Vector2(245,470), 0.82, Color(0.58,0.69,0.61,0.92), 0.03, 38)
	_sprite(HOUSE, Vector2(555,405), 1.18, Color(0.92,0.94,0.90,1.0), 0.0, 112)

	# Asymmetric wall pieces define the garden while preserving the central approach.
	_sprite(MOSSY_WALL, Vector2(405,558), 0.53, Color(0.76,0.79,0.70,0.90), -0.025, 5)
	_sprite(MOSSY_WALL, Vector2(706,566), 0.48, Color(0.72,0.76,0.67,0.87), 0.035, 5)

	# Vegetation is concentrated into corner beds instead of horizontal rows.
	_sprite(FOLIAGE, Vector2(322,526), 0.78, Color(0.75,0.83,0.69,0.90), -0.05, 4)
	_sprite(FLOWER_BED, Vector2(374,578), 0.55, Color(0.92,0.89,0.72,0.93), -0.035, 8)
	_sprite(FOLIAGE, Vector2(438,592), 0.43, Color(0.72,0.80,0.66,0.82), 0.055, 6)
	_sprite(FOLIAGE, Vector2(754,528), 0.70, Color(0.72,0.80,0.66,0.88), 0.05, 5)
	_sprite(FLOWER_BED, Vector2(728,590), 0.48, Color(0.84,0.82,0.68,0.90), -0.045, 8)
	_sprite(FOLIAGE, Vector2(790,610), 0.38, Color(0.69,0.77,0.63,0.78), 0.06, 7)

	# Broken, staggered fence pieces make the yard boundary feel weathered and organic.
	_sprite(FENCE, Vector2(305,625), 0.46, Color(0.72,0.66,0.54,0.82), -0.07, 5)
	_sprite(FENCE, Vector2(390,642), 0.34, Color(0.69,0.63,0.51,0.74), 0.04, 5)
	_sprite(FENCE, Vector2(735,642), 0.36, Color(0.68,0.62,0.51,0.76), -0.045, 5)
	_sprite(FENCE, Vector2(795,650), 0.27, Color(0.64,0.59,0.49,0.68), 0.035, 5)

	# Story props and warm light form one small working corner on the right.
	_sprite(ROADSIDE_CLUTTER, Vector2(770,582), 0.45, Color(0.90,0.82,0.68,0.94), 0.02, 8)
	_sprite(STONE, Vector2(824,612), 0.23, Color(0.82,0.84,0.79,0.75), -0.04, 3)
	_ellipse(Vector2(815,590), Vector2(86,36), Color(0.95,0.58,0.25,0.08), -1)
	_ellipse(Vector2(815,590), Vector2(45,22), Color(1.0,0.72,0.36,0.07), -1)
	_sprite(LANTERN, Vector2(810,535), 0.58, Color(1.0,0.90,0.72,0.98), 0.0, 45)

	# Small edge details soften the empty center without obstructing the playable route.
	_sprite(FOLIAGE, Vector2(475,650), 0.24, Color(0.67,0.75,0.61,0.56), -0.03, 1)
	_sprite(FLOWER_BED, Vector2(650,666), 0.20, Color(0.78,0.76,0.61,0.52), 0.04, 1)

	# Preserve the collision behavior that already tested correctly.
	_add_static_box("HouseCollision", Vector2(555,466), Vector2(286,70))
	_add_static_box("LeftFoundationWallCollision", Vector2(405,562), Vector2(120,22))
	_add_static_box("RightFoundationWallCollision", Vector2(706,570), Vector2(110,22))
	_add_static_box("FenceCollision", Vector2(325,630), Vector2(118,18))
	_add_static_box("ClutterCollision", Vector2(770,590), Vector2(68,32))
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
