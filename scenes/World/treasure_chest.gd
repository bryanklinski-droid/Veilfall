extends Area2D

@export var item_id: String = "cell_key"
@export var amount: int = 1
var opened := false

func _ready() -> void:
	add_to_group("interactable")

func interact() -> void:
	open_chest()

func open_chest() -> void:
	if opened:
		return
	if item_id.is_empty() or amount <= 0:
		push_warning("Treasure chest has invalid item configuration.")
		return

	opened = true
	InventoryManager.add_item(item_id, amount)
	print("Found ", amount, " x ", item_id)
