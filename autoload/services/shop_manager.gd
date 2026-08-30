
extends Node

signal shop_opened(shop_name: String, items: Array[Dictionary])
signal item_purchased(item_name: String, price: int)
signal item_sold(item_name: String, price: int)

var shops: Dictionary = {}
var current_shop: String = ""

func _ready() -> void:
	load_shops()

## Load all shops from data directory
func load_shops() -> void:
	var dir = DirAccess.open("res://data/shops/")
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".tres"):
				var shop_id = filename.trim_suffix(".tres")
				var shop = load("res://data/shops/" + filename)
				if shop is ShopData:
					shops[shop_id] = shop
			filename = dir.get_next()
	
	print("Loaded %d shops" % shops.size())

## Open a shop
func open_shop(shop_id: String) -> bool:
	if not shops.has(shop_id):
		print("Error: Shop not found: ", shop_id)
		return false
	
	current_shop = shop_id
	var shop = shops[shop_id]
	shop_opened.emit(shop.shop_name, shop.get_shop_inventory())
	print("Opened shop: ", shop.shop_name)
	return true

## Buy item from current shop
func buy_item(item_id: String) -> bool:
	if current_shop == "":
		return false
	
	var shop = shops[current_shop]
	var item_data = shop.get_item_data(item_id)
	if not item_data:
		return false
	
	var price = item_data["price"]
	
	# Check if player has enough gold
	if GameState.party_gold < price:
		print("Not enough gold!")
		return false
	
	# Purchase item
	GameState.party_gold -= price
	InventoryManager.add_item(item_id, 1)
	item_purchased.emit(item_data.get("name", item_id), price)
	print("Purchased: ", item_id, " for ", price, " gold")
	SaveManager.save_game()
	return true

## Sell item to current shop
func sell_item(item_id: String, amount: int = 1) -> bool:
	if current_shop == "":
		return false
	
	var shop = shops[current_shop]
	var item_data = shop.get_item_data(item_id)
	if not item_data:
		return false
	
	if amount <= 0 or InventoryManager.get_item_count(item_id) < amount:
	if not InventoryManager.has_item(item_id):
		return false
	
	var sell_price = int(item_data["price"] * 0.5)  # Sell for 50% of buy price
	GameState.party_gold += sell_price * amount
	InventoryManager.remove_item(item_id, amount)
	item_sold.emit(item_data.get("name", item_id), sell_price * amount)
	print("Sold: ", item_id, " for ", sell_price * amount, " gold")
	SaveManager.save_game()
	return true

## Close current shop
func close_shop() -> void:
	current_shop = ""

## Get shop details
func get_shop_info(shop_id: String) -> Dictionary:
	if not shops.has(shop_id):
		return {}
	
	var shop = shops[shop_id]
	return {
		"name": shop.shop_name,
		"description": shop.description,
		"type": shop.shop_type,
		"inventory_count": shop.inventory.size()
	}

## Get current shop
func get_current_shop() -> ShopData:
	if current_shop and shops.has(current_shop):
		return shops[current_shop]
	return null
