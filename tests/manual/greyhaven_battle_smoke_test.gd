extends Node

# Run from the project root:
# godot --headless --path . --scene res://tests/manual/greyhaven_battle_smoke_test.tscn
# Exercises real BattleManager actions without altering the player's saved game.
var passed := 0
var failed := 0
var original_inventory: Dictionary = {}

func _ready() -> void:
	await get_tree().process_frame
	original_inventory = InventoryManager.items.duplicate(true)
	_test_starting_skills()
	_test_item_usage()
	_test_struggle()
	_test_victory_and_rewards()
	InventoryManager.items = original_inventory
	print("Greyhaven battle smoke test: %d passed, %d failed" % [passed, failed])
	get_tree().quit(0 if failed == 0 else 1)

func _make_battle(powerful: bool = false) -> BattleManager:
	var aria := (load("res://data/characters/aria.tres") as CharacterData).duplicate(true) as CharacterData
	var goblin := (load("res://data/characters/goblin.tres") as CharacterData).duplicate(true) as CharacterData
	aria.hp = aria.max_hp
	aria.speed = 999
	if powerful:
		aria.attack = 999
	var members: Array[CharacterData] = [aria]
	var enemies: Array[CharacterData] = [goblin]
	var manager := BattleManager.new()
	add_child(manager)
	manager.init_battle(members, enemies)
	return manager

func _check(condition: bool, message: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", message)
	else:
		failed += 1
		push_error("FAIL: " + message)

func _test_starting_skills() -> void:
	var aria := load("res://data/characters/aria.tres") as CharacterData
	var names: Array[String] = []
	for skill in aria.get_available_skills():
		names.append(skill.skill_name)
	_check(names.has("Arcane Strike"), "Aria can select her starting attack skill")

func _test_item_usage() -> void:
	var manager := _make_battle()
	var hero := manager.party_units[0]
	hero.current_hp = 20
	InventoryManager.items.clear()
	InventoryManager.add_item("small_potion", 1)
	_check(manager.execute_action("item", hero, null, "small_potion"), "potion action succeeds")
	_check(InventoryManager.get_item_count("small_potion") == 0, "potion is consumed exactly once")
	_check(hero.current_hp > 20, "potion heals a damaged ally")
	manager.queue_free()

	var second := _make_battle()
	var second_hero := second.party_units[0]
	second_hero.current_hp = 20
	_check(not second.execute_action("item", second_hero, null, "small_potion"), "missing potion cannot be used")
	second.queue_free()

func _test_struggle() -> void:
	var manager := _make_battle()
	var hero := manager.party_units[0]
	var target := manager.enemy_units[0]
	hero.is_restrained = true
	hero.struggle_attempts = 1
	var notices: Array[String] = []
	manager.combat_message.connect(func(message: String) -> void: notices.append(message))
	_check(not manager.execute_action("attack", target), "grab blocks ordinary attacks")
	_check(manager.execute_action("struggle"), "grabbed party member can struggle")
	var freed := false
	for notice in notices:
		if notice.contains("breaks free"):
			freed = true
	_check(freed, "second struggle guarantees escape")
	manager.queue_free()

func _test_victory_and_rewards() -> void:
	var manager := _make_battle(true)
	var result := {"ended": false, "victory": false, "xp": 0}
	manager.battle_ended.connect(func(victory: bool, rewards: Dictionary) -> void:
		result["ended"] = true
		result["victory"] = victory
		result["xp"] = int(rewards.get("experience", 0))
	)
	_check(manager.execute_action("attack", manager.enemy_units[0]), "attack action succeeds")
	_check(result["ended"] and result["victory"], "defeating the enemy ends the battle in victory")
	_check(result["xp"] > 0, "victory awards enemy XP")
	manager.queue_free()
