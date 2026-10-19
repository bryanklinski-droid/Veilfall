# Veilfall: Corruption of the Kingdom — Production Roadmap

Last planned: 2026-10-19
Engine: Godot 4.7 | Working branch: `art-overhaul` | Stable target: `main`
Goal: Finish an original, stable dark-fantasy 2D JRPG with mature themes, compelling story and companions, polished anime-inspired presentation, and meaningful corruption progression.

## Important starting point

This is a **work queue, not a claim that each listed feature is broken or absent**.
Reassess live scene execution and asset quality before marking work complete. The repository already includes foundations for battle, saving, inventory, shops, quests, NPCs, companions, corruption, elite enemies and bosses, as well as Greyhaven scenes and art. Many are not confirmed functional together. Old `TEST_REPORT.md` and `BALANCE_IMPLEMENTATION.md` contain historical claims that must not replace testing.

`art-overhaul` and `main` have diverged. Compare existing fixes and selectively port them instead of overwriting artwork or merging blindly.

## Build order and acceptance gates

### Milestone 0 — Establish a reliable development baseline (P0)
- [ ] Import `art-overhaul` in Godot 4.7 and run the project; capture complete warnings/errors.
- [ ] Validate project autoload paths and `uid://`/resource references and the main title → Greyhaven scene transition.
- [ ] Inventory existing features and unresolved bugs against *actual* runtime behavior.
- [ ] Compare `main` fixes and tests against `art-overhaul` and port missing protections deliberately.
- [ ] Add repeatable smoke tests or CI for critical game code where practical.
- [ ] Document reproducible bugs with exact steps and severity.
**Gate:** Project launches, no critical parse/runtime errors, known critical bugs have assigned next actions.

### Milestone 1 — A stable playable Greyhaven loop (P0)
- [ ] Verify arrow-key movement, Z interaction, X menu and scene collisions/navigation.
- [ ] Verify New Game resets *all* state, Continue loads the correct area and safe saves persist across restarts.
- [ ] Verify chest collection is one-time, inventory stays consistent and shops cannot create unlimited gold.
- [ ] Verify quest NPC interaction, dialogue, accepting/completing a quest, and reward persistence.
- [ ] Connect visible exploration encounters to functional turn-based battle, victory/defeat and item/XP/gold rewards.
- [ ] Verify at least one recruitable companion and a bond or corruption state change from regular play.
- [ ] Deliver an understandable first objective with a beginning, gameplay loop and resolution.
**Gate:** A tester can play a complete 15–30 minute Greyhaven experience without debug commands, dead ends or critical errors.

### Milestone 2 — Combat depth and progression (P1)
- [ ] Validate enemy roster/resources, encounter spawning, targeting, damage, status effects and progression.
- [ ] Integrate varied regular enemies, elites, minibosses, and scripted multiphase bosses.
- [ ] Polish skill selection, items in combat, feedback, combat animation and battle HUD.
- [ ] Tune economy, XP, rewards, equipment, consumables and difficulty against actual playtests.
- [ ] Test win, lose, retreat, retry and save/load boundaries, including defeat event behavior.
**Gate:** Multiple enemy roles and a memorable boss reward good tactical play with no combat softlocks.

### Milestone 3 — Story, companions, corruption and mature content (P1)
- [ ] Outline a complete main story with beginning, escalation, climax and ending, plus meaningful branching.
- [ ] Develop Aria and the main companions with recruitment, bonds, individual quest arcs and expressive dialogue.
- [ ] Integrate world and character corruption, consequences, choice feedback and defeat/capture recovery routes.
- [ ] Write consistent dialogue, quest flags, NPC scheduling and alternate outcomes; avoid unreachable events.
- [ ] Ensure adult-only content and cast eligibility are verified where relevant; use clear boundaries and platform-compliant packaging.
**Gate:** Major systems affect the narrative, and the story can be played from start through conclusion.

### Milestone 4 — Original art and world expansion (P1)
- [ ] Lock art scale, asset pipeline, color palette, art naming and scene layering.
- [ ] Finish Greyhaven's terrain, paths, readable buildings, interiors, props, lanterns, environmental depth and lighting.
- [ ] Create consistent original top-down character sprites, NPC/enemy battle images, portraits and clear reaction/expression sets.
- [ ] Integrate readable violet/magenta corruption effects, atmospheric FX and restrained animation.
- [ ] Expand to additional towns, forests, ruins, dungeons and castles *only after* Greyhaven's loop is working.
- [ ] Keep collisions, interaction hooks, navigation and game logic separate from replaceable art.
**Gate:** Every playable scene has coherent visuals, clear navigation and matching gameplay interactions.

### Milestone 5 — Content-complete game (P2)
- [ ] Finish major maps, dungeons, NPCs, enemy families, elites, minibosses and final bosses.
- [ ] Finish side quests, companion content, endings, rewards, shops and progression pacing.
- [ ] Fill missing original music, ambience, SFX, transitions, UI iconography and status feedback.
- [ ] Implement settings, input remapping/accessibility, readable text and appropriate content preferences.
- [ ] Eliminate placeholders, unused assets, misleading menus and broken routes.
**Gate:** Every promised path is start-to-finish playable with final intended content.

### Milestone 6 — QA, packaging and release (P0 to ship)
- [ ] Full playthroughs: new game, Continue, alternate branches, corruption stages and endings.
- [ ] Automated/manual regressions: invalid saves, quest softlocks, inventory exploits, transitions, battle failures and bosses.
- [ ] Optimize loading, FPS, memory, audio, save integrity and project size on intended hardware.
- [ ] Check originality/licensing, adult content classification, warnings and target storefront requirements.
- [ ] Export installable builds, verify clean-machine installs, controller/keyboard and packaging integrity.
- [ ] Collect outside feedback, fix release-blocking issues and prepare a stable tagged release.
**Gate:** A new player can finish the game on a clean build with no critical defects.

## Scheduled operating loop

**Automation cadence:** Every hour, 24/7, at most one scheduled run per hour. This is not continuous CPU activity or a promise of uninterrupted autonomous execution; tasks run only when the scheduler invokes them and when external tools are available.

**Per-run protocol**
1. Read the latest branch head, relevant files, recent commits and this roadmap.
2. Identify the highest-priority incomplete gate, keeping the scope small enough for one safe change.
3. Inspect dependencies before editing; do not overwrite `main` or unrelated files.
4. Implement on `art-overhaul`, preserving existing behavior.
5. Run tests when possible; if Godot is unavailable, state clearly that runtime verification remains pending.
6. Commit changes with a focused message, record blockers and the next exact test/implementation step.
7. Prefer fixing problems and closing gates to inventing endless new features.

**Weekly emphasis (not competing automations)**
- Monday: assess blockers, choose the next milestone work and review changes.
- Tuesday: critical code and game-flow stabilization.
- Wednesday: original art, UI and environments.
- Thursday: encounters, progression, characters, quests and story.
- Friday: integration, manual-test preparation, regression fixes and milestone acceptance.
- Weekend: finish urgent blocking work or polish the next highest-priority gate.

**Backlog rules:** Critical parse/crash/data-loss bugs outrank all art/content. Working gameplay outranks volume of content. Tests/validation outrank a cosmetic change that might cause regressions. A finished playable slice outranks many incomplete features. Stop feature expansion when the game is release-ready.

## Initial verified GitHub work (2026-10-19)
- [x] Ported protection against zero/negative or over-inventory shop sales to `art-overhaul` from `main`.
- [x] Brought `tests/manual/shop_sell_smoke_test.gd` and its test scene into `art-overhaul`.
- [x] Updated `GameState.reset_new_game()` to reset player stats, not only gold/party/corruption.
- [ ] Execute those smoke tests in Godot 4.7 and validate the complete New Game → Continue flow.
- [ ] Verify the current running project, not just repository file contents.

## How to test the shop safeguard in Godot

Use a test copy of game data when possible. In Godot 4.7, open the project on `art-overhaul` and run:
```sh
godot --headless --path . --scene res://tests/manual/shop_sell_smoke_test.tscn
```
The scene is intended to exit with status 0 when all assertions pass. It temporarily snapshots and restores user-save content, but backup of valuable saves is still recommended before running tests.

## Release policy

No fixed launch-date commitment before Milestone 0's runtime baseline. Track progress by proven acceptance criteria rather than file count, generated asset count or schedule run count. External JRPG/mature-game references may guide conventions and user experience; do not copy their protected assets, dialogue, maps or identities.
