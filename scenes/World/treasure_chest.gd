extends Area2D

@export var item_id: String = "cell_key"
@export var amount: int = 1
@export var chest_id: String = ""
var opened = false

func _ready() -> void:
	# Check if this chest was already opened in a previous session
	opened = SaveManager.get_progress_flag("chest_" + chest_id)
	if opened:
		_show_opened_state()

func open_chest() -> void:
	if opened:
		return

	opened = true
	SaveManager.set_progress_flag("chest_" + chest_id, true)
	InventoryManager.add_item(item_id, amount)
	print("Found ", amount, " x ", item_id)
	_show_opened_state()
	SaveManager.save_game()

func _show_opened_state() -> void:
	"""Visual feedback that chest is opened"""
	# TODO: Add animation or visual change when opened
	pass
