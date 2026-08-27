extends Node

var items: Dictionary = {}


func add_item(item_id: String, amount: int = 1) -> void:
	if items.has(item_id):
		items[item_id] += amount
	else:
		items[item_id] = amount

func remove_item(item_id: String, amount: int = 1) -> void:
	if not items.has(item_id):
		return

	items[item_id] -= amount

	if items[item_id] <= 0:
		items.erase(item_id)

func get_item_count(item_id: String) -> int:
	return items.get(item_id, 0)

func has_item(item_id: String) -> bool: return items.has(item_id)
