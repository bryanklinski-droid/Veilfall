# Veilfall: Advanced Systems Guide

## Phase 6 Implementation Summary

All 8 advanced systems have been fully implemented and integrated into the Veilfall JRPG engine. This document provides comprehensive usage documentation for developers and content creators.

---

## 1. Boss Battle System

### Overview
Boss battles feature multi-phase mechanics where bosses transition to new phases at specific HP thresholds. Each phase can have unique abilities and behaviors.

### Files
- **Script:** `scripts/characters/boss_data.gd`
- **Extension:** Extends EnemyData with phase mechanics
- **Example:** `data/characters/crimson_captain_boss.tres`

### Creating a Boss

```gdscript
# Create in editor as a .tres file inheriting BossData
@export var phase_thresholds: Array[int] = [100, 50]  # HP thresholds
@export var phase_abilities: Array[Array] = []  # Abilities per phase
@export var is_story_boss: bool = true  # Story progression flag
```

### Key Methods
- `get_current_phase()` - Returns 0-based phase number
- `get_phase_abilities()` - Skills available in current phase
- `should_use_phase_ability()` - 30% chance per turn
- `get_boss_description()` - Display info with phase

### Battle Integration
The BattleManager automatically detects bosses:
```gdscript
var is_boss_battle = battle_manager.is_boss_battle()  # true/false
var bosses = battle_manager.get_bosses()  # Array of boss units
```

### Content Creation
1. Create boss CharacterData file with base stats
2. Extend as BossData with phase thresholds
3. Add phase-specific skills to phase_abilities
4. Set story_boss = true for quest integration
5. Configure boss_rewards for quest completion

---

## 2. Side Quest System

### Overview
Unlimited concurrent quests with stage-based progression. Main, side, and companion quest types supported.

### Files
- **Manager:** `autoload/event_manager.gd`
- **Resource:** `scripts/quests/quest_data.gd`
- **Storage:** `res://data/quests/`

### Creating a Quest

```gdscript
# Create .tres file as QuestData
@export var quest_id: String = "fetch_herbs"
@export var quest_name: String = "Gather Healing Herbs"
@export var quest_type: String = "side"  # main, side, companion
@export var stages: Array[QuestStage] = []
@export var rewards: Dictionary = {
    "experience": 100,
    "gold": 50,
    "items": {}
}
```

### Quest Stages
Each stage has objectives, item requirements, enemy defeats, and area visits:
```gdscript
var stage = QuestStage.new(0, "Find 3 herbs", 3)
stage.required_items = ["herb"]
stage.required_area = "forest"
stage.completion_flag = "collected_herbs"
quest.stages.append(stage)
```

### EventManager API
```gdscript
EventManager.start_quest("fetch_herbs")
EventManager.advance_quest_stage("fetch_herbs")
EventManager.complete_quest("fetch_herbs", {"gold": 50})

EventManager.get_active_quests()  # Returns [quest_id, ...]
EventManager.get_available_quests()  # Not started
EventManager.get_completed_quests()  # Finished
EventManager.get_quest_count()  # {"active": 2, "available": 5, ...}
```

### Dialogue Integration
Quests trigger through dialogue actions:
```gdscript
action = "quest_start"
action_param = "fetch_herbs"
```

---

## 3. Companion Quest System

### Overview
Character-specific story arcs that increase bond and unlock dialogue. Each companion has a quest line.

### Files
- **Manager:** `autoload/companion_quest_manager.gd`
- **Storage:** `res://data/quests/companion/`
- **Naming:** `[character_id]_[quest_name].tres`

### Creating a Companion Quest

```gdscript
# File: data/quests/companion/Elara_origins.tres
quest_id = "Elara_origins"
quest_name = "Elara's Origins"
quest_type = "companion"
rewards = {
    "experience": 300,
    "bond_increase": 50  # Automatic
}
```

### CompanionQuestManager API
```gdscript
CompanionQuestManager.start_companion_quest("Elara", "Elara_origins")
CompanionQuestManager.advance_companion_quest_stage("Elara", "Elara_origins")
CompanionQuestManager.complete_companion_quest("Elara", "Elara_origins")
# Auto-increases bond by 50 on completion

CompanionQuestManager.get_companion_quests("Elara")
CompanionQuestManager.get_active_companion_quest("Elara")
CompanionQuestManager.is_companion_quest_completed("Elara", "Elara_origins")
```

### Progression
- Companion quests have stages like regular quests
- Completion grants +50 bond (customizable in code)
- Multiple quest lines per companion supported
- Dialogue can check quest progress via event flags

---

## 4. Equipment Shop System

### Overview
Buy and sell items with configurable shops. Supports unlimited or limited stock management.

### Files
- **Manager:** `autoload/shop_manager.gd`
- **Resource:** `scripts/shops/shop_data.gd`
- **Storage:** `res://data/shops/`

### Creating a Shop

```gdscript
# File: data/shops/village_general.tres (ShopData)
shop_id = "village_general"
shop_name = "Village General Store"
shop_type = "general"  # general, weapon, armor, magic, potion
inventory = [
    {
        "item_id": "small_potion",
        "price": 50,
        "stock": -1  # -1 = unlimited
    },
    {
        "item_id": "wooden_sword",
        "price": 100,
        "stock": 5  # Limited stock
    }
]
```

### ShopManager API
```gdscript
ShopManager.open_shop("village_general")
ShopManager.buy_item("small_potion")  # Costs gold, adds to inventory
ShopManager.sell_item("small_potion", 1)  # Gets 50% of buy price
ShopManager.close_shop()

ShopManager.get_current_shop()  # Active shop
ShopManager.get_shop_info("village_general")  # Details
```

### World Integration
Place shop NPCs in areas and trigger dialogue:
```gdscript
# In NPC dialogue action
action = "open_shop"
action_param = "village_general"
```

### Pricing
- Sell price = 50% of buy price
- Gold automatically deducted/added
- Inventory updated on transaction
- Auto-saves after purchase/sale

---

## 5. Dungeon Progression System

### Overview
Multi-floor dungeons with unique encounters per floor, boss battles, and treasure discovery. Complete dungeons for rewards.

### Files
- **Manager:** `autoload/dungeon_manager.gd`
- **Resource:** `scripts/dungeons/dungeon_data.gd`
- **Storage:** `res://data/dungeons/`

### Creating a Dungeon

```gdscript
# File: data/dungeons/shadow_crypt.tres (DungeonData)
dungeon_id = "shadow_crypt"
dungeon_name = "Shadow Crypt"
entrance_area = "dark_forest"
boss_enemy_id = "crimson_captain_boss"

# Create floors programmatically
var floor1 = DungeonData.DungeonFloor.new(0, "crypt_floor1", 2)
floor1.enemy_encounters = ["goblin", "bandit"]
floor1.treasure_rooms = [{"item": "potion", "gold": 100}]

var floor2 = DungeonData.DungeonFloor.new(1, "crypt_boss", 3)
floor2.boss_encounter = "crimson_captain_boss"
floors = [floor1, floor2]

rewards = {
    "experience": 2000,
    "gold": 2000,
    "items": {}
}
```

### DungeonManager API
```gdscript
DungeonManager.enter_dungeon("shadow_crypt")
DungeonManager.get_current_floor()  # DungeonFloor object
DungeonManager.advance_floor()  # Progress to next floor

DungeonManager.trigger_encounter()  # Random enemy on floor
DungeonManager.find_treasure()  # Loot discovery
DungeonManager.complete_dungeon()  # Finish and save

DungeonManager.get_dungeon_info("shadow_crypt")  # Details
DungeonManager.get_available_dungeons()  # All dungeons
```

### Floor Management
```gdscript
class DungeonFloor:
    var floor_number: int
    var area_id: String  # Scene to load
    var difficulty: int  # 1-5
    var enemy_encounters: Array[String]  # Enemy IDs
    var treasure_rooms: Array[Dictionary]
    var boss_encounter: String = ""
    
    func get_random_encounter() -> String
    func has_boss() -> bool
```

### Content Flow
1. Create floor areas/scenes in editor
2. Create DungeonData with floor definitions
3. Add to dungeon directory
4. Trigger entrance from world NPC
5. Battle encounters spawn from enemy pool
6. Final floor has optional boss
7. Completion grants rewards

---

## 6. Character Animation System

### Overview
Sprite-based battle animations with tweening. Supports attack, skill, damage, defeat, victory, and defend animations.

### Files
- **Manager:** `autoload/animation_manager.gd`
- **Implementation:** Godot Tween system

### Registration
```gdscript
# Register character sprite (usually in Battle scene)
AnimationManager.register_character("Aria", aria_sprite_node)
```

### Built-in Animations
```gdscript
# Attack: Forward thrust + white flash
AnimationManager.play_attack_animation("Aria", 0.5)

# Skill: Type-specific effects
AnimationManager.play_skill_animation("Aria", "magic", 0.6)  # Yellow spin
AnimationManager.play_skill_animation("Aria", "heal", 0.6)   # Green scale
AnimationManager.play_skill_animation("Aria", "buff", 0.6)   # Cyan pulse

# Damage: Knockback + red flash
AnimationManager.play_damage_animation("Aria", 50, 0.4)

# Defeat: Fade out + shrink
AnimationManager.play_defeat_animation("Aria", 1.0)

# Victory: Jump + glow
AnimationManager.play_victory_animation("Aria", 0.8)

# Defend: Crouch effect
AnimationManager.play_defend_animation("Aria", 0.3)
```

### Async Animation Support
All animations are async (don't block):
```gdscript
# Wait for animation to complete
await AnimationManager.play_attack_animation("Aria")
# Then proceed to next action
```

### Signals
```gdscript
AnimationManager.animation_started.connect(_on_animation_start)
AnimationManager.animation_completed.connect(_on_animation_complete)
```

### Integration
BattleManager can trigger animations on actions:
```gdscript
# In custom battle scripts
await AnimationManager.play_attack_animation(attacker_id)
BattleManager._perform_attack(attacker, defender)
```

---

## 7. Skill Tree System

### Overview
Character-specific skill progression trees with prerequisites, tiers, and skill point investment.

### Files
- **Manager:** `autoload/skill_tree_manager.gd`
- **Resource:** `scripts/skill_tree_data.gd`
- **Storage:** `res://data/skill_trees/`

### Creating a Skill Tree

```gdscript
# File: data/skill_trees/aria_skills.tres (SkillTreeData)
character_id = "Aria"

# Create skill nodes
var arcane_strike = SkillTreeData.SkillNode.new(
    "arcane_strike",
    load("res://data/skills/arcane_strike.tres"),
    1,  # cost
    0   # tier (foundation)
)
arcane_strike.prerequisites = []  # No requirements

var improved_arcane = SkillTreeData.SkillNode.new(
    "improved_arcane",
    load("res://data/skills/arcane_strike_plus.tres"),
    1,
    1  # intermediate tier
)
improved_arcane.prerequisites = ["arcane_strike"]  # Requires base skill

skill_nodes = [arcane_strike, improved_arcane]
```

### SkillTreeManager API
```gdscript
# Get and inspect
SkillTreeManager.get_skill_tree("Aria")  # SkillTreeData object
SkillTreeManager.get_available_skills("Aria")  # Unlockable skills
SkillTreeManager.is_skill_unlocked("Aria", "arcane_strike")  # true/false

# Invest points
SkillTreeManager.invest_in_skill("Aria", "arcane_strike", 1)  # Uses 1 skill point
# Character learns the skill if investment successful

# Track progress
SkillTreeManager.get_skill_points("Aria", "arcane_strike")  # Points spent
SkillTreeManager.get_character_skill_progress("Aria")  # All invested skills
```

### CharacterData Integration
```gdscript
# Each character has skill points
character.skill_points  # 0 initially
# +1 per level up (grants 1 point)

character.level_up()  # Now has +1 skill_points
```

### UI Display
```gdscript
var available = SkillTreeManager.get_available_skills("Aria")
for skill_info in available:
    print(skill_info.name, " costs ", skill_info.cost, " points")
```

### Progression Flow
1. Create SkillData for each skill
2. Define SkillTreeData with nodes and prerequisites
3. Characters gain skill points on level up
4. Players allocate points via UI
5. Skills unlock based on prerequisites
6. Learned skills become available in combat

---

## 8. Day/Night Cycle System

### Overview
24-hour time system with 4 cycles, day/night brightness, time acceleration, and event triggers.

### Files
- **Manager:** `autoload/time_manager.gd`
- **Integration:** World effects, NPC behavior, encounters

### Time Cycles
```
Night:       00:00 - 06:00  (60% brightness)
Morning:     06:00 - 12:00  (100% brightness)
Afternoon:   12:00 - 18:00  (100% brightness)
Evening:     18:00 - 00:00  (100% brightness)
```

### TimeManager API

#### Basic Time Control
```gdscript
# Automatic progression (1 hour per 6 real seconds at time_scale=1.0)
TimeManager.advance_hour()  # +1 hour
TimeManager.advance_minutes(30)  # +30 minutes
TimeManager.set_time(14, 30)  # Set to 14:30 (2:30 PM)

# Speed control
TimeManager.set_time_scale(2.0)  # 2x speed
TimeManager.pause_time()  # Pause
TimeManager.resume_time()  # Resume
```

#### Cycle Queries
```gdscript
TimeManager.get_current_cycle()  # "morning", "afternoon", etc.
TimeManager.is_cycle("night")  # true/false
TimeManager.is_daytime()  # 06:00-18:00
TimeManager.is_nighttime()  # 00:00-06:00 OR 18:00-24:00

# Time ranges
TimeManager.is_time_in_range(10, 14)  # 10:00-14:00?
TimeManager.get_hours_until_cycle("night")  # Hours remaining
```

#### Display & Utilities
```gdscript
TimeManager.get_time_string()  # "14:30"
TimeManager.get_date_string()  # "Day 5, afternoon - 14:30"
TimeManager.get_day_night_modifier()  # 0.6 (night) or 1.0 (day)

# Rest mechanics
TimeManager.skip_to_cycle("morning")  # Jump to next morning
TimeManager.rest_until_cycle("morning")  # Pause, skip, resume
```

### Signals
```gdscript
TimeManager.time_changed.connect(func(hour, minute): print("%02d:%02d" % [hour, minute]))
TimeManager.day_changed.connect(func(day): print("Day ", day))
TimeManager.cycle_changed.connect(func(cycle): print("Cycle: ", cycle))
```

### Gameplay Integration

#### Area Effects
```gdscript
# In AreaManager or scene scripts
var brightness = TimeManager.get_day_night_modifier()
area_canvas_layer.modulate.a = brightness
```

#### NPC Behavior
```gdscript
# NPCs available only during certain times
if TimeManager.is_cycle("morning"):
    npc_sprite.visible = true
```

#### Enemy Encounters
```gdscript
# Different enemies at night
if TimeManager.is_nighttime():
    enemies = night_encounter_pool
```

#### Inn/Rest Mechanics
```gdscript
# Rest until morning
TimeManager.rest_until_cycle("morning")
player.restore_hp()
player.restore_mp()
```

---

## System Architecture

### Autoload Manager Stack (15 Total)

#### Core (1)
- GameState - Party, gold, experience, companions

#### Persistence (1)
- SaveManager - JSON save/load

#### Inventory & Resources (1)
- InventoryManager - Item tracking

#### Game Systems (4)
- CorruptionManager - Central mechanic
- EventManager - Quests and flags
- DialogueManager - NPC conversations
- AreaManager - World exploration

#### Advanced Systems (8 New)
- ShopManager - Equipment/items
- SkillTreeManager - Skill progression
- DungeonManager - Multi-floor dungeons
- CompanionQuestManager - Character stories
- BondManager - Relationships
- AudioManager - Music/SFX
- EffectsManager - Visual effects
- AnimationManager - Battle animations
- TimeManager - Day/night cycle

### Cross-System Communication

**Via Events:**
- Dialogue triggers quests → EventManager.start_quest()
- Quests grant items → InventoryManager.add_item()
- Boss defeat triggers dungeons → DungeonManager.complete_dungeon()
- Companion quests increase bond → BondManager.increase_bond()
- Time cycle changes trigger area effects

**Via Signals:**
- battle_ended → apply rewards → increase bond
- quest_completed → grant gold/items
- companion_recruited → EventManager flag set
- cycle_changed → update area lighting/enemies
- animation_completed → trigger next battle action

---

## Content Creation Workflow

### 1. Creating a Quest Line
```
1. Create QuestData .tres file
2. Define stages with objectives
3. Set rewards and quest_type
4. Add quest_id to EventManager.quests
5. Trigger via dialogue: action="quest_start", action_param="quest_id"
6. Track progress with EventManager.advance_quest_stage()
```

### 2. Creating a Boss Encounter
```
1. Create CharacterData with base stats
2. Extend as BossData
3. Set phase_thresholds and phase_abilities
4. Create area with BattleUI trigger
5. Assign to battle export as default_enemies
6. Battle auto-detects boss and uses phase AI
```

### 3. Creating a Dungeon
```
1. Create DungeonData .tres file
2. Define DungeonFloor for each floor
3. Add enemy encounter pools and treasure
4. Set final floor boss_encounter
5. Create scene files for each floor area
6. Trigger entrance via dialogue or world trigger
```

### 4. Adding a Shop
```
1. Create ShopData .tres file
2. Define inventory with prices/stock
3. Create shop NPC dialogue
4. Add open_shop action to dialogue
5. Players can buy/sell with auto-balance
```

### 5. Creating Companion Quest
```
1. Create QuestData in res://data/quests/companion/
2. Name: [character_id]_[quest_name].tres
3. Define stages and storyline
4. Trigger in dialogue via action parameters
5. Completion auto-increases bond
```

### 6. Creating Skill Tree
```
1. Create SkillTreeData .tres file
2. Define SkillNode for each skill
3. Set prerequisites and tiers
4. Assign character_id
5. UI shows available skills
6. Players invest skill points on level up
```

---

## Performance Considerations

- **Animations:** All async, non-blocking via Tween system
- **Time System:** Lightweight _process() delta accumulation
- **Shops:** Dictionary-based with optional stock tracking
- **Quests:** Arrays with O(n) searches (optimize if >100 quests)
- **Skill Trees:** Prerequisite validation on invest only
- **Dungeons:** Floor loading on enter/advance (minimal memory)

---

## Example Complete Flow

```
1. Player starts game → TimeManager begins (Day 1, 6:00 AM)
2. Player enters world → TimeManager advances cycle
3. Player talks to NPC → DialogueManager loads convo
4. Dialogue action: quest_start "find_herbs"
   → EventManager creates quest
5. Player fights enemies → BattleManager handles combat
6. Victory → BondManager increases companion bond by 5
7. Player collects herbs → InventoryManager tracks items
8. Player returns to NPC → Dialogue triggers quest_complete
9. EventManager.complete_quest() grants rewards:
   → Gold added to GameState
   → Experience added to party
   → SaveManager auto-saves
10. Player visits shop → ShopManager.open_shop("village_general")
11. Player buys potion → GameState.party_gold -= 50
12. Player enters dungeon → DungeonManager.enter_dungeon()
13. Battles on floors → Boss encountered on final floor
14. Boss is BossData → Enhanced AI uses phase abilities
15. Boss defeated → Dungeon completed → Rewards granted
16. Skill tree UI → Player invests skill_points → Characters learn skills
17. Time reaches evening → Cycle changes → Area becomes darker
18. Player rests at inn → TimeManager.rest_until_cycle("morning")
```

---

## Debugging & Testing

### Console Commands (in custom debug scene)
```gdscript
# Test quests
EventManager.start_quest("fetch_herbs")
EventManager.complete_quest("fetch_herbs", {"gold": 100})

# Test time
TimeManager.set_time(20, 0)  # 8 PM
TimeManager.skip_to_cycle("night")

# Test shops
ShopManager.open_shop("village_general")
ShopManager.buy_item("small_potion")

# Test dungeons
DungeonManager.enter_dungeon("shadow_crypt")
DungeonManager.complete_dungeon()

# Test skill trees
SkillTreeManager.invest_in_skill("Aria", "arcane_strike", 1)
print(SkillTreeManager.get_available_skills("Aria"))
```

### Error Handling
All managers include validation:
- Shop: "Not enough gold!" message
- Quest: Stage advancement checks
- Skill Tree: Prerequisite validation
- Dungeon: Floor boundary checks
- Boss: Phase threshold validation

---

## Extending the Systems

### Custom Boss AI
```gdscript
# Override _enemy_act in battle_manager.gd
if current_unit.character_data.character_id == "crimson_captain":
    # Custom logic
```

### Custom Animations
```gdscript
# Add to AnimationManager
func play_custom_animation(char_id: String):
    var tween = create_tween()
    # Your animation code
```

### Custom Time Effects
```gdscript
# Listen to TimeManager signals
TimeManager.cycle_changed.connect(func(cycle):
    if cycle == "night":
        # Spawn night enemies
)
```

### Custom Quest Logic
```gdscript
# Extend EventManager or create QuestSystemExtension
EventManager.quest_completed.connect(func(quest_id):
    if quest_id == "final_boss":
        # Trigger ending
)
```

---

## Summary

**All 8 Advanced Systems Implemented:**
1. ✅ Boss battles with phases
2. ✅ Unlimited side quests
3. ✅ Companion character stories
4. ✅ Equipment shop system
5. ✅ Multi-floor dungeons
6. ✅ Battle animations
7. ✅ Skill tree progression
8. ✅ Day/night cycle

**15 Autoload Managers** provide complete game systems coverage.
**Fully integrated** with existing dialogue, battle, and progression systems.
**Production-ready** for immediate content creation and gameplay testing.

