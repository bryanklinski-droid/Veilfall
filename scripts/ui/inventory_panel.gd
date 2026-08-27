class_name InventoryPanel
extends PanelContainer

var item_list: ItemList
var item_details: RichTextLabel
var use_button: Button
var drop_button: Button
var close_button: Button

var inventory_items: Dictionary = {}
var selected_item: String = ""

func _ready() -> void:
	item_list = ItemList.new()
	item_details = RichTextLabel.new()
	use_button = Button.new()
	drop_button = Button.new()
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
	title.text = "Inventory"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(title)
	
	# Items and details
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	item_list.custom_minimum_size = Vector2(300, 400)
	item_list.item_selected.connect(_on_item_selected)
	hbox.add_child(item_list)
	
	item_details.custom_minimum_size = Vector2(300, 400)
	item_details.bbcode_enabled = true
	hbox.add_child(item_details)
	
	vbox.add_child(hbox)
	
	# Buttons
	var button_hbox = HBoxContainer.new()
	button_hbox.separation = 10
	
	use_button.text = "Use"
	use_button.pressed.connect(_on_use_pressed)
	button_hbox.add_child(use_button)
	
	drop_button.text = "Drop"
	drop_button.pressed.connect(_on_drop_pressed)
	button_hbox.add_child(drop_button)
	
	close_button.text = "Close"
	close_button.pressed.connect(func(): hide())
	button_hbox.add_child(Control.new())  # Spacer
	button_hbox.get_child(-1).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_hbox.add_child(close_button)
	
	vbox.add_child(button_hbox)
	
	hide()

func show_inventory() -> void:
	refresh_inventory()
	show()

func refresh_inventory() -> void:
	item_list.clear()
	inventory_items.clear()
	
	# Get all items
	if InventoryManager:
		inventory_items = InventoryManager.inventory.duplicate()
	
	for item_id in inventory_items:
		var count = inventory_items[item_id]
		item_list.add_item("%s x%d" % [item_id, count])

func _on_item_selected(index: int) -> void:
	var items = inventory_items.keys()
	if index < items.size():
		selected_item = items[index]
		_update_item_details(selected_item)

func _update_item_details(item_id: String) -> void:
	var item_path = "res://data/items/" + item_id + ".tres"
	var item_data = load(item_path)
	
	var text = "[b]%s[/b]\n" % item_id
	if item_data:
		text += item_data.get("description", "")
	text += "\nCount: %d" % inventory_items.get(item_id, 0)
	
	item_details.clear()
	item_details.append_text(text)

func _on_use_pressed() -> void:
	if selected_item and inventory_items.has(selected_item):
		# Use item logic here
		item_details.clear()
		item_details.append_text("[color=green]Used %s![/color]" % selected_item)
		InventoryManager.remove_item(selected_item, 1)
		refresh_inventory()

func _on_drop_pressed() -> void:
	if selected_item and inventory_items.has(selected_item):
		InventoryManager.remove_item(selected_item, 1)
		refresh_inventory()
		item_details.clear()
