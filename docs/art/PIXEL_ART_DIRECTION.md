# Veilfall Pixel Art Direction

## North star
Veilfall's exploration art should use a dense, classic top-down JRPG/RPG Maker-inspired pixel-art presentation. The reference supplied on 2026-08-27 establishes the desired visual language: detailed hand-built village and wilderness maps, compact readable character sprites, richly textured cobble and dirt paths, overlapping vegetation, flowers and weeds, timber/stone architecture, warm practical lights, and strong foreground/background layering.

This is a STYLE AND QUALITY reference only. Do not copy the reference game's characters, buildings, maps, UI, or individual assets. Veilfall needs original designs and its own dark-fantasy identity.

## Pixel language
- Design on a 32 px logical tile grid. Larger props/buildings can span multiple tiles.
- Hard pixel edges: no anti-aliased vector look in final environment assets.
- Nearest-neighbor filtering for pixel assets; integer-friendly scaling whenever practical.
- Use clustered pixels and deliberate shapes rather than single-pixel noise everywhere.
- Use 3-5 value steps per material so forms remain readable at gameplay zoom.
- Avoid perfectly straight/uniform natural borders. Roads, grass, walls, flowers, rubble, and corruption should break their edges organically.

## Environment composition
- Build scenes from connected masses, not isolated icons scattered across a flat field.
- Roads should have edge transitions, embedded stones, weeds, dirt variation, and occasional debris.
- Dense detail belongs near boundaries, buildings, fences, walls, tree lines, and story landmarks.
- Keep navigable/player-reading corridors calmer than the surrounding environment.
- Overlap trees, shrubs, walls, flowers, crates, signs, rocks, and architecture to establish depth.
- Villages should feel inhabited: stacked supplies, barrels, signs, firewood, carts, fences, lamps, gardens, damaged structures, and local clutter.

## Greyhaven palette and mood
- Healthy west/central areas: deep forest greens, desaturated moss, warm brown dirt/wood, cool grey stone, restrained cream/yellow/lilac flowers.
- Corruption moves eastward through a progression: healthy -> neglected -> sick/desaturated -> violet-veined -> heavily corrupted.
- Purple/magenta is an accent and supernatural light source, not a flat replacement color for whole objects.
- Warm lantern/firelight should contrast with cool forest shadows and violet corruption.
- Readability is more important than making the map uniformly dark.

## Architecture
- Top-down three-quarter readability similar to classic JRPG town maps.
- Roofs need multiple value bands, visible material texture, eaves/shadows, and readable entrances.
- Walls should show construction material (timber, plaster, stone) rather than flat shapes.
- Ruins should look structurally damaged before corruption is layered over them.

## Asset conversion order
1. Ground and road tiles / transitions.
2. Grass, weeds, flower beds, stones, rubble, and ground decals.
3. Trees, bushes, forest-edge masses, walls, and fences.
4. Props: lanterns, signs, barrels, crates, carts, camp objects.
5. Buildings and ruins.
6. Corrupted variants and organic spreading overlays.
7. Lighting, shadows, atmospheric overlays, and final detail pass.
8. Character/environment scale reconciliation and sprite polish.

## Implementation rule
Current SVG/procedural assets are composition prototypes. Replace them progressively with original pixel assets while preserving gameplay nodes, collisions, interactions, time/day logic, corruption systems, and UI. Do not rewrite gameplay merely to change the art.
