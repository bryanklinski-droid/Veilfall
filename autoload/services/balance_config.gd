
extends Node

## Game Balance Configuration
## Centralized constants for easy difficulty tuning

# ============================================================================
# DIFFICULTY SCALING MULTIPLIERS
# ============================================================================

## Multipliers for different difficulty settings
const DIFFICULTY_MULTIPLIERS = {
	"easy": 0.75,
	"normal": 1.0,
	"hard": 1.5,
	"nightmare": 2.0
}

var current_difficulty: String = "normal"

# ============================================================================
# ENEMY BALANCE
# ============================================================================

## Base XP multiplier (modified by level and difficulty)
const ENEMY_XP_BASE_MULTIPLIER = 1.0

## Base gold multiplier (modified by level and difficulty)
const ENEMY_GOLD_BASE_MULTIPLIER = 1.0

## Enemy stat scaling per level
const ENEMY_HP_PER_LEVEL = 15
const ENEMY_ATK_PER_LEVEL = 1.2
const ENEMY_DEF_PER_LEVEL = 0.8
const ENEMY_SPD_PER_LEVEL = 0.3

# ============================================================================
# CHARACTER/PARTY BALANCE
# ============================================================================

## Character stat growth per level
const CHAR_HP_PER_LEVEL = 20
const CHAR_ATK_PER_LEVEL = 1.5
const CHAR_DEF_PER_LEVEL = 1.0
const CHAR_MAG_PER_LEVEL = 1.2
const CHAR_SPD_PER_LEVEL = 0.4

## Companion bonus stats per bond level
const COMPANION_BONUS = {
	1: {"atk": 2, "def": 2, "mag": 2, "spd": 1, "hp": 10},
	2: {"atk": 4, "def": 4, "mag": 4, "spd": 2, "hp": 20},
	3: {"atk": 6, "def": 6, "mag": 7, "spd": 3, "hp": 30},
	4: {"atk": 8, "def": 8, "mag": 10, "spd": 4, "hp": 40},
	5: {"atk": 10, "def": 10, "mag": 14, "spd": 5, "hp": 50}
}

# ============================================================================
# ECONOMY BALANCE
# ============================================================================

## Item sell price multiplier (sell price = value * this multiplier)
const SELL_PRICE_MULTIPLIER = 0.5

## Equipment pricing
const EQUIPMENT_PRICES = {
	"wooden_sword": 80,
	"iron_sword": 350,
	"steel_sword": 800,
	"diamond_sword": 2000
}

## Consumable pricing
const CONSUMABLE_PRICES = {
	"small_potion": 60,
	"large_potion": 200,
	"mana_potion": 120,
	"full_heal_potion": 500
}

# ============================================================================
# QUEST BALANCE
# ============================================================================

## Quest reward scaling by type
const QUEST_REWARDS = {
	"tutorial": {"xp": 50, "gold": 25},
	"side_short": {"xp": 150, "gold": 100},
	"side_medium": {"xp": 300, "gold": 200},
	"side_long": {"xp": 500, "gold": 350},
	"main": {"xp": 700, "gold": 550},
	"companion": {"xp": 400, "gold": 300},
	"boss": {"xp": 1000, "gold": 1500}
}

# ============================================================================
# BOSS BALANCE
# ============================================================================

## Boss stat multipliers (vs normal enemies of same level)
const BOSS_HP_MULTIPLIER = 3.0
const BOSS_ATK_MULTIPLIER = 1.8
const BOSS_DEF_MULTIPLIER = 1.5
const BOSS_SPD_MULTIPLIER = 1.2

## Story boss rewards
const STORY_BOSS_REWARDS = {
	"experience": 800,
	"gold": 1500
}

## Mini-boss rewards
const MINI_BOSS_REWARDS = {
	"experience": 400,
	"gold": 600
}

# ============================================================================
# COMBAT BALANCE
# ============================================================================

## Critical hit chance and multiplier
const CRITICAL_CHANCE = 0.15
const CRITICAL_MULTIPLIER = 1.5

## Status effect duration (in turns)
const STATUS_EFFECT_DURATION = {
	"poison": 3,
	"stun": 1,
	"sleep": 2,
	"freeze": 2
}

## Defense damage reduction formula
## Final damage = base_damage * (1 - (defense / (defense + 100)))
const DEFENSE_BASE = 100

## Magic defense (same formula as physical defense)
const MAGIC_DEFENSE_BASE = 100

# ============================================================================
# PROGRESSION BALANCE
# ============================================================================

## Experience required for next level
const EXP_CURVE_BASE = 100
const EXP_CURVE_MULTIPLIER = 1.1  # Each level requires 10% more XP

## Skill point awards
const SKILL_POINTS_PER_LEVEL = 1

## Corruption mechanics
const CORRUPTION_STAT_PENALTIES = {
	0: {"atk": 0, "def": 0, "mag": 0},
	1: {"atk": -5, "def": -3, "mag": 0},
	2: {"atk": -10, "def": -6, "mag": -2},
	3: {"atk": -15, "def": -9, "mag": -5},
	4: {"atk": -20, "def": -12, "mag": -8},
	5: {"atk": -25, "def": -15, "mag": -12}
}

# ============================================================================
# BALANCE GETTERS
# ============================================================================

## Get difficulty multiplier
func get_difficulty_multiplier() -> float:
	return DIFFICULTY_MULTIPLIERS.get(current_difficulty, 1.0)

## Calculate enemy XP reward with difficulty scaling
func calculate_enemy_xp(base_xp: int, enemy_level: int) -> int:
	var multiplier = get_difficulty_multiplier()
	var level_bonus = 1.0 + (enemy_level * 0.1)
	return int(base_xp * level_bonus * multiplier)

## Calculate enemy gold reward with difficulty scaling
func calculate_enemy_gold(base_gold: int, enemy_level: int) -> int:
	var multiplier = get_difficulty_multiplier()
	var level_bonus = 1.0 + (enemy_level * 0.05)
	return int(base_gold * level_bonus * multiplier)

## Calculate quest XP
func calculate_quest_xp(quest_type: String) -> int:
	var base = QUEST_REWARDS.get(quest_type, {"xp": 100}).get("xp", 100)
	return int(base * get_difficulty_multiplier())

## Calculate quest gold
func calculate_quest_gold(quest_type: String) -> int:
	var base = QUEST_REWARDS.get(quest_type, {"gold": 50}).get("gold", 50)
	return int(base * get_difficulty_multiplier())

## Set game difficulty
func set_difficulty(difficulty: String) -> void:
	if difficulty in DIFFICULTY_MULTIPLIERS:
		current_difficulty = difficulty
		print("Game difficulty set to: ", difficulty)
	else:
		push_error("Invalid difficulty: ", difficulty)

## Get current difficulty name
func get_current_difficulty() -> String:
	return current_difficulty
