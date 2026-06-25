extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Hello from the title screen!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func start_new_game():
	var cell_key = load("res://data/items/cell_key.tres")
	InventoryManager.add_item(cell_key, 1)

func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/World/WorldMap.tscn")
