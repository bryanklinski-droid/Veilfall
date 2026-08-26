extends Node

var items: Dictionary = {}

func add_item(item_id: String, amount: int = 1) -> void:
	if item_id.is_empty() or amount <= 0:
		return
	items[item_id] = items.get(item_id, 0) + amount

func remove_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0 or get_item_count(item_id) < amount:
		return false
	items[item_id] -= amount
	if items[item_id] <= 0:
		items.erase(item_id)
	return true

func get_item_count(item_id: String) -> int:
	return int(items.get(item_id, 0))

func has_item(item_id: String) -> bool:
	return get_item_count(item_id) > 0

func clear_inventory() -> void:
	items.clear()
