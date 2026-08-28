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
	# Broad clearing beneath the cottage, kept intentionally irregular so it feels cut into the forest.
	_patch(PackedVector2Array([
		Vector2(250,250),Vector2(350,215),Vector2(485,222),Vector2(645,205),Vector2(790,245),
		Vector2(850,330),Vector2(830,470),Vector2(772,565),Vector2(650,610),Vector2(505,605),
		Vector2(360,565),Vector2(275,485),Vector2(238,350)
	]), Color(0.055,0.075,0.055,0.40), -5)

	# Leaf litter and packed soil visually connect the house, walls and road instead of leaving isolated props.
	_patch(PackedVector2Array([
		Vector2(360,470),Vector2(440,444),Vector2(550,450),Vector2(665,458),Vector2(760,500),
		Vector2(790,555),Vector2(735,615),Vector2(640,628),Vector2(555,615),Vector2(470,630),
		Vector2(385,610),Vector2(335,550)
	]), Color(0.17,0.125,0.082,0.22), -4)

	# A readable front walk leads directly from the road opening to the doorstep.
	_patch(PackedVector2Array([
		Vector2(515,505),Vector2(598,505),Vector2(610,550),Vector2(602,608),Vector2(622,690),
		Vector2(580,708),Vector2(535,704),Vector2(500,682),Vector2(520,605),Vector2(505,550)
	]), Color(0.31,0.235,0.16,0.36), -3)
	_patch(PackedVector2Array([
		Vector2(532,515),Vector2(585,515),Vector2(590,555),Vector2(580,601),Vector2(596,668),
		Vector2(564,683),Vector2(533,673),Vector2(544,602),Vector2(532,555)
	]), Color(0.42,0.34,0.24,0.18), -2)

	# Soft contact shadow grounds the building and makes the foundation feel attached to the terrain.
	_ellipse(Vector2(555,505), Vector2(190,38), Color(0.02,0.025,0.02,0.28), -2, 36)

	# Small embedded stones break up the walk without turning it into a tiled road.
	for stone_data in [
		[Vector2(548,544),0.14,-0.10],[Vector2(578,566),0.11,0.08],[Vector2(542,602),0.12,0.04],
		[Vector2(575,635),0.10,-0.06],[Vector2(550,672),0.09,0.05],
		[Vector2(765,565),0.16,-0.08],[Vector2(810,592),0.14,0.05]
	]:
		_sprite(STONE, stone_data[0], stone_data[1], Color(0.82,0.82,0.76,0.68), stone_data[2], -2)

	# Trees frame the clearing from outside the cottage silhouette.
	_sprite(PINE, Vector2(270,330), 1.18, Color(0.70,0.80,0.70,0.96), -0.04, 55)
	_sprite(PINE, Vector2(825,320), 1.05, Color(0.66,0.76,0.67,0.94), 0.04, 50)
	_sprite(PINE, Vector2(245,470), 0.82, Color(0.58,0.69,0.61,0.92), 0.03, 38)

	_sprite(HOUSE, Vector2(555,405), 1.18, Color(0.92,0.94,0.90,1.0), 0.0, 112)

	# Garden walls now form a deliberate front boundary with a centered entrance gap.
	_sprite(MOSSY_WALL, Vector2(420,558), 0.58, Color(0.76,0.79,0.70,0.90), -0.02, 5)
	_sprite(MOSSY_WALL, Vector2(690,560), 0.54, Color(0.72,0.76,0.67,0.87), 0.025, 5)

	# Layer vegetation into masses instead of isolated icons.
	_sprite(FOLIAGE, Vector2(330,525), 0.78, Color(0.75,0.83,0.69,0.90), -0.05, 4)
	_sprite(FLOWER_BED, Vector2(395,585), 0.62, Color(0.92,0.89,0.72,0.95), -0.02, 8)
	_sprite(FLOWER_BED, Vector2(452,592), 0.45, Color(0.86,0.83,0.68,0.90), 0.04, 7)
	_sprite(FOLIAGE, Vector2(748,528), 0.70, Color(0.72,0.80,0.66,0.88), 0.05, 5)
	_sprite(FLOWER_BED, Vector2(706,587), 0.54, Color(0.84,0.82,0.68,0.92), -0.04, 8)
	_sprite(FLOWER_BED, Vector2(760,598), 0.38, Color(0.78,0.76,0.62,0.84), 0.04, 7)

	# Fence runs are offset from the wall so they read as a yard boundary, not scattered leftovers.
	_sprite(FENCE, Vector2(318,620), 0.52, Color(0.72,0.66,0.54,0.82), -0.055, 5)
	_sprite(FENCE, Vector2(392,632), 0.44, Color(0.70,0.64,0.52,0.78), 0.025, 5)
	_sprite(FENCE, Vector2(720,632), 0.46, Color(0.68,0.62,0.51,0.78), -0.02, 5)

	# Story props live together beside the garden rather than floating independently.
	_sprite(ROADSIDE_CLUTTER, Vector2(760,582), 0.48, Color(0.90,0.82,0.68,0.94), 0.02, 8)
	_sprite(STONE, Vector2(820,610), 0.26, Color(0.82,0.84,0.79,0.78), -0.04, 3)

	# Warm light ties the right side of the clearing together.
	_ellipse(Vector2(815,590), Vector2(86,36), Color(0.95,0.58,0.25,0.08), -1)
	_ellipse(Vector2(815,590), Vector2(45,22), Color(1.0,0.72,0.36,0.07), -1)
	_sprite(LANTERN, Vector2(810,535), 0.58, Color(1.0,0.90,0.72,0.98), 0.0, 45)

	# Keep the established collision behavior that already tested correctly.
	_add_static_box("HouseCollision", Vector2(555,466), Vector2(286,70))
	_add_static_box("LeftFoundationWallCollision", Vector2(420,562), Vector2(132,22))
	_add_static_box("RightFoundationWallCollision", Vector2(690,564), Vector2(122,22))
	_add_static_box("FenceCollision", Vector2(335,625), Vector2(135,18))
	_add_static_box("ClutterCollision", Vector2(760,590), Vector2(72,32))
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
