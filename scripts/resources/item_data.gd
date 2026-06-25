extends Resource
class_name ItemData

@export var item_name: String = ""
@export_multiline var description = ""
@export var is_key_item: bool = false
@export var icon: Texture2D
@export var item_type: String = "Consumable" # Weapon, Armor, Accessory, KeyItem
@export var value: int = 0

@export var hp_restore: int = 0
@export var mp_restore: int = 0

@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var magic_bonus: int = 0
