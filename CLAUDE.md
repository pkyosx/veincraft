# VeinCraft - Tower Defense Game

## Project Overview
VeinCraft is a 2D tower defense game built with **Godot 4.6.2** and **GDScript**. Players place towers along a winding path to defend against waves of enemies. The game is deployed as a web build on GitHub Pages.

- **Live URL**: https://pkyosx.github.io/veincraft/
- **Repo**: https://github.com/pkyosx/veincraft
- **Engine**: Godot 4.6.2 (gl_compatibility renderer)
- **Viewport**: 1600x900, stretch mode `canvas_items`

## Project Structure

```
veincraft/
  project.godot            # Godot project config
  scenes/main.tscn         # Main scene (Camera2D, containers, HUD)
  scripts/
    main.gd                # Core game logic: grid, towers, enemies, projectiles, drawing
    game_data.gd            # All constants: grid size, tower/enemy/item configs, wave composition
    enemy.gd                # Enemy entity: movement, damage, status effects, sprite animation
    hud.gd                  # UI: info panel, bag with icons, shop, spin, speed control
    projectile.gd           # Projectile: normal bullets and car sprites (F1, police, firetruck, monstertruck)
    audio_manager.gd        # Sound effects
    damage_number.gd        # Floating damage text
    coin_fly.gd             # Gold coin fly animation
  sprites/
    tower_sheet.png         # 9 tower sprites in a row (64x64 each): Turret, Trebuchet, Frost, Tesla, Racer, Police, FireTruck, Ambulance, MonsterTruck
    monster_*.png           # Enemy sprites (64x64, RGBA with transparent background)
    monster_*_sheet.png     # Animated enemy sprites (horizontal frames)
    monster_noob_boss_4dir.png  # Noob Boss: 8 frames x 4 directions (512x256)
    projectile_f1.png       # F1 car projectile (32x16)
    projectile_police.png   # Police car projectile
    projectile_firetruck.png
    projectile_monstertruck.png
    icon_*.png              # Bag item icons (64x64)
  export/
    web/                    # Exported web build files
  addons/
    godot_mcp/              # Godot MCP Pro plugin (WebSocket on port 6505)
    godot_sfxr/             # Sound effect generator
```

## Key Architecture

### Grid System
- **18x12 grid**, 60px cells, offset (20, 30)
- Winding S-shaped enemy path with 5 turns
- Coordinate conversion: `cell_to_world()` / `world_to_cell()`
- Mouse input uses `get_global_mouse_position()` (NOT `event.position`) for proper Camera2D + stretch mode mapping

### Tower Types (8 total)
| Tower | Cost | Damage | Special |
|-------|------|--------|---------|
| Turret | $8 | 3 | Basic |
| Trebuchet | $18 | 10 | Long range |
| Frost | $12 | 1 | Slow 40% |
| Tesla | $20 | 5 | Chain 3 enemies |
| Racer | $50 | 20 | Pierce 5, shoots F1 car |
| Police | $35 | 12 | Pierce 3 + Slow 50%, shoots police car |
| FireTruck | $40 | 8 | Pierce 3 + Burn 4dps/3s |
| MonsterTruck | $60 | 35 | Pierce 8 + Knockback 2 cells |

### Enemy Types (11 total)
- Normal: Slime, Skeleton, Goblin, Wolf, Mushroom, Bat, Orc, Wraith, Dragon, Golem
- **Boss**: Noob Boss (Roblox Noob) - appears wave 20, 200x HP, 3.5x sprite scale, 4-direction walk animation

### Item System
- **Bag**: 8 slots (4x2 GridContainer), items shown with icons
- **Shop**: Spin ($10) for normal pool, Premium Spin ($50) for rare items (Racer, Police, FireTruck, MonsterTruck, MegaBomb, ++DMG)
- **Direct Buy**: All 8 tower types available as buttons
- **Bomb**: Destroys rocks, trees, AND own towers/upgrades
- **MegaBomb**: 3x3 area destruction

### Sprite System
- Enemy sprites: 64x64 PNG with transparent background (flood-fill removed)
- Animated sprites use `hframes` (horizontal frames) and optionally `vframes` (4 directions)
- Noob Boss uses 4-direction sprite sheet (vframes=4, hframes=8): row 0=down, 1=right, 2=up, 3=left
- Slime/Mushroom use bounce animation (6-frame squash/stretch sheet)
- `base_scale` instance variable controls sprite size (0.8 normal, 3.5 boss) - must NOT be hardcoded in status effect code

### Visual Effects
- Path: 3D sunken border effect (dark top-left, light bottom-right)
- Towers: drop shadow + lifted 4px
- Enemies: ground shadow circle
- Burn: orange flicker modulate + fire particles
- Freeze: blue tint + scale pulse + ice crystals
- Shock: yellow flash + position jitter

## Development Commands

### Run Game in Editor
Open project in Godot 4.6.2 editor. The MCP plugin starts automatically on ports 6505-6509.

### Export Web Build
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/seth_wang/pkyosx/veincraft --export-release "Web" export/web/index.html
```

### Deploy to GitHub Pages
```bash
# 1. Export (see above)
# 2. Switch to gh-pages, copy files, push
git stash
git checkout gh-pages
cp export/web/index.pck export/web/index.wasm .
git add index.pck index.wasm
git commit -m "Deploy: description"
git push origin gh-pages
# 3. Switch back
git checkout -- .
git checkout master
git stash pop
# 4. Commit source to master
git add <specific files>
git commit -m "description"
git push origin master
```

### Force Browser Cache Refresh
Append `?v=NUMBER` to URL: `https://pkyosx.github.io/veincraft/?v=108`

## MCP Server Setup (for Antigravity / other editors)
```json
{
  "mcpServers": {
    "godot-mcp-pro": {
      "command": "/Users/seth_wang/.asdf/installs/nodejs/22.10.0/bin/node",
      "args": ["/Users/seth_wang/pkyosx/godot-mcp-pro-v1.8.1/server/build/index.js", "--lite"],
      "env": {
        "GODOT_MCP_PORT": "6505"
      }
    }
  }
}
```
Use `--lite` (80 tools) for editors with 100-tool limit. Use `--minimal` (35 tools) for stricter limits.

## Common Pitfalls
1. **Sprite transparency**: Monster PNGs must be RGBA. After editing sprites, delete `.godot/imported/monster_*.ctex` AND `.import` files to force reimport.
2. **Click coordinates**: Always use `get_global_mouse_position()`, never `event.position` - the Camera2D and stretch mode transform needs it.
3. **Boss scale reset**: `base_scale` is an instance variable. Status effect code must use `base_scale` not hardcoded `0.8`, or boss sprites shrink.
4. **Export cache**: After changing sprites, must clear Godot import cache before export, or old textures get bundled.
5. **GitHub Pages cache**: Users may see old version. Always increment `?v=` parameter.
6. **Tower sheet order**: Turret=0, Trebuchet=1, Frost=2, Tesla=3, Racer=4, Police=5, FireTruck=6, (Ambulance=7 unused), MonsterTruck=8

## Current State
- **Starting gold**: $99999 (testing mode - change back to 30 for release)
- **Wave 1**: Noob Boss only (testing mode - change back to Slime for release)
- **Obstacles**: Removed (no rocks/trees)
- **Language**: UI in English, code comments in English
