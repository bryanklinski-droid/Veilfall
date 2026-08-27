class_name BattleUI
extends CanvasLayer

signal action_selected(action: String, target: CombatUnit)

@export var battle_manager: BattleManager
@export var message_speed: float = 0.05

var current_action: String = ""
var current_target: int = 0
var action_menu_visible: bool = false
var waiting_for_input: bool = false

func _ready() -> void:
	if not battle_manager:
		battle_manager = get_parent().get_node("BattleManager")
	
	if battle_manager:
		battle_manager.turn_changed.connect(_on_turn_changed)
		battle_manager.unit_acted.connect(_on_unit_acted)
		battle_manager.unit_defeated.connect(_on_unit_defeated)

func _process(_delta: float) -> void:
	if waiting_for_input and action_menu_visible:
		_handle_menu_input()

## Display party and enemies status
func update_battle_display() -> void:
	_update_party_display()
	_update_enemy_display()

## Update party member status
func _update_party_display() -> void:
	if not battle_manager:
		return
	
	for unit in battle_manager.party_units:
		print("%s: %d/%d HP | %d/%d MP" % [
			unit.character_data.display_name,
			unit.current_hp,
			unit.character_data.max_hp,
			unit.current_mp,
			unit.character_data.max_mp
		])

## Update enemy status
func _update_enemy_display() -> void:
	if not battle_manager:
		return
	
	for unit in battle_manager.enemy_units:
		if not unit.is_defeated():
			print("%s: %d/%d HP" % [
				unit.character_data.display_name,
				unit.current_hp,
				unit.character_data.max_hp
			])

## Show action menu for player unit
func show_action_menu(unit: CombatUnit) -> void:
	action_menu_visible = true
	waiting_for_input = true
	current_action = ""
	current_target = 0
	
	print("\n=== %s's Turn ===" % unit.character_data.display_name)
	print("Actions:")
	print("  [1] Attack")
	print("  [2] Skill")
	print("  [3] Item")
	print("  [4] Defend")
	
	# Wait for player input
	await _wait_for_action_input()

## Wait for action input from player
func _wait_for_action_input() -> void:
	while waiting_for_input and current_action == "":
		await get_tree().process_frame

## Handle menu input
func _handle_menu_input() -> void:
	if Input.is_action_just_pressed("ui_1"):  # Attack
		current_action = "attack"
		_show_target_menu()
		waiting_for_input = false
	elif Input.is_action_just_pressed("ui_2"):  # Skill
		current_action = "skill"
		_show_skill_menu()
		waiting_for_input = false
	elif Input.is_action_just_pressed("ui_3"):  # Item
		current_action = "item"
		waiting_for_input = false
	elif Input.is_action_just_pressed("ui_4"):  # Defend
		current_action = "defend"
		waiting_for_input = false

## Show target selection menu for attacks
func _show_target_menu() -> void:
	if not battle_manager:
		return
	
	var valid_targets = battle_manager.get_valid_targets(battle_manager.current_unit)
	if valid_targets.is_empty():
		return
	
	current_target = 0
	print("\nSelect Target:")
	for i in range(valid_targets.size()):
		print("  [%d] %s (%d/%d HP)" % [
			i + 1,
			valid_targets[i].character_data.display_name,
			valid_targets[i].current_hp,
			valid_targets[i].character_data.max_hp
		])
	
	# Wait for target selection
	_wait_for_target_input(valid_targets)

## Wait for target input
func _wait_for_target_input(targets: Array[CombatUnit]) -> void:
	var selected = false
	while not selected:
		if Input.is_action_just_pressed("ui_up"):
			current_target = max(0, current_target - 1)
			print("-> %s" % targets[current_target].character_data.display_name)
		elif Input.is_action_just_pressed("ui_down"):
			current_target = min(targets.size() - 1, current_target + 1)
			print("-> %s" % targets[current_target].character_data.display_name)
		elif Input.is_action_just_pressed("ui_accept"):
			action_selected.emit(current_action, targets[current_target])
			action_menu_visible = false
			selected = true
		await get_tree().process_frame

## Show skill menu
func _show_skill_menu() -> void:
	if not battle_manager or not battle_manager.current_unit:
		return
	
	var skills = battle_manager.current_unit.character_data.get_available_skills()
	if skills.is_empty():
		print("No skills available!")
		return
	
	print("\nSelect Skill:")
	for i in range(skills.size()):
		print("  [%d] %s (Cost: %d MP)" % [
			i + 1,
			skills[i].skill_name,
			skills[i].mp_cost
		])

## Display combat message
func show_message(message: String) -> void:
	print(message)
	# TODO: Add animated message display

## Called when turn changes
func _on_turn_changed(unit: CombatUnit) -> void:
	update_battle_display()
	if unit.is_player:
		show_action_menu(unit)

## Called when unit acts
func _on_unit_acted(unit: CombatUnit, action: String) -> void:
	show_message("%s used %s!" % [unit.character_data.display_name, action])

## Called when unit is defeated
func _on_unit_defeated(unit: CombatUnit) -> void:
	show_message("%s was defeated!" % unit.character_data.display_name)
