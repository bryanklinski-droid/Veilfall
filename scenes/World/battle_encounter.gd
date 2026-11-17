extends Area2D

# A one-time overworld battle marker. All progression is stored in SaveManager's
# existing world_progress dictionary; no new autoload is required.
@export var encounter_id := ""
@export var encounter_name := "Hostile presence"
@export var enemy_path := "res://data/characters/goblin.tres"

func _ready() -> void:
	if encounter_id.is_empty():
		push_warning("An encounter marker has no ID.")
		queue_free()
		return
	if GameState.world_progress.completed_events.has("encounter_" + encounter_id):
		queue_free()
		return
	add_to_group("interactable")
	collision_layer = 2
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 28.0
	shape.shape = circle
	add_child(shape)

	var marker := Polygon2D.new()
	marker.polygon = PackedVector2Array([Vector2(0, -20), Vector2(17, -4), Vector2(11, 15), Vector2(-11, 15), Vector2(-17, -4)])
	marker.color = Color(0.69, 0.22, 0.37, 0.85)
	add_child(marker)

	var label := Label.new()
	label.text = encounter_name + "\nZ: Battle"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-90, -58)
	label.size = Vector2(180, 40)
	label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.89))
	add_child(label)

func interact() -> void:
	if encounter_id.is_empty() or GameState.world_progress.completed_events.has("encounter_" + encounter_id):
		return
	if not enemy_path.begins_with("res://data/characters/") or not enemy_path.ends_with(".tres") or not ResourceLoader.exists(enemy_path):
		push_warning("Encounter %s has an invalid enemy resource." % encounter_id)
		return
	var player := get_parent().get_node_or_null("Player") as Node2D
	if player == null:
		return
	GameState.world_progress["return_position"] = [player.global_position.x, player.global_position.y]
	GameState.world_progress["pending_encounter"] = {"id": encounter_id, "enemy_path": enemy_path}
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/battle/Battle.tscn")
