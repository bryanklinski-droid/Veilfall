extends SceneTree

# Non-destructive Greyhaven chest resource smoke test.
# Run: godot --headless --path . --script res://tests/manual/greyhaven_chest_resource_test.gd
func _initialize() -> void:
	var scene := load("res://scenes/World/WorldMap.tscn") as PackedScene
	if scene == null:
		push_error("Greyhaven scene could not be loaded")
		quit(1)
		return

	var world := scene.instantiate()
	var chest_count := 0
	var failures := 0
	for node in world.find_children("*", "Area2D", true, false):
		if not node.has_method("open_chest"):
			continue
		chest_count += 1
		var item_id := String(node.get("item_id"))
		if not ResourceLoader.exists("res://data/items/%s.tres" % item_id):
			failures += 1
			push_error("%s awards an unknown item id: %s" % [node.name, item_id])
		if node.get_node_or_null("ChestArt") == null:
			failures += 1
			push_error("%s has no visible ChestArt node" % node.name)

	if chest_count == 0:
		failures += 1
		push_error("No Greyhaven chests found")
	world.free()
	print("Greyhaven chest smoke test: %d chests, %d failures" % [chest_count, failures])
	quit(0 if failures == 0 else 1)
