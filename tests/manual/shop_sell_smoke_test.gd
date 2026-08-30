extends Node

const TEST_SHOP_ID := "__patchforge_shop_sell_smoke_test__"
const TEST_ITEM_ID := "patchforge_test_item"
const TEST_PRICE := 100

var _passed := 0
var _failed := 0
var _original_gold := 0
var _original_items: Dictionary = {}
var _original_current_shop := ""
var _had_test_shop := false
var _original_test_shop: Variant = null
var _save_existed := false
var _original_save_text := ""

class FakeShop:
	extends RefCounted

	func get_item_data(item_id: String) -> Dictionary:
		if item_id == TEST_ITEM_ID:
			return {
				"id": TEST_ITEM_ID,
				"name": "Patchforge Test Item",
				"price": TEST_PRICE,
				"stock": -1,
				"description": "Temporary smoke-test item."
			}
		return {}


func _ready() -> void:
	await get_tree().process_frame
	_snapshot_state()
	ShopManager.shops[TEST_SHOP_ID] = FakeShop.new()
	ShopManager.current_shop = TEST_SHOP_ID

	print("\n=== Veilfall Shop sell_item() smoke test ===")
	_test_sell_one_owned_item()
	_test_sell_partial_stack()
	_test_reject_oversell()
	_test_reject_zero_and_negative()
	_test_reject_missing_item()
	_restore_state()

	print("=== Result: %d passed, %d failed ===\n" % [_passed, _failed])
	get_tree().quit(0 if _failed == 0 else 1)


func _snapshot_state() -> void:
	_original_gold = GameState.party_gold
	_original_items = InventoryManager.items.duplicate(true)
	_original_current_shop = ShopManager.current_shop
	_had_test_shop = ShopManager.shops.has(TEST_SHOP_ID)
	if _had_test_shop:
		_original_test_shop = ShopManager.shops[TEST_SHOP_ID]

	_save_existed = SaveManager.has_save_file()
	if _save_existed:
		var file := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.READ)
		if file != null:
			_original_save_text = file.get_as_text()
			file.close()


func _restore_state() -> void:
	GameState.party_gold = _original_gold
	InventoryManager.items = _original_items.duplicate(true)
	ShopManager.current_shop = _original_current_shop

	if _had_test_shop:
		ShopManager.shops[TEST_SHOP_ID] = _original_test_shop
	else:
		ShopManager.shops.erase(TEST_SHOP_ID)

	if _save_existed:
		var file := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		if file == null:
			push_error("Smoke test could not restore the original save file.")
		else:
			file.store_string(_original_save_text)
			file.close()
	elif SaveManager.has_save_file():
		SaveManager.delete_save()


func _reset_case(item_count: int, gold: int = 1000) -> void:
	GameState.party_gold = gold
	InventoryManager.items.clear()
	if item_count > 0:
		InventoryManager.add_item(TEST_ITEM_ID, item_count)
	ShopManager.current_shop = TEST_SHOP_ID


func _check(condition: bool, message: String) -> void:
	if condition:
		_passed += 1
		print("PASS: ", message)
	else:
		_failed += 1
		push_error("FAIL: " + message)


func _test_sell_one_owned_item() -> void:
	_reset_case(1)
	var before_gold := GameState.party_gold
	var result := ShopManager.sell_item(TEST_ITEM_ID, 1)
	_check(result, "selling one owned item succeeds")
	_check(GameState.party_gold == before_gold + 50, "one item awards exactly 50 gold")
	_check(InventoryManager.get_item_count(TEST_ITEM_ID) == 0, "one sold item is removed")


func _test_sell_partial_stack() -> void:
	_reset_case(3)
	var before_gold := GameState.party_gold
	var result := ShopManager.sell_item(TEST_ITEM_ID, 2)
	_check(result, "selling two of three owned items succeeds")
	_check(GameState.party_gold == before_gold + 100, "two items award exactly 100 gold")
	_check(InventoryManager.get_item_count(TEST_ITEM_ID) == 1, "only the requested quantity is removed")


func _test_reject_oversell() -> void:
	_reset_case(1)
	var before_gold := GameState.party_gold
	var before_count := InventoryManager.get_item_count(TEST_ITEM_ID)
	var result := ShopManager.sell_item(TEST_ITEM_ID, 2)
	_check(not result, "selling more than owned is rejected")
	_check(GameState.party_gold == before_gold, "oversell does not change gold")
	_check(InventoryManager.get_item_count(TEST_ITEM_ID) == before_count, "oversell does not change inventory")


func _test_reject_zero_and_negative() -> void:
	_reset_case(2)
	var before_gold := GameState.party_gold
	var before_count := InventoryManager.get_item_count(TEST_ITEM_ID)
	var zero_result := ShopManager.sell_item(TEST_ITEM_ID, 0)
	var negative_result := ShopManager.sell_item(TEST_ITEM_ID, -1)
	_check(not zero_result, "zero sale amount is rejected")
	_check(not negative_result, "negative sale amount is rejected")
	_check(GameState.party_gold == before_gold, "invalid non-positive amounts do not change gold")
	_check(InventoryManager.get_item_count(TEST_ITEM_ID) == before_count, "invalid non-positive amounts do not change inventory")


func _test_reject_missing_item() -> void:
	_reset_case(0)
	var before_gold := GameState.party_gold
	var result := ShopManager.sell_item(TEST_ITEM_ID, 1)
	_check(not result, "selling an item not owned is rejected")
	_check(GameState.party_gold == before_gold, "missing-item sale does not change gold")
	_check(InventoryManager.get_item_count(TEST_ITEM_ID) == 0, "missing-item sale does not create inventory")
