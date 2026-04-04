# Sprite & Character Generation

Two methods for generating game sprites and character art for this project.

## Method 1: LPC Spritesheet Generator (Pixel Art Characters)

Use the Universal LPC Spritesheet Character Generator for pixel-art style characters with walk/attack/idle animations.

**URL**: https://liberatedpixelcup.github.io/Universal-LPC-Spritesheet-Character-Generator/

### How to use

1. Open the URL in the user's browser using Playwright:
   ```
   mcp__plugin_playwright_playwright__browser_navigate → the URL above
   ```
2. Use the web UI to customize the character:
   - Body type, skin color
   - Hair, clothing, armor
   - Weapons, accessories
3. Download the spritesheet PNG (typically 832x1344, 64x64 per frame)
4. Copy to `res://sprites/` in the project
5. Use AnimatedSprite2D or Sprite2D with frame-based animation

### Spritesheet layout
- Each row = one animation direction (up, left, down, right)
- Columns = animation frames
- Standard frame size: 64x64 pixels
- Common animations: idle, walk, slash, thrust, shoot, hurt, cast

### Best for
- Player characters
- Humanoid enemies (soldiers, knights, mages)
- NPCs

### License
LPC assets are dual-licensed under CC-BY-SA 3.0 and GPLv3. Credit required.

---

## Method 2: Gemini AI Image Generation (Custom Monsters)

Use Google Gemini to generate unique monster/creature art via AI.

**URL**: https://gemini.google.com/

### How to use

1. Open Gemini in browser using Playwright:
   ```
   mcp__plugin_playwright_playwright__browser_navigate → https://gemini.google.com/
   ```
2. Prompt Gemini with a specific style description. Example prompts:

   **Halloween-style monsters:**
   ```
   Generate a pixel art sprite sheet of a Halloween-style [monster type],
   top-down view, 64x64 pixels, dark background, 4 frames of walk
   animation facing right. Style: retro 16-bit game art.
   ```

   **Tower Defense enemies:**
   ```
   Create a pixel art character sprite for a tower defense game.
   The character is a [description]. Show 4 animation frames in a
   horizontal strip, each frame 64x64 pixels, transparent background.
   ```

3. Download the generated image
4. Copy to `res://sprites/` in the project
5. May need manual cleanup in an image editor (crop, resize, fix transparency)

### Prompt tips for better results
- Always specify "pixel art" and "sprite sheet" in the prompt
- Include exact pixel dimensions (64x64, 32x32)
- Mention "transparent background" or "dark background"
- Specify "top-down view" or "side view" depending on game perspective
- Request specific frame count: "4 frames" or "8 frames"
- Add style keywords: "retro", "16-bit", "8-bit", "Halloween", "fantasy"

### Best for
- Unique monsters and creatures
- Boss characters
- Environmental props
- Any non-humanoid characters

---

## Integration into Godot

After downloading sprites, to use them in the game:

```gdscript
# Load a sprite sheet
var texture: Texture2D = load("res://sprites/monster.png")

# For AnimatedSprite2D — set up in SpriteFrames resource
# For simple Sprite2D — use hframes/vframes for frame-based animation

# Example: Sprite2D with horizontal strip (4 frames)
var sprite: Sprite2D = Sprite2D.new()
sprite.texture = texture
sprite.hframes = 4  # 4 columns
sprite.frame = 0    # current frame
# Animate by changing sprite.frame in _process
```

## Method 3: Pixabay (Free Sound Effects)

**URL**: https://pixabay.com/

### How to use

1. Open Pixabay in browser, search for the sound type needed
2. Filter by "Sound Effects"
3. Download the MP3
4. Copy to `res://audio/` in the project
5. Load in AudioManager: `streams["name"] = load("res://audio/filename.mp3")`

### Best for
- Professional-quality sound effects (shoot, explosion, UI clicks)
- Background music loops
- Ambient sounds

### License
Pixabay Content License — free for commercial use, no attribution required.

### Sound library in this project
| File | Description | Source |
|------|-------------|--------|
| `sfx_spin.mp3` | Spinner wheel sound | Pixabay/freesound |
| `sfx_jackpot.mp3` | Twinkle sparkle for spin result | Pixabay |
| `sfx_shoot.mp3` | Retro laser shot | Pixabay |
| `sfx_shoot_alt.mp3` | Alternative shoot sound (stored for later) | Pixabay/freesound |
| `bgm.mp3` | Holding The Line — main BGM | User created |

---

## When to trigger

Use this skill PROACTIVELY when:
- The user asks for character sprites, monster art, or game graphics
- A new enemy type or character is being added to the game
- The user mentions "pixel art", "spritesheet", "character generator", or "monster design"
- The game needs visual variety beyond colored circles/shapes
