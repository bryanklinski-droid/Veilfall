class_name QuestLogPanel
extends PanelContainer

var quest_list: ItemList
var quest_details: RichTextLabel
var close_button: Button

var active_quests: Array[String] = []
var selected_quest: String = ""

func _ready() -> void:
	quest_list = ItemList.new()
	quest_details = RichTextLabel.new()
	close_button = Button.new()
	setup_ui()
	modulate.a = 0.0  # Start hidden

func setup_ui() -> void:
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Title with styling
	var title = Label.new()
	title.text = "Quest Log"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(title)
	
	# Quest list and details
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	quest_list.custom_minimum_size = Vector2(300, 400)
	quest_list.item_selected.connect(_on_quest_selected)
	hbox.add_child(quest_list)
	
	quest_details.custom_minimum_size = Vector2(400, 400)
	quest_details.bbcode_enabled = true
	hbox.add_child(quest_details)
	
	vbox.add_child(hbox)
	
	# Close button with styling
	close_button.text = "Close"
	close_button.pressed.connect(_on_close_pressed)
	vbox.add_child(close_button)
	
	hide()

func show() -> void:
	super.show()
	modulate.a = 0.0
	
	# Smooth fade-in
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _on_close_pressed() -> void:
	# Smooth fade-out
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	hide()

func show_quest_log() -> void:
	refresh_quests()
	show()

func refresh_quests() -> void:
	quest_list.clear()
	active_quests.clear()
	
	# Add active quests
	var active = EventManager.get_active_quests()
	for quest_id in active:
		quest_list.add_item("[ACTIVE] %s" % quest_id)
		active_quests.append(quest_id)
	
	# Add available quests
	var available = EventManager.get_available_quests()
	for quest_id in available:
		quest_list.add_item "[AVAILABLE] %s" % quest_id
		active_quests.append(quest_id)
	
	# Add completed quests
	var completed = EventManager.get_completed_quests()
	for quest_id in completed:
		quest_list.add_item "[COMPLETED] %s" % quest_id
		active_quests.append(quest_id)

func _on_quest_selected(index: int) -> void:
	if index < active_quests.size():
		selected_quest = active_quests[index]
		_update_quest_details(selected_quest)

func _update_quest_details(quest_id: String) -> void:
	var quest_info = EventManager.get_quest_info(quest_id)
	if quest_info.is_empty():
		quest_details.clear()
		return
	
	var text = ""
	text += "[b]%s[/b]\n" % quest_id
	text += "Status: %s\n" % ("Active" if quest_info.get("started") else "Available")
	text += "Stage: %d\n" % quest_info.get("stage", 0)
	
	if quest_info.get("completed"):
		text += "[color=green]COMPLETED[/color]"
	
	quest_details.clear()
	quest_details.append_text(text)
