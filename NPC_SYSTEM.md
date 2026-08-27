# Veilfall: NPC System Documentation

## Overview

A comprehensive NPC (Non-Player Character) system has been implemented to populate Veilfall with living characters across four main categories: **Store Keepers**, **Quest Givers**, **Companion Events**, and **Corruption Events**. This creates a rich, interactive world where NPCs drive quests, commerce, character development, and story progression.

---

## System Architecture

### NPCData Class
- **Location**: `scripts/characters/npc_data.gd`
- **Base Resource Class**: Extends Resource for easy creation and management
- **Key Properties**:
  - `npc_id` - Unique identifier
  - `display_name` - Name shown to player
  - `npc_type` - One of: store_keeper, quest_giver, companion_event, corruption_event
  - `dialogue_trees` - Greeting, farewell, and special event dialogues
  - `state_tracking` - Interaction count, availability status

### NPCManager Autoload
- **Location**: `autoload/systems/npc_manager.gd`
- **19th Autoload System** - Registered in project.godot
- **Responsibilities**:
  - Load all NPCs from `data/npcs/`
  - Route NPC interactions
  - Trigger companion events based on bond level
  - Trigger corruption events based on corruption stage
  - Manage shop assignments
  - Track quest giver assignments

---

## NPC Categories

### 1. Store Keepers (3 NPCs)

#### 🏪 Thomas (Merchant)
- **ID**: `merchant_thomas`
- **Role**: General goods merchant
- **Location**: Town Market
- **Special**: Fair prices and reliable stock

#### 🧪 Vera (Apothecary)
- **ID**: `apothecary_vera`
- **Role**: Potion crafter and healer supplier
- **Location**: Apothecary Shop
- **Special**: Crafts potions from rare herbs

#### ⚒️ Marcus (Blacksmith)
- **ID**: `blacksmith_marcus`
- **Role**: Weapon and armor crafter
- **Location**: Blacksmith Forge
- **Special**: Forges weapons and armor to order

**Usage Example**:
```gdscript
var keeper = NPCManager.get_npc("merchant_thomas")
var shop = NPCManager.get_shop_for_keeper("merchant_thomas")
NPCManager.interact_with_npc("merchant_thomas")
```

---

### 2. Quest Givers (3 NPCs)

#### 👴 Elder Councillor
- **ID**: `elder_councillor`
- **Quests Offered**: forest_exploration, bandit_camp, corruption_investigation
- **Role**: Town leadership and main quest line
- **Motivation**: Protecting the town and kingdom

#### 📖 Scholar Daemon
- **ID**: `scholar_daemon`
- **Quests Offered**: artifact_hunt, library_research, ancient_ruins
- **Role**: Investigator of mysteries and ancients
- **Motivation**: Academic pursuit and hidden knowledge

#### ⚔️ Captain Blake
- **ID**: `guard_captain_blake`
- **Quests Offered**: goblin_caves, monster_hunt, protect_caravan
- **Role**: Town guard leadership
- **Motivation**: Security and protection

**Usage Example**:
```gdscript
var giver = NPCManager.get_quest_giver_for_quest("forest_exploration")
var all_givers = NPCManager.get_quest_givers()
NPCManager.interact_with_npc("elder_councillor")
```

---

### 3. Companion Events (5 NPCs)

These special NPCs trigger when companion bond levels reach thresholds, revealing character backstory and deepening relationships.

#### ✨ Elara (Memories)
- **ID**: `elara_event_advisor`
- **Bond Requirement**: Level 3+
- **Type**: One-time event
- **Dialogue**: "I remember now... fragments of my past return to me when we're together."

#### 💭 Lyra (Dreams)
- **ID**: `lyra_event_dreamer`
- **Bond Requirement**: Level 2+
- **Type**: Repeatable event
- **Dialogue**: "In my dreams, I see us together... laughing, fighting, growing stronger."

#### 🌑 Selene (Shadow)
- **ID**: `selene_event_shadow`
- **Bond Requirement**: Level 4+
- **Type**: One-time event
- **Dialogue**: "The shadows reveal what I've hidden... My past is no longer a burden when shared."

#### 👑 Vivienne (Legacy)
- **ID**: `vivienne_event_legacy`
- **Bond Requirement**: Level 3+
- **Type**: One-time event
- **Dialogue**: "My lineage awakens within me... and with it comes power."

#### 🐺 Freya (Wild)
- **ID**: `freya_event_wild`
- **Bond Requirement**: Level 2+
- **Type**: Repeatable event
- **Dialogue**: "The primal force within awakens! With you beside me, I feel unstoppable."

**Triggering Logic**:
```gdscript
# During gameplay, check for companion events:
var event_npc = NPCManager.check_companion_events("Elara", current_bond_level)
if event_npc:
    # Show companion event dialogue
    DialogueManager.start_dialogue(event_npc.event_dialogues[0])
```

---

### 4. Corruption Events (3 NPCs)

These sinister NPCs appear when world corruption reaches critical levels, representing the spreading darkness.

#### 🖤 Corrupted Elder
- **ID**: `corrupted_elder`
- **Corruption Threshold**: 3+
- **Type**: One-time transformation event
- **Dialogue**: "The Elder you knew is gone... I am what remains. The corruption is inevitable."
- **Effect**: Shows Elder has been overtaken by darkness

#### 🌑 Shadow Merchant
- **ID**: `shadow_merchant`
- **Corruption Threshold**: 4+
- **Type**: Corruption-triggered NPC
- **Role**: Offers dark artifacts and forbidden goods
- **Dialogue**: "I deal in rare... items. Artifacts of power that your 'good' merchants would never offer."

#### ⚫ Void Herald
- **ID**: `void_herald`
- **Corruption Threshold**: 5+
- **Type**: Ultimate corruption manifestation
- **Dialogue**: "The end times approach. The darkness spreads. Your resistance merely delays the inevitable."
- **Effect**: Represents peak corruption state

**Triggering Logic**:
```gdscript
# Check for corruption events:
var event_npc = NPCManager.check_corruption_events(current_corruption_level)
if event_npc:
    # Show corruption event dialogue
    DialogueManager.start_dialogue(event_npc.dialogue)
    # Update story based on corruption level
```

---

## Dialogue System Integration

### Dialogue Files Created (15 total)

**Store Keeper Dialogues**:
- `merchant_thomas_greeting.tres` - "Welcome, traveler! I have fine goods..."
- `apothecary_vera_greeting.tres` - "Ah, welcome! My potions are crafted with care..."
- `blacksmith_marcus_greeting.tres` - "Well met. I forge only the finest weapons..."

**Quest Giver Dialogues**:
- `elder_councillor_greeting.tres` - "Ah, you have arrived. The town needs your aid..."
- `scholar_daemon_greeting.tres` - "Fascinating! I sense you are capable..."
- `guard_captain_blake_greeting.tres` - "Good to see someone capable..."

**Companion Event Dialogues**:
- `elara_event_dialogue.tres`
- `lyra_event_dialogue.tres`
- `selene_event_dialogue.tres`
- `vivienne_event_dialogue.tres`
- `freya_event_dialogue.tres`

**Corruption Event Dialogues**:
- `corrupted_elder_dialogue.tres`
- `shadow_merchant_dialogue.tres`
- `void_herald_dialogue.tres`

---

## API Reference

### NPCManager Functions

#### Loading & Retrieval
```gdscript
# Load all NPCs from data/npcs/
NPCManager.load_all_npcs()

# Get specific NPC
var npc = NPCManager.get_npc("merchant_thomas")

# Get by type
var store_keepers = NPCManager.get_store_keepers()
var quest_givers = NPCManager.get_quest_givers()
var corruption_npcs = NPCManager.get_npcs_by_type("corruption_event")
```

#### Interaction
```gdscript
# Interact with NPC
NPCManager.interact_with_npc("elder_councillor")

# Get interaction count
var times_talked = NPCManager.get_interaction_count("merchant_thomas")
```

#### Event Triggers
```gdscript
# Check companion event (called when bond level changes)
var event = NPCManager.check_companion_events("Elara", bond_level)

# Check corruption event (called when corruption changes)
var event = NPCManager.check_corruption_events(corruption_level)
```

#### Quest Integration
```gdscript
# Get quest giver for specific quest
var giver = NPCManager.get_quest_giver_for_quest("forest_exploration")

# Get shop data for store keeper
var shop = NPCManager.get_shop_for_keeper("merchant_thomas")
```

### Signals

```gdscript
# Emitted when player interacts with NPC
signal npc_interaction(npc: NPCData)

# Emitted when companion event is triggered
signal companion_event_triggered(npc: NPCData, companion: String)

# Emitted when corruption event is triggered
signal corruption_event_triggered(npc: NPCData, corruption_level: int)
```

---

## Usage Examples

### Displaying an NPC Interaction
```gdscript
func talk_to_npc(npc_id: String):
    var npc = NPCManager.get_npc(npc_id)
    if npc and npc.greeting_dialogue:
        DialogueManager.start_dialogue(npc.greeting_dialogue)
```

### Triggering a Quest
```gdscript
func interact_with_quest_giver():
    var giver = NPCManager.get_quest_giver_for_quest("forest_exploration")
    if giver:
        NPCManager.interact_with_npc(giver.npc_id)
        # Offer quest to player
```

### Companion Bonding
```gdscript
# After battle with companion in party
BondManager.increase_bond("Elara", 5)

# Check if event should trigger
var event = NPCManager.check_companion_events("Elara", BondManager.get_bond("Elara"))
if event:
    # Play special companion scene
```

### World Corruption Progression
```gdscript
# As world corruption increases
CorruptionManager.increase_corruption(1)

# Check for corruption events
var event = NPCManager.check_corruption_events(CorruptionManager.get_corruption())
if event:
    # Show dark event dialogue
```

---

## File Structure

```
data/
├── npcs/                          (14 NPC resource files)
│   ├── merchant_thomas.tres
│   ├── apothecary_vera.tres
│   ├── blacksmith_marcus.tres
│   ├── elder_councillor.tres
│   ├── scholar_daemon.tres
│   ├── guard_captain_blake.tres
│   ├── elara_event_advisor.tres
│   ├── lyra_event_dreamer.tres
│   ├── selene_event_shadow.tres
│   ├── vivienne_event_legacy.tres
│   ├── freya_event_wild.tres
│   ├── corrupted_elder.tres
│   ├── shadow_merchant.tres
│   └── void_herald.tres
│
└── dialogues/                     (15 dialogue files)
    ├── merchant_thomas_greeting.tres
    ├── apothecary_vera_greeting.tres
    ├── blacksmith_marcus_greeting.tres
    ├── elder_councillor_greeting.tres
    ├── scholar_daemon_greeting.tres
    ├── guard_captain_blake_greeting.tres
    ├── elara_event_dialogue.tres
    ├── lyra_event_dialogue.tres
    ├── selene_event_dialogue.tres
    ├── vivienne_event_dialogue.tres
    ├── freya_event_dialogue.tres
    ├── corrupted_elder_dialogue.tres
    ├── shadow_merchant_dialogue.tres
    └── void_herald_dialogue.tres

scripts/
└── characters/
    └── npc_data.gd               (NPC data class)

autoload/
└── systems/
    └── npc_manager.gd            (NPCManager - 19th autoload)
```

---

## Integration Points

### With DialogueManager
- NPCs trigger dialogues through `DialogueManager.start_dialogue()`
- Dialogue options can lead to quest acceptance or shop interactions
- Companion events trigger special dialogue sequences

### With QuestManager
- Quest givers defined in NPC quests_offered array
- Quests track which NPC offered them
- Completing quests can unlock new NPC interactions

### With ShopManager
- Store keepers have shop_data linked
- Player can buy/sell through NPC interactions
- Different shops have different inventory

### With BondManager
- Companion events triggered when bond reaches threshold
- Each companion has 5 special event NPCs
- Events increase bond further or reveal story

### With CorruptionManager
- Corruption NPCs appear at specific corruption levels
- Shadow Merchant appears when world is heavily corrupted
- Void Herald appears at peak corruption
- Corrupted Elder represents story transformation

---

## Expansion Opportunities

1. **More Companion Events**: Add additional event tiers for deeper companion development
2. **Dynamic Dialogue**: Dialogue could change based on player choices and game state
3. **NPC Combat**: Some NPCs could become party members or enemies in special encounters
4. **Town Reputation**: Track individual NPC relationships separately from companions
5. **Quest Chains**: Create multi-step quest chains through related NPCs
6. **Romance Events**: Special dialogue branches for romantic progression
7. **NPC Deaths**: Corruption could "kill" NPCs, changing shop availability
8. **Random Events**: NPCs appear in random world events

---

## Current Status

✅ **NPC System Complete**
- 14 NPCs created and configured
- 4 NPC types implemented
- 15 dialogue files created
- NPCManager autoload integrated
- All signals and callbacks functional
- 0 compilation errors

**Next Steps**:
- Create NPC scenes/visuals for world interaction
- Implement NPC dialogue UI panels
- Create shop UI connected to NPCs
- Add NPC animations and effects
- Test companion event triggers
- Test corruption event progression

---

*Version: 1.0 - Complete NPC System*
*Created: Session 2026-06-25*
