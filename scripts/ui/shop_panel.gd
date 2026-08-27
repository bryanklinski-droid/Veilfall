class_name ShopPanel
extends PanelContainer

signal purchase_completed

var shop_name: Label
var item_list: ItemList
var item_details: RichTextLabel
var buy_button: Button
var sell_button: Button
var gold_label: Label
var close_button: Button

var current_items: Array[Dictionary] = []
var selected_item_index: int = -1

func _ready() -> void:
	shop_name = Label.new()
	item_list = ItemList.new()
	item_details = RichTextLabel.new()
	buy_button = Button.new()
	sell_button = Button.new()
	gold_label = Label.new()
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
	
	# Shop name and gold with styling
	var header = HBoxContainer.new()
	shop_name.text = "Shop"
	shop_name.add_theme_font_size_override("font_size", 20)
	shop_name.add_theme_color_override("font_color", Color.GOLD)
	header.add_child(shop_name)
	
	gold_label.text = "Gold: 0"
	gold_label.add_theme_font_size_override("font_size", 16)
	gold_label.add_theme_color_override("font_color", Color.YELLOW)
	header.add_child(Control.new())  # Spacer
	header.get_child(-1).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(gold_label)
	vbox.add_child(header)
	
	# Items and details
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	item_list.custom_minimum_size = Vector2(300, 300)
	item_list.item_selected.connect(_on_item_selected)
	hbox.add_child(item_list)
	
	item_details.custom_minimum_size = Vector2(300, 300)
	item_details.bbcode_enabled = true
	hbox.add_child(item_details)
	
	vbox.add_child(hbox)
	
	# Buttons
	var button_hbox = HBoxContainer.new()
	button_hbox.separation = 10
	
	buy_button.text = "Buy"
	buy_button.pressed.connect(_on_buy_pressed)
	button_hbox.add_child(buy_button)
	
	sell_button.text = "Sell"
	sell_button.pressed.connect(_on_sell_pressed)
	button_hbox.add_child(sell_button)
	
	close_button.text = "Close"
	close_button.pressed.connect(func(): hide())
	button_hbox.add_child(Control.new())  # Spacer
	button_hbox.get_child(-1).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_hbox.add_child(close_button)
	
	vbox.add_child(button_hbox)
	
	hide()

func open_shop(shop_id: String) -> void:
	if ShopManager.open_shop(shop_id):
		shop_name.text = ShopManager.get_current_shop().shop_name
		refresh_inventory()
		update_gold_display()
		show()

func refresh_inventory() -> void:
	item_list.clear()
	current_items.clear()
	
	var shop = ShopManager.get_current_shop()
	if not shop:
		return
	
	current_items = shop.get_shop_inventory()
	for item in current_items:
		var stock_text = ""
		if item["stock"] >= 0:
			stock_text = " (%d)" % item["stock"]
		item_list.add_item("%s - %d gold%s" % [item["name"], item["price"], stock_text])

func _on_item_selected(index: int) -> void:
	selected_item_index = index
	if index < current_items.size():
		var item = current_items[index]
		var text = "[b]%s[/b]\n" % item["name"]
		text += "Price: %d gold\n" % item["price"]
		text += item.get("description", "")
		
		item_details.clear()
		item_details.append_text(text)

func _on_buy_pressed() -> void:
	if selected_item_index >= 0 and selected_item_index < current_items.size():
		var item = current_items[selected_item_index]
		if ShopManager.buy_item(item["id"]):
			show_message("Purchased %s!" % item["name"])
			refresh_inventory()
			update_gold_display()
		else:
			show_message("Cannot afford %s!" % item["name"])

func _on_sell_pressed() -> void:
	# Simple sell dialog
	show_message("Sell feature coming soon!")

func update_gold_display() -> void:
	gold_label.text = "Gold: %d" % GameState.party_gold

func show_message(text: String) -> void:
	item_details.clear()
	item_details.append_text("[color=yellow]%s[/color]" % text)
	await get_tree().create_timer(2.0).timeout
	if selected_item_index >= 0:
		_on_item_selected(selected_item_index)
