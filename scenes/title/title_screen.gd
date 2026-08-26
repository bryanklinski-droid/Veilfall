extends Control

func _ready() -> void:
	print("Hello from the title screen!")

func start_new_game() -> void:
	GameState.potions = 0
	GameState.party = ["Aria"]
	InventoryManager.items.clear()
	InventoryManager.add_item("cell_key", 1)

func _on_new_game_button_pressed() -> void:
	start_new_game()
	get_tree().change_scene_to_file("res://scenes/World/WorldMap.tscn")
