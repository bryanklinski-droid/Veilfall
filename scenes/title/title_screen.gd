extends Control

func _ready() -> void:
	print("Hello from the title screen!")

func start_new_game() -> void:
	GameState.reset_new_game()
	EventManager.reset_events()
	InventoryManager.items.clear()
	InventoryManager.add_item("cell_key", 1)

func _on_new_game_button_pressed() -> void:
	start_new_game()
	get_tree().change_scene_to_file("res://scenes/World/WorldMap.tscn")

func _on_continue_button_pressed() -> void:
	if not SaveManager.load_game():
		print("No valid save file found.")
		return
	get_tree().change_scene_to_file("res://scenes/World/WorldMap.tscn")

func _on_settings_button_pressed() -> void:
	print("Settings menu is not implemented yet.")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
