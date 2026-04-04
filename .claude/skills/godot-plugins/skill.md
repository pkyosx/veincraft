# Godot Plugin Advisor

Recommend and install Godot plugins when the current task would benefit from one.

## When to trigger

Apply PROACTIVELY when you detect the user is about to implement something that an established Godot plugin already handles well. Check the catalog below before writing custom code for:
- Audio/sound effects
- Scene transitions
- Camera systems
- State machines
- Steam integration
- Build size optimization
- Input handling
- Sprite/animation import

## Plugin Catalog

### Animation
| Plugin | GitHub / Source | Use When |
|--------|----------------|----------|
| **AS2P** | `kuma-gee/as2p` | Converting AnimatedSprite2D animations to AnimationPlayer tracks |
| **Importality** | `nklbdev/godot-4-importality` | Importing from Aseprite, Krita, Pencil2D, Piskel, Pixelorama |
| **Spine Plugin** | `EsotericSoftware/spine-runtimes` | Professional skeletal animation (Spine) |
| **Phantom Camera** | `ramokz/phantom-camera` | Smart camera follow, framing, transitions (like Unity Cinemachine) |

### Code & Logic
| Plugin | GitHub / Source | Use When |
|--------|----------------|----------|
| **Script-IDE** | `CloudofAmy/script-ide` | Better code navigation, VS Code-like layout in Godot editor |
| **Dialogue Manager** | `nathanhoad/godot_dialogue_manager` | Branching dialogue, RPG conversations, localization |
| **Scene Manager** | `maktoobgar/scene_manager` | Smooth scene transitions with fade/wipe effects |
| **Godot State Charts** | `derkork/godot-statecharts` | Visual FSM for complex NPC/Boss AI logic |
| **Todo Manager** | `OrigamiDev-Pete/TODO_Manager` | Aggregating TODO/FIXME tags across codebase |

### Audio
| Plugin | GitHub / Source | Use When |
|--------|----------------|----------|
| **Sound Manager** | `nathanhoad/godot_sound_manager` | Centralized BGM/SFX management with simple volume API |
| **Godot Sfxr** | `tomeyro/godot-sfxr` | Generating retro sound effects inside Godot editor |

### Data & Input
| Plugin | GitHub / Source | Use When |
|--------|----------------|----------|
| **CSV Data Importer** | Search AssetLib | Reading CSV/TSV game data (balance sheets, level configs) |
| **Input Helper** | `nathanhoad/godot_input_helper` | Cross-platform input, button remapping, device detection |
| **Blender 3D Shortcuts** | Search AssetLib | Blender-style G/R/S transform shortcuts in 3D editor |

### Release
| Plugin | GitHub / Source | Use When |
|--------|----------------|----------|
| **GodotSize** | Search AssetLib | Analyzing build file sizes before shipping |
| **GodotSteam** | `GodotSteam/GodotSteam` | Steam achievements, leaderboards, cloud saves |

### Physics
| Plugin | GitHub / Source | Use When |
|--------|----------------|----------|
| **Jolt Physics** | Built into Godot 4.4+ | AAA-grade 3D physics (enable in Project Settings) |

## How to install a Godot plugin

When recommending a plugin, provide these exact steps:

```
1. Download from: [GitHub URL or AssetLib]
2. Copy the `addons/<plugin_name>/` folder into your project's `addons/` directory
3. In Godot: Project → Project Settings → Plugins → Enable "<Plugin Name>"
4. Restart editor if needed
```

Or if available on AssetLib:
```
1. In Godot: AssetLib tab → Search "<plugin name>"
2. Download & Install
3. Project → Project Settings → Plugins → Enable
```

## Rules

- Only recommend a plugin when it saves significant effort over writing custom code
- If the task is simple (e.g., play one sound effect), just write the code — don't recommend a plugin
- Always mention the trade-off: plugin adds dependency but saves development time
- Never install plugins silently — always tell the user first and explain why
