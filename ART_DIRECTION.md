# Veilfall: Corruption of the Kingdom — Art Direction

## Visual identity
Veilfall uses an original mature dark-fantasy JRPG aesthetic. Reference material is inspiration for mood, presentation, composition, and production targets only; final assets must be original.

### Core pillars
- Top-down 2D exploration with richly illustrated medieval environments.
- Gothic architecture, old stone, timber, ironwork, ruined shrines, forests, dungeons, villages, castles, and corrupted wilderness.
- Moody nighttime and interior lighting with warm lantern/fire contrast against cool moonlight.
- Corruption is visually identified with violet/magenta supernatural light, dark organic veins, warped vegetation, particles, and environmental decay.
- Adult anime-inspired character designs with strong silhouettes and readable costumes at gameplay scale.
- Ornate gothic UI: charcoal/black panels, silver filigree, restrained violet accents, parchment elements, and high-contrast readable text.

## Player character direction
The heroine must remain recognizable in both portrait art and top-down gameplay sprites. Use a mature adult fantasy-adventurer silhouette, pale/light costume values contrasted by dark accessories/armor, practical adventuring equipment, and a distinct head/hair silhouette. Gameplay sprites prioritize readability over portrait-level detail.

Required player asset groups:
- overworld idle/walk sprites: down, left, right, up
- battle idle and combat poses
- dialogue portrait: neutral, determined, worried, hurt, corrupted states
- menu/status portrait
- capture/escape gameplay state variants where needed

## Environment asset groups
### Greyhaven outskirts
- grass and dark-earth tiles
- worn north-road tiles and edge transitions
- dense evergreen/deciduous trees
- dead/corrupted trees
- rocks, roots, weeds, shrubs, flowers
- ruined stone shrine/building pieces
- fences, signs, lanterns, carts, barrels/crates
- corruption ground overlays and veins
- treasure chest variants

### Future sets
- Greyhaven town
- castle/interiors
- deep forest
- caves/mines
- prison/dungeon
- corrupted zones

## Technical pipeline
Final raster assets should live under `assets/art/` and be referenced by scenes rather than embedding art logic in gameplay scripts.

Suggested layout:
- `assets/art/characters/player/`
- `assets/art/characters/companions/`
- `assets/art/characters/enemies/`
- `assets/art/world/greyhaven/`
- `assets/art/world/shared/`
- `assets/art/ui/`
- `assets/art/fx/`

World scenes should keep collision, interactions, quests, encounters, and navigation independent from visual sprites. This allows art to be replaced without breaking gameplay.

## Scene layering standard
World scenes should use this conceptual order:
1. Ground
2. GroundDetail
3. CorruptionBelow
4. StructuresBelow
5. Actors
6. StructuresAbove
7. Foreground
8. WeatherFX
9. Lighting
10. HUD

## Import targets
- PNG with transparency for sprites and props.
- Consistent pixels-per-unit within each asset family.
- Nearest filtering for pixel-art assets; linear filtering for illustrated/high-resolution assets.
- Avoid baking collision into artwork.
- Keep source art and exported game-ready art clearly separated if source files are later added.

## Production rule
Do not replace functional gameplay with temporary visual hacks. Preserve the working game while upgrading one visual system at a time.