extends Node

## Manages corruption mechanics - central to Veilfall's theme
## Corruption affects character stats, appearance, and story

signal corruption_increased(character: String, stage: int, max_stage: int)
signal character_corrupted(character: String)
signal corruption_reversed(character: String)

const MAX_CORRUPTION_STAGE = 5
const CORRUPTION_STAT_PENALTY = 0.1  # 10% penalty per stage

var corruption_data: Dictionary = {}

func _ready() -> void:
	# Initialize corruption tracking for all characters
	for char_name in GameState.companions:
		if not corruption_data.has(char_name):
			corruption_data[char_name] = {
				"stage": 0,
				"resistance": 50,  # Higher = harder to corrupt
				"corruption_points": 0
			}

## Increase corruption for a character
func increase_corruption(character_name: String, amount: int = 10) -> void:
	if not corruption_data.has(character_name):
		_initialize_character(character_name)
	
	var char_data = corruption_data[character_name]
	var resistance = char_data["resistance"]
	
	# Resistance reduces corruption gain
	var actual_amount = max(1, amount - (resistance / 10))
	char_data["corruption_points"] += actual_amount
	
	# Check if stage increases
	var stage_threshold = 100 * (char_data["stage"] + 1)
	if char_data["corruption_points"] >= stage_threshold and char_data["stage"] < MAX_CORRUPTION_STAGE:
		char_data["stage"] += 1
		corruption_increased.emit(character_name, char_data["stage"], MAX_CORRUPTION_STAGE)
		
		# Update character data
		var char_resource = _load_character_resource(character_name)
		if char_resource:
			char_resource.corruption_stage = char_data["stage"]
			_apply_corruption_effects(character_name, char_data["stage"])
		
		if char_data["stage"] >= MAX_CORRUPTION_STAGE:
			character_corrupted.emit(character_name)
			if GameState.companions.has(character_name):
				GameState.companions[character_name]["captured"] = true

## Decrease corruption for a character
func decrease_corruption(character_name: String, amount: int = 20) -> void:
	if not corruption_data.has(character_name):
		return
	
	var char_data = corruption_data[character_name]
	var old_stage = char_data["stage"]
	
	char_data["corruption_points"] = max(0, char_data["corruption_points"] - amount)
	
	# Check if stage decreases
	var stage_threshold = 100 * char_data["stage"]
	if char_data["corruption_points"] < stage_threshold and char_data["stage"] > 0:
		char_data["stage"] -= 1
		
		var char_resource = _load_character_resource(character_name)
		if char_resource:
			char_resource.corruption_stage = char_data["stage"]
			_apply_corruption_effects(character_name, char_data["stage"])
		
		if old_stage >= MAX_CORRUPTION_STAGE and char_data["stage"] < MAX_CORRUPTION_STAGE:
			corruption_reversed.emit(character_name)
			if GameState.companions.has(character_name):
				GameState.companions[character_name]["captured"] = false

## Get corruption stage for a character
func get_corruption_stage(character_name: String) -> int:
	if not corruption_data.has(character_name):
		_initialize_character(character_name)
	return corruption_data[character_name]["stage"]

## Get corruption percentage (0-100)
func get_corruption_percentage(character_name: String) -> float:
	if not corruption_data.has(character_name):
		_initialize_character(character_name)
	
	var char_data = corruption_data[character_name]
	var stage_threshold = 100 * (char_data["stage"] + 1)
	return min(100.0, (float(char_data["corruption_points"]) / float(stage_threshold)) * 100.0)

## Apply stat penalties based on corruption stage
func get_corruption_stat_modifier(base_stat: int, character_name: String) -> int:
	var stage = get_corruption_stage(character_name)
	var penalty = 1.0 - (stage * CORRUPTION_STAT_PENALTY)
	return max(1, int(base_stat * penalty))

## Apply visual/gameplay effects based on corruption
func _apply_corruption_effects(character_name: String, stage: int) -> void:
	print("Applying corruption effects for %s at stage %d" % [character_name, stage])
	
	match stage:
		0:
			pass  # Normal state
		1:
			print("%s is slightly corrupted" % character_name)
		2:
			print("%s is moderately corrupted" % character_name)
		3:
			print("%s is heavily corrupted" % character_name)
		4:
			print("%s is severely corrupted" % character_name)
		5:
			print("%s is completely corrupted!" % character_name)
	
	# TODO: Trigger visual changes in character sprite/model

## Check if character is fully corrupted
func is_fully_corrupted(character_name: String) -> bool:
	return get_corruption_stage(character_name) >= MAX_CORRUPTION_STAGE

## Initialize character corruption tracking
func _initialize_character(character_name: String) -> void:
	if not corruption_data.has(character_name):
		corruption_data[character_name] = {
			"stage": 0,
			"resistance": 50,
			"corruption_points": 0
		}

## Load character resource
func _load_character_resource(character_name: String) -> CharacterData:
	var char_path = "res://data/characters/" + character_name.to_lower() + ".tres"
	if ResourceLoader.exists(char_path):
		return load(char_path)
	return null
