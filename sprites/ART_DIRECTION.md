# VeinCraft Art Direction

## Visual Tone: Cute Medieval Fantasy

Inspired by the **Tiny Swords** art pack. Think Studio Ghibli meets Clash Royale —
whimsical, colorful, approachable, but with a fantasy-war undertone.

## Style Rules

### Characters
- **Proportions**: Chibi — oversized head (60% of body), stubby limbs
- **Outlines**: Thick dark outlines (near-black, RGB ~0,0,32), 2-3px at 192px
- **Shading**: Soft 2-3 tone shading, no harsh gradients
- **Eyes**: Simple dots or small ovals, expressive
- **View**: 3/4 isometric (slightly above, angled)
- **Size**: Characters occupy ~60-70% of their frame, centered

### Color Palette
| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Outline | Near-black blue | #000020 | All outlines, darkest shadow |
| Shadow | Dark grey | #404040 | Secondary shadows |
| Skin Light | Warm cream | #E0E0A0 | Highlights on skin/cloth |
| Skin Mid | Sandy brown | #C0A060 | Base skin/cloth tone |
| Skin Dark | Muted mauve | #806060 | Skin shadows |
| Cool Accent | Steel blue | #406080 | Metal, armor, cool elements |
| Warm Brown | Earth brown | #806040 | Wood, leather, ground |
| Gold | Warm yellow | #C0C040 | Gold, treasure, highlights |
| Earth | Deep ochre | #A08040 | Dirt, path, terrain |
| Ice | Pale teal | #A0C0C0 | Frost effects, water |

### Terrain
- **Grass**: Bright green with subtle texture variation (Tiny Swords tilemap)
- **Path**: Warm brown dirt (#8C6B47), solid fill
- **Trees**: Evergreen pines, animated sway (8 frames)
- **Rocks**: Blue-grey boulders, 2 variants
- **Grid lines**: Subtle, low opacity (0.3 alpha)

### Towers
- **Style**: Pixel art machinery/structures, same outline weight as characters
- **Size**: Fit within 56x56 display area in 90px cells
- **Colors**: Each tower type has a distinct hue (red, brown, blue, purple)

### Enemies
- **Walk cycle**: 4-6 frames per direction
- **Status effects**: Visual change (blue tint = frozen, spark overlay = shocked)
- **Death**: Collapse + fade animation
- **Types distinguished by**: Color, size, silhouette, accessories

### UI
- **HUD panel**: Dark semi-transparent (0.1, 0.1, 0.12, 0.9)
- **Text**: Clean sans-serif, white/colored for emphasis
- **Hearts**: Red filled / grey empty
- **Gold**: Yellow with $ prefix
- **Buttons**: Dark with clear text, disabled = dimmed

## DO
- Keep outlines thick and consistent
- Use muted, earthy tones with occasional bright accents
- Make silhouettes readable at small sizes
- Add subtle animations (tree sway, idle bounce)

## DON'T
- Use pure black (#000000) for outlines — use near-black blue
- Use neon/saturated colors (except for UI highlights)
- Make characters too detailed — readability > detail at 64px
- Mix art styles (realistic + chibi)

## Reference
- `sprites/style_guide.png` — visual reference with palette + assets
- `sprites/style_reference.png` — 3 character lineup for Gemini uploads
- `sprites/design/` — individual character turnaround sheets
