# Sprite & Character Generation

## Method 1: Gemini AI Sprite Pipeline (Primary)

Automated pipeline for generating consistent game sprites via Google Gemini.

**URL**: https://gemini.google.com/

### Pipeline Steps

#### Step 1: Open Gemini & Upload Style Reference

```
mcp__plugin_playwright_playwright__browser_navigate → https://gemini.google.com/
# Take snapshot, find and click the "Create image" button
# Then upload the style reference image BEFORE typing the prompt
```

**Upload the style reference:**
1. Click the "Open upload file menu" button (the + icon)
2. Upload `res://sprites/style_reference.png` (contains 3 Tiny Swords characters)
3. This ensures Gemini matches the existing art style

The style reference file (`sprites/style_reference.png`) contains single frames
of our 3 existing enemy types (Purple Pawn, Yellow Archer, Black Warrior) from
the Tiny Swords art pack. Gemini uses this to match proportions, color palette,
outline style, shading, and overall aesthetic.

**To regenerate the reference** (if new characters are added):
```gdscript
# Run as Godot editor script
var ref_img = Image.create(576, 256, false, Image.FORMAT_RGBA8)
ref_img.fill(Color(0, 0, 0, 0))
var sources = ["enemy_normal.png", "enemy_fast.png", "enemy_tank.png"]
for i in range(sources.size()):
    var src = Image.load_from_file("res://sprites/" + sources[i])
    var frame = src.get_region(Rect2i(0, 0, 192, 192))
    ref_img.blit_rect(frame, Rect2i(0, 0, 192, 192), Vector2i(i * 192, 32))
ref_img.save_png("res://sprites/style_reference.png")
```

#### Step 2: Submit Standardized Prompt (with reference)

Use this **grid-based** template — fill in `[CHARACTER]`, `[DESCRIPTION]`:

```
The attached image shows 3 characters from our game (Tiny Swords art style).
Match this EXACT art style: cute chibi pixel art with thick dark outlines,
soft shading, small body with oversized head, muted fantasy color palette,
isometric view.

Create a game sprite sheet for a NEW character: [CHARACTER] ([DESCRIPTION]).

Layout the sprite sheet as a GRID like a classic game sprite sheet:
- Row 1: WALK EAST animation (6 frames, walking to the right)
- Row 2: WALK NORTH animation (6 frames, walking upward / away from camera)
- Row 3: WALK SOUTH animation (6 frames, walking downward / toward camera)
- Row 4: WALK WEST animation (6 frames, walking to the left)
- Row 5: FROZEN animation (6 frames, character encased in ice, shivering)
- Row 6: ELECTRIC SHOCK animation (6 frames, character being electrocuted with sparks)
- Row 7: DEATH animation (6 frames, character collapsing and fading)

Each frame should be exactly 64x64 pixels. Total image: 384x448 pixels
(6 columns x 7 rows).
Transparent background. Every frame must have the character centered in
its 64x64 cell.
The character should match the proportions and style of the reference
image exactly.
```

**Variant — Multi-character sheet** (e.g., 4 tower types, single row):
```
The attached image shows characters from our game (Tiny Swords art style).
Match this EXACT art style. Create [N] NEW items/characters in a single row,
each 64x64 pixels (total: [N*64]x64).
From left to right:
1. [Name] — [description]
2. [Name] — [description]
...
```

**Row index reference for code integration:**

| Row | Index | Animation | Frames | Usage |
|-----|-------|-----------|--------|-------|
| 1 | 0 | Walk East | 0–5 | Moving right on path |
| 2 | 1 | Walk North | 6–11 | Moving up on path |
| 3 | 2 | Walk South | 12–17 | Moving down on path |
| 4 | 3 | Walk West | 18–23 | Moving left on path |
| 5 | 4 | Frozen | 24–29 | Hit by Frost tower |
| 6 | 5 | Electric Shock | 30–35 | Hit by Tesla tower |
| 7 | 6 | Death | 36–41 | HP reaches 0 |

**Why this layout works for our TD game:**
- 4 directional walks = natural movement without flip_h hack
- Status effect rows = visual feedback for Frost/Tesla tower hits
- Death animation = replaces programmatic scale tween
- 6x7 grid = 42 frames, comprehensive character coverage
- Easy to slice: `hframes=6, vframes=7`, row = `direction * 6`

#### Step 3: Wait & Download

Gemini takes ~15-30 seconds. Check with screenshot. Then:

```
# The download event auto-fires when running code that references blob images:
mcp__godot-mcp-pro__execute_editor_script  # (or use Playwright run_code)
# Image lands in .playwright-mcp/ as Gemini-Generated-Image-*.png
```

If auto-download doesn't work, click the "Download full size image" button from snapshot.

#### Step 4: Resize (REQUIRED)

Gemini ALWAYS outputs ~4128px wide regardless of prompt. Must resize:

```bash
# For sprite sheets: resize to target dimensions
sips -z [HEIGHT] [WIDTH] path/to/image.png

# Examples:
sips -z 64 256   # 4-frame sheet (4 * 64 = 256)
sips -z 64 384   # 6-frame sheet
sips -z 64 512   # 8-frame sheet
sips -z 64 64    # Single sprite
```

#### Step 5: Remove Checkerboard Background (REQUIRED)

Gemini renders "transparency" as a grey/white checkerboard. Remove it via Godot editor script:

```gdscript
# Run as editor script in Godot
var img = Image.load_from_file("res://sprites/[FILENAME].png")

var removed = 0
for x in range(img.get_width()):
    for y in range(img.get_height()):
        var c = img.get_pixel(x, y)
        var r = int(c.r8)
        var g = int(c.g8)
        var b = int(c.b8)
        var max_diff = max(abs(r - g), max(abs(g - b), abs(r - b)))
        # Grey pixels: R approx G approx B, not too dark or bright
        if max_diff < 25:
            var avg = (r + g + b) / 3
            if avg > 70 and avg < 240:
                img.set_pixel(x, y, Color(0, 0, 0, 0))
                removed += 1

img.save_png("res://sprites/[OUTPUT_FILENAME].png")
_mcp_print("Removed " + str(removed) + " background pixels")
```

**Thresholds to adjust if needed:**
- `max_diff < 25` — how "grey" a pixel must be (lower = stricter)
- `avg > 70` — don't remove very dark pixels (shadow detail)
- `avg < 240` — don't remove very bright pixels (white highlights)

If sprites lose detail, increase the lower bound (70 → 90) or decrease max_diff (25 → 15).

#### Step 6: Import & Verify

```gdscript
# Trigger Godot filesystem scan
EditorInterface.get_resource_filesystem().scan()
```

Then restart the game scene (textures loaded at `_ready` won't hot-reload).

### Known Issues & Workarounds

| Issue | Solution |
|-------|----------|
| Gemini ignores exact pixel size | Always resize with `sips` after download |
| "Transparent background" = checkerboard | Run background removal script (Step 5) |
| Browser session dies between uses | Run `browser_snapshot` first; if error, navigate fresh |
| Download button doesn't save to disk | Use `browser_run_code` — the download event fires automatically |
| Sprites have grey halos after cleanup | Tighten thresholds or do a second pass |
| Style inconsistency between generations | Always include "matching Tiny Swords art pack aesthetic" in prompt |

### Integration Code Template

```gdscript
# Constants for grid sprite sheets (6x7 layout)
enum AnimRow { WALK_E = 0, WALK_N = 1, WALK_S = 2, WALK_W = 3,
               FROZEN = 4, SHOCKED = 5, DEATH = 6 }
const FRAMES_PER_ROW: int = 6

# In the node that uses the sprite:
static var my_texture: Texture2D = null
var current_row: int = AnimRow.WALK_E

func setup():
    if my_texture == null:
        my_texture = load("res://sprites/my_sprite.png")
    if my_texture:
        sprite = Sprite2D.new()
        sprite.texture = my_texture
        sprite.hframes = 6   # columns
        sprite.vframes = 7   # rows
        sprite.frame = 0
        sprite.scale = Vector2(1.0, 1.0)  # 64px frames, adjust as needed
        add_child(sprite)

# Pick row based on movement direction:
func _get_walk_row(dir: Vector2) -> int:
    if abs(dir.x) > abs(dir.y):
        return AnimRow.WALK_E if dir.x > 0 else AnimRow.WALK_W
    else:
        return AnimRow.WALK_S if dir.y > 0 else AnimRow.WALK_N

# Animation in _process:
anim_timer += delta
if anim_timer >= 0.15:
    anim_timer = 0.0
    anim_frame = (anim_frame + 1) % FRAMES_PER_ROW
    sprite.frame = current_row * FRAMES_PER_ROW + anim_frame
```

---

## Method 2: Tiny Swords Asset Pack (Pre-made)

Use downloaded assets from `~/Downloads/Tiny Swords (Free Pack)/` for consistent art.

### Available Assets

| Category | Path | Details |
|----------|------|---------|
| Units | `Units/[Color] Units/[Type]/` | 5 types (Archer, Lancer, Monk, Pawn, Warrior) x 5 colors |
| Trees | `Terrain/Resources/Wood/Trees/` | Tree1-4.png (8 frames, 192x256 each) |
| Rocks | `Terrain/Decorations/Rocks/` | Rock1-4.png (64x64, static) |
| Bushes | `Terrain/Decorations/Bushes/` | Bushe1-4.png (animated, 8 frames) |
| Gold | `Terrain/Resources/Gold/Gold Stones/` | Gold Stone 1-6.png (64x64) |
| Tilemap | `Terrain/Tileset/` | Tilemap_color1-5.png (576x384, 64px tiles) |

### Unit Sprite Format
- **Animations**: Idle, Run, Attack1, Attack2, Guard
- **Frame sizes**: 192x192 per frame
- **Frame counts**: 6 or 8 frames per animation (check file width / 192)
- **Colors**: Red, Blue, Purple, Black, Yellow
- **Scale in game**: Vector2(0.35–0.5, 0.35–0.5) for 90px cells

### Current Assignments

| Game Element | Asset | Source |
|---|---|---|
| Normal enemy | Purple Pawn Run (6 frames) | Tiny Swords |
| Fast enemy | Yellow Archer Run (4 frames) | Tiny Swords |
| Tank enemy | Black Warrior Run (6 frames) | Tiny Swords |
| Trees | Tree1 (8 frames) | Tiny Swords |
| Rocks | Rock1, Rock2 (static) | Tiny Swords |
| Ground | Tilemap_color1 center tile | Tiny Swords |
| Towers | Gemini AI generated sheet | Gemini |
| Pumpkin (unused) | pumpkin_monster_64.png | Gemini |

---

## Method 3: LPC Spritesheet Generator (Humanoid Characters)

**URL**: https://liberatedpixelcup.github.io/Universal-LPC-Spritesheet-Character-Generator/

Best for detailed humanoid characters with full directional walk/attack animations.
- 832x1344 output, 64x64 per frame
- Customize body, hair, armor, weapons via web UI
- License: CC-BY-SA 3.0 / GPLv3

---

## Method 4: Pixabay (Sound Effects)

**URL**: https://pixabay.com/

### Sound Library

| File | Description | Source |
|------|-------------|--------|
| `sfx_spin.mp3` | Spinner wheel sound | Pixabay/freesound |
| `sfx_jackpot.mp3` | Twinkle sparkle for spin result | Pixabay |
| `sfx_shoot.mp3` | Retro laser shot | Pixabay |
| `sfx_shoot_alt.mp3` | Alternative shoot (stored) | Pixabay/freesound |
| `bgm.mp3` | Holding The Line — main BGM | User provided |

---

## When to trigger

Use this skill PROACTIVELY when:
- The user asks for character sprites, monster art, or game graphics
- A new enemy type or character is being added to the game
- The user mentions "pixel art", "spritesheet", "character generator", or "monster design"
- The game needs visual variety beyond colored circles/shapes
