extends Node2D

var battle_manager: BattleManager
var battle_ui: BattleUI

@export var default_enemies: Array[CharacterData] = []
@export var show_debug := false

const WORLD_SCENE := "res://scenes/World/WorldMap.tscn"

func _ready() -> void:
	battle_manager = BattleManager.new()
	battle_manager.name = "BattleManager"
	add_child(battle_manager)

	battle_ui = BattleUI.new()
	battle_ui.name = "BattleUI"
	battle_ui.battle_manager = battle_manager
	add_child(battle_ui)

	battle_manager.battle_ended.connect(_on_battle_ended)
	battle_ui.action_selected.connect(_on_action_selected)

	var party_members: Array[CharacterData] = []
	for member_name in GameState.party:
		var original := GameState.get_party_member(member_name)
		if original == null:
			continue
		var member := original.duplicate(true) as CharacterData
		if member_name == "Aria":
			member.hp = int(GameState.player_stats.get("hp", member.hp))
			member.mp = int(GameState.player_stats.get("mp", member.mp))
		party_members.append(member)

	var enemies: Array[CharacterData] = []
	var pending: Dictionary = GameState.world_progress.get("pending_encounter", {})
	var enemy_path := str(pending.get("enemy_path", ""))
	if enemy_path.begins_with("res://data/characters/") and enemy_path.ends_with(".tres") and ResourceLoader.exists(enemy_path):
		var encounter_enemy := load(enemy_path) as CharacterData
		if encounter_enemy != null:
			enemies.append(encounter_enemy)
	if enemies.is_empty():
		for fallback_enemy in default_enemies:
			if fallback_enemy != null:
				enemies.append(fallback_enemy)
	if enemies.is_empty():
		enemies.append(load("res://data/characters/goblin.tres") as CharacterData)

	battle_manager.init_battle(party_members, enemies)

func _on_action_selected(action: String, target: CombatUnit) -> void:
	var accepted := battle_manager.execute_action(action, target, battle_ui.selected_skill, battle_ui.selected_item_id)
	if not accepted and not battle_manager.battle_over:
		battle_ui.show_action_menu(battle_manager.current_unit)

func _on_battle_ended(victory: bool, rewards: Dictionary) -> void:
	if victory:
		_apply_battle_rewards(rewards)
	_persist_party_after_battle(victory)
	if victory:
		var pending: Dictionary = GameState.world_progress.get("pending_encounter", {})
		var encounter_id := str(pending.get("id", ""))
		if not encounter_id.is_empty():
			var completed_id := "encounter_" + encounter_id
			if not GameState.world_progress.completed_events.has(completed_id):
				GameState.world_progress.completed_events.append(completed_id)
	GameState.world_progress.erase("pending_encounter")
	GameState.world_progress["current_scene"] = WORLD_SCENE
	SaveManager.save_game()

	if victory:
		battle_ui.show_result("VICTORY!  +%d XP  +%d gold\nReturning to Greyhaven..." % [int(rewards.get("experience", 0)), int(rewards.get("gold", 0))])
	else:
		battle_ui.show_result("DEFEAT.  The party regroups in Greyhaven.")
	await get_tree().create_timer(1.8).timeout
	get_tree().change_scene_to_file(WORLD_SCENE)

func _apply_battle_rewards(rewards: Dictionary) -> void:
	var experience := maxi(0, int(rewards.get("experience", 0)))
	var gold := maxi(0, int(rewards.get("gold", 0)))
	GameState.party_gold += gold
	GameState.party_experience += experience
	var per_member := int(experience / maxi(1, battle_manager.party_units.size()))
	for unit in battle_manager.party_units:
		var original := GameState.get_party_member(unit.character_data.display_name)
		if original != null and per_member > 0:
			original.add_experience(per_member)
		if GameState.companions.has(unit.character_data.display_name):
			BondManager.increase_bond(unit.character_data.display_name, 5)
	var items: Dictionary = rewards.get("items", {})
	for item_id in items:
		var amount := int(items[item_id])
		if amount > 0:
			InventoryManager.add_item(str(item_id), amount)

func _persist_party_after_battle(victory: bool) -> void:
	for unit in battle_manager.party_units:
		var name := unit.character_data.display_name
		var original := GameState.get_party_member(name)
		if original == null:
			continue
		# Regrouping at half HP prevents a loss from producing an unwinnable reload.
		original.hp = maxi(1, unit.current_hp) if victory else maxi(1, int(original.max_hp / 2))
		original.mp = maxi(0, unit.current_mp)
		if name == "Aria":
			GameState.player_stats["hp"] = original.hp
			GameState.player_stats["mp"] = original.mp
			GameState.player_stats["max_hp"] = original.max_hp
			GameState.player_stats["max_mp"] = original.max_mp
			GameState.player_stats["level"] = original.level
			GameState.player_stats["experience"] = original.experience
