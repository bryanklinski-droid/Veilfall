extends Area2D

@export var item_id: String = "cell_key"
@export var amount: int = 1
var opened = false

func open_chest():
	if opened:
		return

	opened = true
	InventoryManager.add_item(item_id, amount)
	print("Found ", amount, " x ", item_id)
