# Greyhaven combat slice — first integration pass

Branch: art-overhaul. Status: CODE ADDED; GODOT 4.7 RUNTIME TEST REQUIRED.

## Current player loop

1. New Game launches Greyhaven. Move with arrows, Z to interact, X for world status.
2. Take the roadside chest (3 small potions). Approach red markers on the east road:
   - Goblin Scout (1180, 945)
   - Forest Wolf (1345, 1090)
   - Bandit Guard (1510, 770)
3. Press Z at a marker to enter the battle scene. Use on-screen action buttons for Attack, Skill, Item, Defend, and Struggle/Rescue when grabbed.
4. Victories grant XP/gold, any eligible loot, and mark each encounter complete. The world returns near the marker.
5. Defeat returns the party at half HP for retry. Saved completed markers remain cleared after Continue.
6. HUD shows 0/3 through 3/3 Greyhaven patrols; all three are optional and repeatable only after a New Game.

## Tests to run in Godot 4.7

- Import on art-overhaul and resolve ANY parse/resource warnings before playing.
- Run: godot --headless --path . --scene res://tests/manual/greyhaven_battle_smoke_test.tscn
- Run existing shop test: godot --headless --path . --scene res://tests/manual/shop_sell_smoke_test.tscn
- New Game → loot roadside chest → fight Goblin Scout → win → verify XP/gold and marker gone.
- Use one small potion in combat; verify exactly one is removed and HP rises. Re-enter combat without potions to verify no free heal and no lost turn.
- Use Arcane Strike (requires 15 MP); verify MP decreases and enemy HP decreases.
- Verify enemy grab warning, forced Struggle selection, escape by second attempt; recruit an ally and verify Rescue when available.
- Lose to an encounter; confirm player returns alive, can retry, and the failed marker remains.
- Quit/relaunch → Continue; verify restored chest/encounter completion and saved return position.
- New Game again; verify counters and completed markers reset.
- Check error/warning output, controller/mouse interaction, and the original art/collision.
- Verify no regression to separate boss scenes, scripted defeat events, or equipment/stats.

## Explicit limits / remaining gates

This is a first battle/overworld integration, not a completed 15–30-minute vertical slice. It currently has three single-enemy markers and lacks an NPC-directed quest, dialogue/companion onboarding, full capture outcomes, enemy-specific grab AI, encounter art, battle animations, and polished encounter pacing. Grab is a reversible in-battle restraint state, not a full story capture. The old README/test report cannot substitute for running the game. No automated pass/CI claim is made until Godot runs.
