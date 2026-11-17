extends Node2D

const GREYHAVEN_LANDMARK := preload("res://scenes/World/greyhaven_landmark.gd")
const GREYHAVEN_REFERENCE_OVERHAUL := preload("res://scenes/World/greyhaven_reference_overhaul.gd")
const BATTLE_ENCOUNTER := preload("res://scenes/World/battle_encounter.gd")

func _ready() -> void:
	GameState.world_progress.current_scene = "res://scenes/World/WorldMap.tscn"
	mark_area_visited("WorldMap")
	_prepare_reference_composition()
	_add_landmark_layer()
	_add_reference_overhaul()
	_add_cottage_world_collision()
	_restore_player_position()
	_add_encounters()
	_update_objective()
	SaveManager.save_game()

func _prepare_reference_composition() -> void:
	# Retire the prototype dressing and the oversized legacy east-side ruin/corruption.
	# The base terrain and road remain as the gameplay floor while the focused art layers
	# below rebuild Greyhaven around the cottage -> road -> board -> corrupted ruin flow.
	for path in [
		"Environment/Corruption",
		"Environment/Structures"
	]:
		var node := get_node_or_null(path)
		if node != null:
			node.visible = false

	# The old broad forest-mass polygons read as giant geometric wedges underneath the
	# new composition. Keep the actual ground shader but remove these prototype overlays.
	for path in [
		"Environment/Terrain/NorthForestMass",
		"Environment/Terrain/SouthForestMass",
		"Environment/Terrain/EastForestMass"
	]:
		var node := get_node_or_null(path)
		if node != null:
			node.visible = false

	# Clear legacy trees from the cottage and the new eastern landmark corridor. Trees
	# outside these zones remain as distant/foreground framing.
	var vegetation := get_node_or_null("Environment/Vegetation")
	if vegetation != null:
		var cottage_clear := Rect2(Vector2(210, 190), Vector2(690, 520))
		var east_clear := Rect2(Vector2(1260, 150), Vector2(720, 850))
		var road_clear := Rect2(Vector2(820, 250), Vector2(360, 980))
		for child in vegetation.get_children():
			if child is Node2D:
				var item := child as Node2D
				if cottage_clear.has_point(item.position) or east_clear.has_point(item.position) or road_clear.has_point(item.position):
					item.visible = false

func _add_landmark_layer() -> void:
	if has_node("GreyhavenLandmark"):
		return
	var landmark := Node2D.new()
	landmark.name = "GreyhavenLandmark"
	landmark.set_script(GREYHAVEN_LANDMARK)
	add_child(landmark)
	move_child(landmark, 2)

func _add_reference_overhaul() -> void:
	if has_node("GreyhavenReferenceOverhaul"):
		return
	var overhaul := Node2D.new()
	overhaul.name = "GreyhavenReferenceOverhaul"
	overhaul.set_script(GREYHAVEN_REFERENCE_OVERHAUL)
	add_child(overhaul)
	move_child(overhaul, 3)

func _add_cottage_world_collision() -> void:
	var collision_root := get_node_or_null("Collision")
	if collision_root == null or collision_root.has_node("CottageBody"):
		return

	var body := StaticBody2D.new()
	body.name = "CottageBody"
	body.collision_layer = 1
	body.collision_mask = 1
	collision_root.add_child(body)

	_add_cottage_shape(body, Vector2(555, 455), Vector2(300, 160))
	_add_cottage_shape(body, Vector2(452, 535), Vector2(92, 26))
	_add_cottage_shape(body, Vector2(658, 535), Vector2(92, 26))

func _add_cottage_shape(body: StaticBody2D, world_pos: Vector2, size: Vector2) -> void:
	var shape_node := CollisionShape2D.new()
	shape_node.position = world_pos
	var rect := RectangleShape2D.new()
	rect.size = size
	shape_node.shape = rect
	body.add_child(shape_node)

func mark_area_visited(area_name: String) -> void:
	if not GameState.world_progress.visited_areas.has(area_name):
		GameState.world_progress.visited_areas.append(area_name)
		SaveManager.save_game()

func record_chest_open(chest_id: String) -> void:
	if chest_id == "":
		return

	if not GameState.world_progress.opened_chests.has(chest_id):
		GameState.world_progress.opened_chests.append(chest_id)
		SaveManager.save_game()

func change_scene(scene_path: String) -> void:
	GameState.world_progress.current_scene = scene_path
	SaveManager.save_game()
	get_tree().change_scene_to_file(scene_path)

func _restore_player_position() -> void:
	var position_data: Variant = GameState.world_progress.get("return_position", [])
	if position_data is Array and position_data.size() == 2:
		var player := get_node_or_null("Gameplay/Player") as Node2D
		if player != null:
			player.global_position = Vector2(float(position_data[0]), float(position_data[1]))

func _add_encounters() -> void:
	var gameplay := get_node_or_null("Gameplay")
	if gameplay == null:
		return
	# Greyhaven's first three optional fights are deliberately spaced along the
	# east road and corruption approach, away from the initial player spawn.
	var encounters := [
		{"id": "road_goblin", "name": "Goblin Scout", "enemy": "goblin", "position": Vector2(1180, 945)},
		{"id": "forest_wolf", "name": "Forest Wolf", "enemy": "wolf", "position": Vector2(1345, 1090)},
		{"id": "ruin_bandit", "name": "Bandit Guard", "enemy": "bandit", "position": Vector2(1510, 770)}
	]
	for info in encounters:
		var completed_id := "encounter_" + str(info["id"])
		if GameState.world_progress.completed_events.has(completed_id):
			continue
		var marker := Area2D.new()
		marker.name = "Encounter_" + str(info["id"])
		marker.set_script(BATTLE_ENCOUNTER)
		marker.set("encounter_id", str(info["id"]))
		marker.set("encounter_name", str(info["name"]))
		marker.set("enemy_path", "res://data/characters/%s.tres" % info["enemy"])
		marker.position = info["position"]
		gameplay.add_child(marker)

func _update_objective() -> void:
	var hud := get_node_or_null("HUD")
	if hud == null:
		return
	var cleared := 0
	for encounter_id in ["road_goblin", "forest_wolf", "ruin_bandit"]:
		if GameState.world_progress.completed_events.has("encounter_" + encounter_id):
			cleared += 1
	var objective := Label.new()
	objective.position = Vector2(39, 124)
	objective.add_theme_font_size_override("font_size", 16)
	objective.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	objective.text = "Greyhaven patrols: %d/3 cleared" % cleared if cleared < 3 else "Greyhaven patrols cleared! Return to the road."
	hud.add_child(objective)
