# Veilfall: Polish & Transitions Guide

## Overview
This guide documents all polish and transition systems implemented to enhance the visual and interactive quality of Veilfall.

---

## 1. TransitionManager

A dedicated autoload for managing all screen transitions and UI animations.

### Features

#### Scene Transitions
```gdscript
# Fade to black over 0.5 seconds
await TransitionManager.fade_out(0.5)

# Fade in from black
await TransitionManager.fade_in(0.5)

# Complete fade transition (out then in)
await TransitionManager.fade_transition(0.5)
```

#### Slide Transitions
```gdscript
# Slide from right, duration 0.4 seconds
await TransitionManager.slide_transition(Vector2.RIGHT, 0.4)
```

#### UI Panel Animations
```gdscript
# Smooth fade-in with upward motion
await TransitionManager.animate_panel_show(panel, 0.3, Vector2(0, 20))

# Smooth fade-out with downward motion
await TransitionManager.animate_panel_hide(panel, 0.3, Vector2(0, 20))
```

#### Emphasis Effects
```gdscript
# Bounce animation
await TransitionManager.bounce_animation(node, 0.3, 10.0)

# Pulse animation (scale and fade)
await TransitionManager.pulse_animation(node, 0.2, 1.1)
```

#### Menu Polish
```gdscript
# Highlight menu item when selected
TransitionManager.highlight_menu_item(item, true, 0.2)

# Unhighlight when deselected
TransitionManager.highlight_menu_item(item, false, 0.2)
```

#### Text Effects
```gdscript
# Typewriter effect for text
await TransitionManager.typewriter_effect(label, "Long dialogue text", 0.05)
```

---

## 2. Enhanced EffectsManager

Expanded visual effects system with particle-like animations.

### Particle Effects

#### Slash Effect
```gdscript
# Animated slash lines at position
EffectsManager.spawn_particle_effect("slash", Vector2(100, 100))
```

#### Heal Effect
```gdscript
# Green sparkles radiating outward
EffectsManager.spawn_particle_effect("heal", Vector2(100, 100))
```

#### Spell Effect
```gdscript
# Cyan magical aura expanding
EffectsManager.spawn_particle_effect("spell", Vector2(100, 100))
```

#### Impact Effect
```gdscript
# White impact radiating circles
EffectsManager.spawn_particle_effect("impact", Vector2(100, 100))
```

### Screen Effects (Existing)

```gdscript
# Fade screen to black
await EffectsManager.fade_to_black(1.0, 0.5)

# Screen shake
await EffectsManager.screen_shake(5.0, 0.5)

# Flash screen with color
await EffectsManager.flash_screen(Color.RED, 0.3)

# Floating damage/heal text
EffectsManager.show_damage_text(Vector2(200, 150), 25, false)  # Damage
EffectsManager.show_damage_text(Vector2(200, 150), 50, true)   # Heal
```

---

## 3. UI Panel Polish

All UI panels now feature smooth transitions and visual enhancements.

### DialoguePanel Enhancements
- ✅ Smooth fade-in when dialogue starts (0.3s cubic ease-out)
- ✅ Character-by-character text animation (0.02s per char)
- ✅ Gold-colored speaker name for emphasis
- ✅ Staggered fade-in for dialogue options
- ✅ Smooth fade-out when dialogue ends (0.3s cubic ease-in)
- ✅ Skip animation with SPACE/ENTER

### BattlePanel Enhancements
- ✅ Initial fade-in when battle starts (0.5s)
- ✅ Yellow turn indicator for clarity
- ✅ Cyan-colored character names
- ✅ Color-coded status (red for low HP, yellow for medium, green for high)
- ✅ HP bar pulse animation on creation

### QuestLogPanel Enhancements
- ✅ Gold-colored title
- ✅ Smooth fade-in on show (0.3s)
- ✅ Smooth fade-out on close (0.3s)
- ✅ Panel starts hidden with alpha=0

### ShopPanel Enhancements
- ✅ Gold shop name and yellow gold display
- ✅ Panel starts hidden for fade-in
- ✅ Color-coded pricing feedback

### InventoryPanel Enhancements
- ✅ Gold-colored title
- ✅ Panel starts hidden for fade-in
- ✅ Staggered item list animation

---

## 4. AnimationManager Polish

Enhanced character animations for battle sequences.

### Attack Animation
```gdscript
# Character moves forward, flashes white, returns
await AnimationManager.play_attack_animation("aria", 0.5)
```

### Skill Animations
```gdscript
# Magic: spin and glow yellow
await AnimationManager.play_skill_animation("aria", "magic", 0.6)

# Heal: scale up with green glow
await AnimationManager.play_skill_animation("aria", "heal", 0.6)

# Buff: pulse with cyan glow
await AnimationManager.play_skill_animation("aria", "buff", 0.6)
```

### Damage Animation
```gdscript
# Knockback and red flash
await AnimationManager.play_damage_animation("aria", 25, 0.4)
```

### Victory Animation
```gdscript
# Jump and celebration
await AnimationManager.play_victory_animation("aria", 0.8)
```

### Defeat Animation
```gdscript
# Collapse and fade
await AnimationManager.play_defeat_animation("aria", 1.0)
```

---

## 5. Tween Configuration Best Practices

### Easing Functions
- `TRANS_CUBIC` - Smooth, natural motion (most UI animations)
- `TRANS_QUAD` - Faster, more responsive (quick actions)
- `TRANS_BOUNCE` - Fun, bouncy emphasis (selections)

### Easing Types
- `EASE_OUT` - Starts fast, slows down (fade-in, appearing)
- `EASE_IN` - Starts slow, speeds up (fade-out, disappearing)
- `EASE_IN_OUT` - Starts and ends slow (transitions)

### Parallel Animations
```gdscript
var tween = create_tween()
tween.set_parallel(true)  # Run animations simultaneously

tween.tween_property(panel, "modulate:a", 1.0, 0.3)
tween.tween_property(panel, "position:y", panel.position.y - 20, 0.3)

tween.set_parallel(false)  # Sequential from here on
```

---

## 6. Polish Checklist

### ✅ Completed
- [x] TransitionManager with fade/slide effects
- [x] Enhanced particle effects (slash, heal, spell, impact)
- [x] DialoguePanel smooth animations
- [x] BattlePanel fade-in and color coding
- [x] QuestLogPanel transitions
- [x] ShopPanel and InventoryPanel styling
- [x] Color-coded UI elements (gold titles, cyan names, yellow status)
- [x] AnimationManager effect enhancements

### 🔄 Next (Optional Enhancements)
- [ ] Scene transition animations between areas
- [ ] Menu background animations
- [ ] Damage number pop-up sequences
- [ ] Critical hit visual effects (enhanced flash)
- [ ] Level-up animation sequence
- [ ] Equipment equip/unequip animations
- [ ] Particle system for area transitions

---

## 7. Polish Integration Examples

### Complete Dialogue Flow
```gdscript
# Dialogue starts with fade-in
DialogueManager.start_dialogue("npc_intro")

# Options appear with staggered animation
# Player selects option

# Dialogue fades out smoothly
# Next scene or action begins
```

### Complete Battle Flow
```gdscript
# Battle panel fades in
# Character animations play with effects

# Attack: move forward + white flash
# Skill: spin/glow based on type
# Damage taken: knockback + red flash
# Victory: celebration animation

# Battle panel fades out
```

### Complete Shop Flow
```gdscript
# Shop panel fades in
# Items list with hover highlights

# Purchase with visual feedback
# Gold updated with smooth animation
# Items added to inventory

# Shop panel fades out
```

---

## 8. Audio Polish Integration (Future)

When audio is integrated, these transitions can be paired with:

- **Fade transitions** ↔ Music crossfade
- **Battle start** ↔ Battle music SFX
- **Victory animation** ↔ Victory fanfare
- **Dialogue open** ↔ Dialogue UI sound
- **Menu navigation** ↔ Menu cursor sound

---

## 9. Performance Considerations

### Tween Limits
- Typical scene: 5-15 simultaneous tweens (safe)
- Busy scenes: Keep under 30 tweens
- For mobile: Reduce animation duration by 20%

### Particle Effects
- Max 8-10 particle spawns per second
- Effects auto-clean up after completion
- Queue free ensures no memory leaks

### UI Animations
- All panels use opacity for visibility (no visibility toggles)
- Animations complete before destruction
- Staggered animations prevent UI lag

---

## 10. Configuration Constants

### Recommended Durations
```gdscript
# Quick feedback
const QUICK_FADE = 0.2
const QUICK_SLIDE = 0.3

# Standard transitions
const STANDARD_FADE = 0.5
const STANDARD_SLIDE = 0.4

# Slow/dramatic
const SLOW_FADE = 0.8
const SLOW_SLIDE = 0.6

# Battle animations
const ATTACK_DURATION = 0.5
const SKILL_DURATION = 0.6
const DAMAGE_DURATION = 0.4
```

### Color Palette
```gdscript
const COLOR_TITLE = Color.GOLD        # Titles and headers
const COLOR_NAME = Color.CYAN         # Character/NPC names
const COLOR_GOOD = Color.GREEN        # Healing, buffs
const COLOR_BAD = Color.RED           # Damage, debuffs
const COLOR_EMPHASIS = Color.YELLOW   # Status, highlights
```

---

## 11. Testing Checklist

- [ ] All transitions play smoothly without stuttering
- [ ] UI panels fade in/out correctly
- [ ] Text animation can be skipped
- [ ] Colors are readable and consistent
- [ ] Animations don't overlap awkwardly
- [ ] Particle effects clean up properly
- [ ] Battle animations sync with combat logic
- [ ] Menu highlights work on all devices

---

*Last Updated: 2026-06-25*
*Version: 1.0 - Complete Polish & Transitions*
