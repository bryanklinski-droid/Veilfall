extends Area2D

@export var item_id: String = "cell_key"
@export var amount: int = 1
@export var chest_id: String = ""
var opened := false

func _ready() -> void:
	add_to_group("interactable")
	opened = GameState.is_chest_open(chest_id)
	if opened:
		_show_opened_state()

func interact() -> void:
	open_chest()

func open_chest() -> void:
	if opened:
		return
	opened = true
	InventoryManager.add_item(item_id, amount)
	if not chest_id.is_empty():
		GameState.record_chest_open(chest_id)
	else:
		SaveManager.save_game()
	print("Found ", amount, " x ", item_id)
	_show_opened_state()

func _show_opened_state() -> void:
	# TODO: Add animation or sprite change when opened.
	pass
