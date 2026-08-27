# Veilfall: Project File Organization

## Overview
This document describes the organized folder structure of the Veilfall project. Files are organized by functionality to improve codebase comprehension and maintainability.

---

## Project Root Structure

```
veilfall--corruption-of-the-kingdom/
├── autoload/                 # Global singleton managers (autoloads)
├── data/                     # Game content resources (.tres files)
├── scenes/                   # Scene files (.tscn) for different game areas
├── scripts/                  # GDScript source code organized by function
├── assets/                   # Graphics and visual resources
├── audio/                    # Audio files (music, sound effects)
├── ui/                       # UI scene files
├── SYSTEMS_GUIDE.md          # Documentation of core systems
├── PROJECT_STRUCTURE.md      # This file
└── project.godot             # Godot project configuration
```

---

## Detailed Folder Structure

### `autoload/` - Global Managers & Singletons
Godot autoloads that persist across scenes and manage game-wide systems.

```
autoload/
├── state/                    # Core game state managers
│   ├── game_state.gd         # Main game state (party, gold, flags)
│   ├── save_manager.gd       # Save/load game state (JSON)
│   └── inventory_manager.gd  # Player inventory management
│
├── systems/                  # Core game systems
│   ├── corruption_manager.gd # Corruption mechanic (5 stages, stat penalties)
│   ├── event_manager.gd      # Quest tracking and story events
│   ├── dialogue_manager.gd   # NPC dialogue and branching options
│   └── area_manager.gd       # Exploration and area transitions
│
└── services/                 # Feature-specific service managers
    ├── audio_manager.gd      # Music management & SFX playback
    ├── bond_manager.gd       # Companion relationship tracking
    ├── effects_manager.gd    # Visual/screen effects (fade, shake, flash)
    ├── shop_manager.gd       # Buy/sell system
    ├── skill_tree_manager.gd # Character skill progression
    ├── dungeon_manager.gd    # Multi-floor dungeon progression
    ├── animation_manager.gd  # Battle animation playback
    ├── time_manager.gd       # 24-hour day/night cycle
    └── companion_quest_manager.gd # Companion-specific story quests
```

**15 Autoloads Total:**
- **State (3)**: Game state, persistence, inventory
- **Systems (4)**: Corruption, events, dialogue, exploration
- **Services (9)**: Audio, bonding, effects, shops, skills, dungeons, animation, time, quests

---

### `scripts/` - Source Code Organization
Game logic organized by feature and component type.

```
scripts/
├── managers/                 # Gameplay managers & orchestrators
│   ├── battle_manager.gd     # Turn-based combat system
│   ├── player_controller.gd  # Player input and movement
│   └── world_manager.gd      # World interaction orchestration
│
├── ui/                       # UI panel components
│   ├── dialogue_panel.gd     # NPC dialogue UI with options
│   ├── battle_panel.gd       # Battle HUD with party/enemy status
│   ├── quest_log_panel.gd    # Quest tracking and details
│   ├── shop_panel.gd         # Shop interface (buy/sell)
│   └── inventory_panel.gd    # Inventory management UI
│
├── characters/               # Character & combat units
│   └── character_data.gd     # Character stats, leveling, skills
│
├── utilities/                # Utility & helper classes
│   ├── combat_unit.gd        # In-battle unit wrapper
│   ├── skill_tree_data.gd    # Skill tree definition class
│   └── battle_ui.gd          # Battle UI utilities
│
├── dialogue/                 # Dialogue system
│   ├── dialogue_data.gd      # Dialogue definition class
│   └── dialogue_option.gd    # Dialogue option class
│
├── areas/                    # Exploration & world
│   └── area_data.gd          # Area definition class
│
├── shops/                    # Shop system
│   └── shop_data.gd          # Shop definition class
│
├── dungeons/                 # Dungeon system
│   └── dungeon_data.gd       # Dungeon definition class
│
├── quests/                   # Quest system
│   └── quest_data.gd         # Quest definition class
│
└── resources/                # Base resource classes
    ├── item_data.gd          # Item definition class
    ├── skill_data.gd         # Skill definition class
    └── boss_data.gd          # Boss enemy definition class
```

**Organization Principles:**
- **managers/**: Local orchestrators for specific gameplay areas
- **ui/**: Visual UI components (panels, HUDs)
- **[Feature]/**: System-specific data classes (dialogue, areas, shops, dungeons, quests)
- **utilities/**: Shared helper classes and wrappers
- **resources/**: Base classes for game content definitions

---

### `data/` - Game Content Resources
.tres (resource) files containing game content. Organized by type for easy content creation and management.

```
data/
├── characters/               # Character definitions
│   ├── aria.tres            # Protagonist
│   ├── elara.tres           # Companion
│   ├── freya.tres           # Companion
│   ├── lyra.tres            # Companion
│   ├── selene.tres          # Companion
│   ├── vivienne.tres        # Companion
│   └── ...more characters
│
├── skills/                   # Skill definitions
│   ├── slash.tres           # Basic attack skill
│   ├── fireball.tres        # Magical skill
│   └── ...more skills
│
├── skill_trees/             # Character-specific skill trees
│   ├── aria_skills.tres     # Aria's skill progression
│   └── ...more skill trees
│
├── items/                    # Consumable and equipment items
│   ├── small_potion.tres    # Basic healing
│   ├── large_potion.tres    # Enhanced healing
│   ├── mana_potion.tres     # MP restoration
│   ├── wooden_sword.tres    # Starting weapon
│   ├── iron_sword.tres      # Mid-game weapon
│   └── ...more items
│
├── dialogues/               # NPC dialogue and branching conversations
│   ├── aria_intro.tres      # Aria introduction dialogue
│   └── ...more dialogues
│
├── quests/                  # Quest definitions
│   ├── find_elara.tres      # Main quest
│   ├── defeat_bandits.tres  # Side quest
│   ├── forest_exploration.tres # Exploration quest
│   ├── potion_delivery.tres # Delivery quest
│   ├── bandit_camp.tres     # Combat quest
│   └── companion/
│       └── lyra_mystery.tres # Companion quest
│
├── areas/                   # World area definitions
│   ├── village.tres         # Starting village
│   ├── forest.tres          # Forest area
│   └── ...more areas
│
├── dungeons/                # Dungeon definitions
│   ├── shadow_crypt.tres    # Multi-floor dungeon
│   └── goblin_caves.tres    # Starter dungeon
│
└── shops/                   # Shop definitions
    ├── weapon_smith.tres    # Weapon shop
    └── healer_potions.tres  # Potion shop
```

**Content Organization:**
- Each file type has its own category
- Similar content grouped together for easy discovery
- Quest subfolder (companion/) for specialized quests

---

### `scenes/` - Game Scene Files
Godot scene (.tscn) files for different game areas and interfaces.

```
scenes/
├── title/                    # Title screen
│   ├── TitleScreen.tscn
│   └── title_screen.gd
│
├── battle/                   # Battle system scenes
│   ├── Battle.tscn
│   └── battle.gd
│
└── World/                    # World exploration
    ├── WorldMap.tscn        # Main world map
    ├── treasure_chest.tscn  # Treasure chest interaction
    └── treasure_chest.gd    # Chest logic
```

---

### `ui/` - UI Scene Files
Root-level UI scene components (scene files, not scripts).

```
ui/
├── [Future: dialogue_panel.tscn]
├── [Future: battle_panel.tscn]
├── [Future: quest_log_panel.tscn]
├── [Future: shop_panel.tscn]
└── [Future: inventory_panel.tscn]
```

**Note:** UI GDScript classes are in `scripts/ui/`. Scene files (.tscn) will be added here.

---

### `assets/` - Visual Resources
Graphics, sprites, and other visual assets (reserved for future expansion).

```
assets/
└── [Future: sprites, backgrounds, visual effects]
```

---

### `audio/` - Audio Resources
Music tracks and sound effects (reserved for future expansion).

```
audio/
└── [Future: music files (.ogg), SFX files]
```

---

## Key File Categories

### Autoload Managers (16 total)

| Manager | Category | Responsibility |
|---------|----------|-----------------|
| **GameState** | State | Core game data (party, gold, progression) |
| **SaveManager** | State | Game persistence (JSON save/load) |
| **InventoryManager** | State | Player inventory and items |
| **CorruptionManager** | Systems | 5-stage corruption mechanic |
| **EventManager** | Systems | Quest tracking and story flags |
| **DialogueManager** | Systems | NPC dialogue orchestration |
| **AreaManager** | Systems | World exploration and transitions |
| **AudioManager** | Services | Music and SFX management |
| **BondManager** | Services | Companion relationship system |
| **EffectsManager** | Services | Visual effects (fade, shake, flash) |
| **ShopManager** | Services | Buy/sell transactions |
| **SkillTreeManager** | Services | Character skill unlocking |
| **DungeonManager** | Services | Multi-floor dungeon progression |
| **AnimationManager** | Services | Battle animation playback |
| **TimeManager** | Services | 24-hour day/night cycle |
| **CompanionQuestManager** | Services | Companion-specific story quests |

### Script Organization

| Folder | Purpose | Examples |
|--------|---------|----------|
| **managers/** | Gameplay orchestration | Battle, player input, world interaction |
| **ui/** | Visual UI components | Dialogue panel, battle HUD, quest log |
| **characters/** | Character systems | Character data, stats, leveling |
| **utilities/** | Helper classes | Combat units, skill trees, battle UI utils |
| **[system]/** | Feature-specific data | Dialogue, areas, shops, dungeons, quests |
| **resources/** | Base resource classes | Items, skills, bosses |

### Data Organization

| Folder | Content Type | Purpose |
|--------|--------------|---------|
| **characters/** | Character resources | Define playable and NPC characters |
| **skills/** | Skill definitions | Attack, magic, support abilities |
| **skill_trees/** | Progression paths | Character-specific skill progression |
| **items/** | Equipment & consumables | Weapons, armor, potions |
| **dialogues/** | Conversation trees | NPC dialogue with branching options |
| **quests/** | Quest definitions | Main, side, and companion quests |
| **areas/** | World definitions | Explorable locations and encounters |
| **dungeons/** | Dungeon definitions | Multi-floor challenge areas |
| **shops/** | Shop definitions | Merchant inventories and prices |

---

## System Architecture Overview

### Signal-Based Communication
Systems use Godot signals for decoupled communication:

```
AreaManager → signals area_changed, enemy_encountered
EventManager → signals quest_started, quest_completed
DialogueManager → signals dialogue_started, option_selected
ShopManager → signals item_purchased, item_sold
BondManager → signals bond_increased
TimeManager → signals time_changed, day_changed
AudioManager → signals music_changed, sfx_played
```

### Manager Dependencies
```
GameState (base)
├── SaveManager (reads/writes GameState)
├── InventoryManager (tracks items)
├── EventManager (tracks quest progress)
│   └── CompanionQuestManager (companion quests)
├── DialogueManager (story interactions)
├── AreaManager (world exploration)
├── BondManager (relationship tracking)
├── ShopManager (transactions)
├── SkillTreeManager (progression)
├── DungeonManager (dungeon progress)
├── TimeManager (day/night cycle)
├── CorruptionManager (stat penalties)
├── AudioManager (sound/music)
├── EffectsManager (visual effects)
└── AnimationManager (battle animations)
```

---

## File Naming Conventions

| File Type | Pattern | Example |
|-----------|---------|---------|
| **GDScript** | snake_case.gd | character_data.gd |
| **Resource** | snake_case.tres | iron_sword.tres |
| **Scene** | PascalCase.tscn | BattlePanel.tscn |
| **Folder** | snake_case/ | skill_trees/ |
| **UID file** | basename.gd.uid | character_data.gd.uid |

---

## How to Add New Content

### Adding a New Quest
1. Create: `data/quests/quest_name.tres`
2. Extend: `QuestData` class
3. Configure: Name, description, stages, rewards
4. Reference: In `EventManager.gd` or dialogue options

### Adding a New Shop
1. Create: `data/shops/shop_name.tres`
2. Extend: `ShopData` class
3. Configure: Shop name, items, prices, stock
4. Reference: In `AreaManager` or through world manager

### Adding a New Dungeon
1. Create: `data/dungeons/dungeon_name.tres`
2. Extend: `DungeonData` class
3. Configure: Floors, enemies, boss encounters, rewards
4. Reference: Through `DungeonManager` or area transitions

### Adding a New Dialogue
1. Create: `data/dialogues/dialogue_name.tres`
2. Extend: `DialogueData` class
3. Configure: Speaker, text, options, actions
4. Reference: In NPC interactions or quest events

---

## Benefits of This Organization

✅ **Clear Separation of Concerns** - Each folder has a specific responsibility
✅ **Scalability** - Easy to add new content, managers, or UI components
✅ **Discoverability** - New developers can quickly locate relevant code
✅ **Maintainability** - Related code and content grouped together
✅ **Testing** - Isolated systems are easier to test
✅ **Reusability** - Clear interfaces enable code reuse
✅ **Documentation** - Folder structure self-documents the codebase

---

## Quick Reference: Where to Find Things

| What | Where |
|------|-------|
| **Character data** | `data/characters/` or `scripts/characters/` |
| **Quest logic** | `autoload/systems/event_manager.gd` or `scripts/quests/` |
| **Combat logic** | `scripts/managers/battle_manager.gd` |
| **UI components** | `scripts/ui/` |
| **Quest resources** | `data/quests/` |
| **Item definitions** | `data/items/` |
| **Shop definitions** | `data/shops/` |
| **Dungeon definitions** | `data/dungeons/` |
| **Dialogue trees** | `data/dialogues/` |
| **Game state** | `autoload/state/game_state.gd` |
| **Audio management** | `autoload/services/audio_manager.gd` |
| **Day/night cycle** | `autoload/services/time_manager.gd` |
| **Companion bonding** | `autoload/services/bond_manager.gd` |
| **Skill progression** | `autoload/services/skill_tree_manager.gd` |

---

## Future Organization Considerations

- **Localization** folder for multi-language support
- **Tests** folder for unit and integration tests
- **Config** folder for balance and difficulty settings
- **Documentation** folder for detailed system documentation
- **Mods** folder structure if modding support is added

---

*Last Updated: 2026-06-25*
*Version: 1.0 - Complete File Organization*
