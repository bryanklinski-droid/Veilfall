class_name BattleUI
extends CanvasLayer

signal action_selected(action: String, target: CombatUnit)

var battle_manager: BattleManager
var selected_skill: SkillData = null
var selected_item_id := ""
var waiting_for_input := false
var status_label: Label
var message_label: Label
var choices: VBoxContainer

func _ready() -> void:
	if battle_manager == null:
		battle_manager = get_parent().get_node_or_null("BattleManager")
	_build_ui()
	if battle_manager != null:
		battle_manager.turn_changed.connect(_on_turn_changed)
		battle_manager.unit_acted.connect(_on_unit_acted)
		battle_manager.unit_defeated.connect(_on_unit_defeated)
		battle_manager.combat_message.connect(show_message)
	update_battle_display()

func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.045, 0.035, 0.075)
	root.add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	root.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)

	var heading := Label.new()
	heading.text = "VEILFALL  |  BATTLE"
	heading.add_theme_font_size_override("font_size", 30)
	heading.add_theme_color_override("font_color", Color(0.86, 0.67, 1.0))
	column.add_child(heading)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 19)
	status_label.add_theme_color_override("font_color", Color(0.9, 0.89, 0.95))
	column.add_child(status_label)

	message_label = Label.new()
	message_label.text = "Choose an action."
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size.y = 52
	message_label.add_theme_font_size_override("font_size", 20)
	message_label.add_theme_color_override("font_color", Color(0.95, 0.78, 0.72))
	column.add_child(message_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)

	choices = VBoxContainer.new()
	choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choices.add_theme_constant_override("separation", 8)
	scroll.add_child(choices)

func update_battle_display() -> void:
	if battle_manager == null or status_label == null:
		return
	var lines: Array[String] = ["PARTY"]
	for unit in battle_manager.party_units:
		var tag := "  [GRABBED]" if unit.is_restrained else ""
		lines.append("  %s    HP %d/%d   MP %d/%d%s" % [unit.character_data.display_name, unit.current_hp, unit.character_data.max_hp, unit.current_mp, unit.character_data.max_mp, tag])
	lines.append("")
	lines.append("ENEMIES")
	for unit in battle_manager.enemy_units:
		var tag := " [DEFEATED]" if unit.is_defeated() else ""
		lines.append("  %s    HP %d/%d%s" % [unit.character_data.display_name, maxi(0, unit.current_hp), unit.character_data.max_hp, tag])
	status_label.text = "\n".join(PackedStringArray(lines))

func show_action_menu(unit: CombatUnit) -> void:
	if unit == null or battle_manager == null or battle_manager.battle_over:
		return
	waiting_for_input = true
	selected_skill = null
	selected_item_id = ""
	_clear_choices()
	if unit.is_restrained:
		show_message("%s is grabbed! Struggle to escape." % unit.character_data.display_name)
		_add_choice("Struggle (escape by the second try)", Callable(self, "_choose_action").bind("struggle"))
		return
	show_message("%s's turn — choose an action." % unit.character_data.display_name)
	_add_choice("Attack", Callable(self, "_choose_action").bind("attack"))
	_add_choice("Skill", Callable(self, "_choose_action").bind("skill"))
	_add_choice("Item", Callable(self, "_choose_action").bind("item"))
	_add_choice("Defend", Callable(self, "_choose_action").bind("defend"))
	for ally in battle_manager.party_units:
		if ally.is_restrained and not ally.is_defeated():
			_add_choice("Rescue ally", Callable(self, "_choose_action").bind("rescue"))
			break

func _choose_action(action: String) -> void:
	if not waiting_for_input or battle_manager.current_unit == null:
		return
	match action:
		"attack":
			_choose_target("attack", battle_manager.get_valid_targets(battle_manager.current_unit))
		"rescue":
			var captives: Array[CombatUnit] = []
			for ally in battle_manager.party_units:
				if ally.is_restrained and not ally.is_defeated():
					captives.append(ally)
			_choose_target("rescue", captives)
		"skill":
			_show_skills()
		"item":
			_show_items()
		"defend", "struggle":
			_confirm_target(action, null)

func _show_skills() -> void:
	_clear_choices()
	var available := 0
	for skill in battle_manager.current_unit.character_data.get_available_skills():
		if skill != null and battle_manager.current_unit.current_mp >= skill.mp_cost:
			_add_choice("%s (%d MP)" % [skill.skill_name, skill.mp_cost], Callable(self, "_choose_skill").bind(skill))
			available += 1
	if available == 0:
		show_message("No usable skills right now.")
	_add_choice("Back", Callable(self, "_show_actions"))

func _choose_skill(skill: SkillData) -> void:
	selected_skill = skill
	var targets: Array[CombatUnit] = []
	var friendly := skill.effect.to_lower() == "heal" or skill.target_type in ["single_party", "self"]
	if friendly:
		if skill.target_type == "self":
			targets.append(battle_manager.current_unit)
		else:
			for ally in battle_manager.party_units:
				if not ally.is_defeated():
					targets.append(ally)
	else:
		targets = battle_manager.get_valid_targets(battle_manager.current_unit)
	_choose_target("skill", targets)

func _show_items() -> void:
	_clear_choices()
	var count := 0
	for key in InventoryManager.items:
		var item_id := str(key)
		if InventoryManager.get_item_count(item_id) <= 0:
			continue
		var path := "res://data/items/%s.tres" % item_id
		if not ResourceLoader.exists(path):
			continue
		var item := load(path) as ItemData
		if item != null and not item.is_key_item and (item.hp_restore > 0 or item.mp_restore > 0):
			_add_choice("%s x%d" % [item.item_name, InventoryManager.get_item_count(item_id)], Callable(self, "_choose_item").bind(item_id))
			count += 1
	if count == 0:
		show_message("No usable consumables in your inventory.")
	_add_choice("Back", Callable(self, "_show_actions"))

func _choose_item(item_id: String) -> void:
	selected_item_id = item_id
	var targets: Array[CombatUnit] = []
	for unit in battle_manager.party_units:
		if not unit.is_defeated():
			targets.append(unit)
	_choose_target("item", targets)

func _choose_target(action: String, targets: Array[CombatUnit]) -> void:
	_clear_choices()
	if targets.is_empty():
		show_message("No valid targets.")
		_add_choice("Back", Callable(self, "_show_actions"))
		return
	for target in targets:
		_add_choice("%s  (%d HP)" % [target.character_data.display_name, target.current_hp], Callable(self, "_confirm_target").bind(action, target))
	_add_choice("Back", Callable(self, "_show_actions"))

func _confirm_target(action: String, target: CombatUnit) -> void:
	if not waiting_for_input:
		return
	waiting_for_input = false
	_clear_choices()
	action_selected.emit(action, target)

func _show_actions() -> void:
	show_action_menu(battle_manager.current_unit)

func _add_choice(text_value: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(360, 42)
	button.add_theme_font_size_override("font_size", 18)
	choices.add_child(button)
	button.pressed.connect(callback)

func _clear_choices() -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()

func show_message(message: String) -> void:
	if message_label != null:
		message_label.text = message

func show_result(message: String) -> void:
	waiting_for_input = false
	_clear_choices()
	show_message(message)
	update_battle_display()

func _on_turn_changed(unit: CombatUnit) -> void:
	update_battle_display()
	if unit.is_player:
		show_action_menu(unit)
	else:
		waiting_for_input = false
		_clear_choices()

func _on_unit_acted(_unit: CombatUnit, _action: String) -> void:
	update_battle_display()

func _on_unit_defeated(_unit: CombatUnit) -> void:
	update_battle_display()
