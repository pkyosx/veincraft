# Phase 0: Godot MCP Experiment
# 階段零：Godot MCP 實驗

> **Goal**: Build the same tiny prototype with both MCP servers. Evaluate which one is better for our project before committing.

---

## The Benchmark Task

Build a **minimal tile grid prototype** in Godot 4 that tests the core capabilities we'll need:

1. Create a Godot project from scratch
2. Create a 5×5 TileMap scene
3. Add a click handler — click a tile to place a "room" (colored square)
4. Add a simple enemy that moves across the grid toward a target tile
5. Run the project, verify it works, capture debug output

This is small enough to do quickly but touches every capability we need: project setup, scene creation, node manipulation, scripting, and run/debug.

---

## Experiment A: Coding-Solo/godot-mcp

### Setup

```bash
# Install via Claude Code
claude mcp add godot -e GODOT_PATH=/path/to/godot -e DEBUG=true -- npx @coding-solo/godot-mcp
```

### Available Tools (14 total)
| Tool | What it does |
|---|---|
| `launch_editor` | Opens Godot editor for a project |
| `run_project` | Runs project in debug mode |
| `get_debug_output` | Gets console output and errors |
| `stop_project` | Stops running project |
| `get_godot_version` | Gets Godot version |
| `list_projects` | Lists Godot projects in a directory |
| `get_project_info` | Project structure info |
| `create_scene` | Creates new scene with root node type |
| `add_node` | Adds nodes to scenes with properties |
| `load_sprite` | Loads sprites into Sprite2D nodes |
| `export_mesh_library` | Exports 3D scenes as MeshLibrary |
| `save_scene` | Saves scenes |
| `get_uid` | Gets UID for files (Godot 4.4+) |
| `update_project_uids` | Updates UID references |

### What the AI Must Do (with this MCP)
Since Coding-Solo only has 14 tools (scene/node focused), the AI agent will need to:
- Use MCP tools for: project setup, scene creation, adding nodes
- Use **file system tools (Read/Write/Edit)** for: writing GDScript files, editing project.godot, creating resource files
- Use MCP `run_project` + `get_debug_output` for: testing and debugging

This is a **hybrid approach** — MCP for Godot-specific operations, file tools for code.

### Instruction for Claude Code Agent

```
## EXPERIMENT A: Coding-Solo/godot-mcp

You have the `godot` MCP server available (Coding-Solo/godot-mcp).

### Task: Build a minimal tile grid prototype in Godot 4

Create a new Godot 4 project at ~/pkyosx/fengshui-td-experiment-a/ with the following:

1. **Project setup**: Create project.godot and folder structure manually via file tools
2. **Main scene**: Use MCP `create_scene` to create a Node2D root scene called "Main"
3. **Grid**: Create a 5×5 visual grid (use TileMap or ColorRect nodes — whichever works best)
   - Each cell is 64×64 pixels
   - Default color: dark grey (rock)
4. **Click to place rooms**: Write a GDScript that detects mouse clicks on the grid and changes the clicked tile's color to yellow (representing a "room")
5. **Enemy movement**: Add a Sprite2D or ColorRect node (red, 32×32) that spawns at grid position (0,0) and moves tile-by-tile toward grid position (4,4) at 1 tile per second
6. **Camera**: Set up a Camera2D so the grid is centered and visible
7. **Run and verify**: Use `run_project` to launch, then `get_debug_output` to check for errors

Write all GDScript code via file system Write/Edit tools.
Use MCP tools for scene creation and project management.

After building, report:
- What worked well with this MCP
- What you had to work around
- Any limitations or friction points
- Total number of tool calls used
```

---

## Experiment B: GDAI MCP

### Setup

```bash
# 1. Download GDAI MCP plugin from: https://github.com/3ddelano/gdai-mcp-plugin-godot
# 2. Copy addons/gdai-mcp-plugin-godot/ into your Godot project's addons/ folder
# 3. In Godot: Project → Project Settings → Plugins → GDAI MCP → Enable
# 4. Copy the JSON config from the GDAI MCP tab in Godot's bottom panel
# 5. Add to Claude Code:
claude mcp add gdai-mcp -- uv run /absolute/path/to/addons/gdai-mcp-plugin-godot/gdai_mcp_server.py
```

### Available Tools (many more — key ones listed)
| Tool | What it does |
|---|---|
| Scene tools | Create/open/delete scenes, play/stop, instancing |
| Node tools | Add/delete/duplicate/move nodes, set properties, signals, groups |
| Script tools | Read/create/edit scripts, attach to nodes, validate syntax |
| Editor tools | Take screenshots, read error log, execute editor scripts |
| Runtime tools | Inspect running game, navigate, click UI elements |
| Input tools | Simulate key/mouse/action input in running game |

### What the AI Must Do (with this MCP)
GDAI MCP can do almost everything through MCP tools:
- Scene creation, node manipulation, script creation all via MCP
- Can take screenshots to verify visual state
- Can simulate input in running game to test
- **Less need for file system tools** — MCP handles most operations

### Instruction for Claude Code Agent

```
## EXPERIMENT B: GDAI MCP

You have the `gdai-mcp` MCP server available (GDAI MCP Plugin).

### Prerequisites
- A Godot 4 project already exists at ~/pkyosx/fengshui-td-experiment-b/
- The GDAI MCP plugin is installed and enabled in that project
- The Godot editor is open with this project loaded

### Task: Build a minimal tile grid prototype in Godot 4

Using GDAI MCP tools as much as possible:

1. **Main scene**: Create a Node2D scene called "Main"
2. **Grid**: Create a 5×5 visual grid (use TileMap or ColorRect nodes)
   - Each cell is 64×64 pixels
   - Default color: dark grey (rock)
3. **Click to place rooms**: Create and attach a GDScript that detects mouse clicks on the grid and changes the clicked tile's color to yellow (representing a "room")
4. **Enemy movement**: Add a colored node (red, 32×32) that spawns at grid position (0,0) and moves tile-by-tile toward grid position (4,4) at 1 tile per second
5. **Camera**: Set up a Camera2D so the grid is centered and visible
6. **Run and verify**: Play the scene, take a screenshot to verify visuals, check for errors

Use MCP tools for everything possible (scene, nodes, scripts, running).
Only fall back to file system tools if MCP cannot do something.

After building, report:
- What worked well with this MCP
- What you had to work around
- Any limitations or friction points
- Total number of tool calls used
```

---

## Evaluation Checklist

After both experiments, compare on these criteria:

| Criteria | Weight | Coding-Solo (A) | GDAI (B) |
|---|---|---|---|
| **Setup complexity** — how hard to install and configure | 15% | _score 1-5_ | _score 1-5_ |
| **Scene creation** — can it create scenes and add nodes smoothly | 20% | _score 1-5_ | _score 1-5_ |
| **Script writing** — can it create/edit GDScript effectively | 20% | _score 1-5_ | _score 1-5_ |
| **Run & debug** — can it launch project and read errors | 15% | _score 1-5_ | _score 1-5_ |
| **Reliability** — did tools fail, timeout, or need workarounds | 15% | _score 1-5_ | _score 1-5_ |
| **Tool call efficiency** — fewer calls = better | 10% | _count_ | _count_ |
| **Visual verification** — can it see what it built | 5% | _yes/no_ | _yes/no_ |

### Decision Criteria
- If scores are close (within 10%), pick **Coding-Solo** (simpler, less dependency)
- If GDAI scores significantly higher (>20%), pick **GDAI** (more powerful)
- If both fail badly, consider **Godot MCP Pro** ($5) as fallback

---

## Important Notes

### For Coding-Solo (Experiment A)
- This MCP does NOT require Godot editor to be open — it launches Godot directly
- GDScript must be written via Claude Code's file system tools (Read/Write/Edit)
- The MCP creates `.tscn` files but complex scene editing may need manual file editing

### For GDAI (Experiment B)
- This MCP REQUIRES Godot editor to be open and the plugin enabled
- It communicates via WebSocket to the running editor
- It can take screenshots — useful for visual verification
- The Godot project must exist BEFORE starting the experiment (create manually or via file tools)
- Uses `uv` (Python) instead of `npx` (Node.js)

### Godot Version
- Both MCPs work with Godot 4.x
- Recommend Godot 4.3+ for best compatibility

---

## After the Experiment

Once you've picked a winner, I'll rewrite the full Phase 1 technical spec targeting that MCP + Godot 4 + GDScript, and update the Claude Code agent instruction accordingly.
