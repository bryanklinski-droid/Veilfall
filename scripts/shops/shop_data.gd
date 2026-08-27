class_name ShopData
extends Resource

@export var shop_id: String
@export var shop_name: String
@export var description: String = ""
@export var shop_type: String = "general"  # general, weapon, armor, magic, potion
@export var inventory: Array[Dictionary] = []  # {item_id: "", price: 0, stock: -1 (unlimited)}

## Get inventory with available items
func get_shop_inventory() -> Array[Dictionary]:
	var available = []
	for item in inventory:
		var item_id = item.get("item_id", "")
		var item_data = load("res://data/items/" + item_id + ".tres")
		if item_data:
			available.append({
				"id": item_id,
				"name": item_data.display_name,
				"price": item.get("price", 100),
				"stock": item.get("stock", -1),  # -1 = unlimited
				"description": item_data.description,
			})
	return available

## Get specific item data
func get_item_data(item_id: String) -> Dictionary:
	for item in inventory:
		if item.get("item_id") == item_id:
			var item_data = load("res://data/items/" + item_id + ".tres")
			if item_data:
				return {
					"id": item_id,
					"name": item_data.display_name,
					"price": item.get("price", 100),
					"stock": item.get("stock", -1),
					"description": item_data.description,
				}
	return {}

## Check if item is in stock
func is_in_stock(item_id: String) -> bool:
	for item in inventory:
		if item.get("item_id") == item_id:
			var stock = item.get("stock", -1)
			return stock == -1 or stock > 0
	return false

## Decrease stock (for limited shops)
func decrease_stock(item_id: String) -> void:
	for item in inventory:
		if item.get("item_id") == item_id:
			if item.get("stock", -1) > 0:
				item["stock"] -= 1
