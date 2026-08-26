extends Node

var items: Dictionary = {}

func add_item(item_id: String, amount: int = 1) -> void:
	if amount <= 0:
		return
	items[item_id] = items.get(item_id, 0) + amount

	# Keep legacy GameState potion count synchronized while the battle system
	# is being migrated to InventoryManager.
	if item_id == "small_potion" or item_id == "potions":
		GameState.potions = get_item_count(item_id)

func remove_item(item_id: String, amount: int = 1) -> void:
	if amount <= 0 or not items.has(item_id):
		return
	items[item_id] -= amount
	if items[item_id] <= 0:
		items.erase(item_id)
	if item_id == "small_potion" or item_id == "potions":
		GameState.potions = get_item_count(item_id)

func get_item_count(item_id: String) -> int:
	return items.get(item_id, 0)

func has_item(item_id: String) -> bool:
	return get_item_count(item_id) > 0
