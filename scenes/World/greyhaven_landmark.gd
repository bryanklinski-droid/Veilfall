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
	# Ground shapes stay beneath all actors and props.
	_patch(PackedVector2Array([
		Vector2(255,250),Vector2(360,214),Vector2(500,224),Vector2(650,205),Vector2(790,246),
		Vector2(850,330),Vector2(828,472),Vector2(760,560),Vector2(620,586),Vector2(474,575),
		Vector2(338,536),Vector2(270,442),Vector2(238,338)
	]), Color(0.055,0.075,0.055,0.38), -4)
	_patch(PackedVector2Array([
		Vector2(392,474),Vector2(500,446),Vector2(620,454),Vector2(742,486),Vector2(802,546),
		Vector2(770,605),Vector2(652,616),Vector2(530,596),Vector2(420,610),Vector2(354,560)
	]), Color(0.15,0.115,0.075,0.18), -3)

	_patch(PackedVector2Array([
		Vector2(742,540),Vector2(792,548),Vector2(844,585),Vector2(894,632),Vector2(884,670),
		Vector2(829,636),Vector2(780,600),Vector2(724,575)
	]), Color(0.28,0.205,0.135,0.26), -2)
	for stone_data in [
		[Vector2(767,565),0.18,-0.08],[Vector2(810,592),0.16,0.05],[Vector2(850,623),0.14,-0.04]
	]:
		_sprite(STONE, stone_data[0], stone_data[1], Color(0.88,0.89,0.84,0.68), stone_data[2], -2)

	# Tall scenery sorts from its visual ground-contact point, not its texture center.
	_sprite(PINE, Vector2(315,328), 1.30, Color(0.70,0.80,0.70,0.96), -0.04, 70)
	_sprite(PINE, Vector2(775,315), 1.12, Color(0.66,0.76,0.67,0.94), 0.04, 60)
	_sprite(PINE, Vector2(265,458), 0.94, Color(0.58,0.69,0.61,0.92), 0.03, 50)

	# The cottage image is centered at y=405 and its visible foundation reaches about y=535.
	# Sorting at that foundation line lets Aria render in front once her feet pass the doorstep.
	_sprite(HOUSE, Vector2(555,405), 1.18, Color(0.92,0.94,0.90,1.0), 0.0, 130)

	_sprite(MOSSY_WALL, Vector2(465,548), 0.66, Color(0.78,0.80,0.72,0.88), -0.025, 4)
	_sprite(MOSSY_WALL, Vector2(665,550), 0.58, Color(0.72,0.76,0.67,0.84), 0.035, 4)
	_sprite(FLOWER_BED, Vector2(430,570), 0.62, Color(0.92,0.90,0.73,0.94), -0.03, 8)
	_sprite(FLOWER_BED, Vector2(700,574), 0.54, Color(0.84,0.82,0.68,0.90), 0.04, 8)
	_sprite(FOLIAGE, Vector2(345,535), 0.74, Color(0.77,0.84,0.70,0.90), -0.05, 6)
	_sprite(FOLIAGE, Vector2(770,518), 0.68, Color(0.72,0.80,0.66,0.88), 0.06, 6)
	_sprite(FENCE, Vector2(350,586), 0.52, Color(0.75,0.69,0.57,0.80), -0.08, 4)
	_sprite(ROADSIDE_CLUTTER, Vector2(744,570), 0.48, Color(0.90,0.82,0.68,0.92), 0.02, 7)

	_ellipse(Vector2(812,585), Vector2(78,34), Color(0.95,0.58,0.25,0.075), -1)
	_sprite(LANTERN, Vector2(810,535), 0.58, Color(1.0,0.90,0.72,0.98), 0.0, 45)

	# Use a shallow rear-wall footprint instead of one large box covering the entire facade.
	# This leaves the doorstep/front apron walkable while still preventing passage through the house.
	_add_static_box("HouseRearCollision", Vector2(555,462), Vector2(296,62))
	_add_static_box("HouseLeftFrontCollision", Vector2(475,512), Vector2(118,38))
	_add_static_box("HouseRightFrontCollision", Vector2(635,512), Vector2(118,38))
	# The central gap is the doorway/step approach.
	_add_static_box("LeftFoundationWallCollision", Vector2(465,552), Vector2(150,24))
	_add_static_box("RightFoundationWallCollision", Vector2(665,554), Vector2(132,24))
	_add_static_box("FenceCollision", Vector2(350,590), Vector2(120,20))
	_add_static_box("ClutterCollision", Vector2(744,579), Vector2(76,34))
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
