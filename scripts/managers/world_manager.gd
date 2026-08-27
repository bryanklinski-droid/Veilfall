class_name WorldManager
extends Node

signal enemy_encountered(enemy_data: CharacterData)
signal npc_interacted(npc_name: String)
signal treasure_opened(treasure_name: String)

@export var player: PlayerController
@export var default_battle_scene: String = "res://scenes/battle/Battle.tscn"

func _ready() -> void:
	if not player:
		player = get_tree().root.find_child("Player", true, false)

## Trigger a battle with an enemy
func start_battle(enemy_data: CharacterData) -> void:
	if not enemy_data:
		print("Error: Invalid enemy data")
		return
	
	enemy_encountered.emit(enemy_data)
	get_tree().change_scene_to_file(default_battle_scene)

## Interact with an NPC (placeholder for dialogue system)
func interact_with_npc(npc_name: String) -> void:
	npc_interacted.emit(npc_name)
	print("Interacting with: ", npc_name)

## Open a treasure chest
func open_treasure(treasure_name: String, items: Dictionary) -> void:
	treasure_opened.emit(treasure_name)
	for item_id in items:
		InventoryManager.add_item(item_id, items[item_id])
	print("Opened treasure: ", treasure_name)
