# Veincraft — Technical Build Spec (For AI Implementation)
# 技術建造規格書（供 AI 實作）

> Each phase is a self-contained build target. The AI should implement one phase at a time.
> Output: a playable web game (HTML5 Canvas or React + Canvas).

---

## Tech Stack

- **Renderer**: HTML5 Canvas (simple 2D tile rendering) or React with Canvas overlay
- **Language**: TypeScript
- **State management**: Plain objects or a simple ECS (Entity-Component-System) for Phase 1; evaluate Zustand or similar for Phase 3+
- **Build tool**: Vite
- **No backend required** — single-player, all state in memory
- **Target**: runs in modern browser, desktop-first (mouse/keyboard)

---

## Phase 1: 骨架 Skeleton

### Data Structures

```typescript
// === GRID ===
type TileType = 'rock' | 'corridor' | 'room';

interface Tile {
  x: number;           // grid column (0-8)
  y: number;           // grid row (0-8)
  type: TileType;
  roomType?: RoomType; // only if type === 'room'
  roomLevel?: number;  // default 1
  hp?: number;         // room HP, Furnace has HP
}

type RoomType = 'production' | 'attack' | 'furnace';

// === GRID MAP ===
interface GameMap {
  width: number;       // 9
  height: number;      // 9
  tiles: Tile[][];     // 2D array [y][x]
}

// === RESOURCES ===
interface Resources {
  energy: number;          // spendable EN
  depositedEnergy: number; // EN deposited into furnace (toward win)
  targetEnergy: number;    // win threshold (300)
}

// === ENEMIES ===
interface Enemy {
  id: string;
  x: number;            // pixel or grid position (fractional for movement)
  y: number;
  hp: number;
  maxHp: number;
  speed: number;         // tiles per second
  damage: number;        // damage to furnace per hit
  path: {x: number, y: number}[];  // precomputed path to furnace
  pathIndex: number;     // current position in path
}

// === ROOMS ===
interface RoomConfig {
  type: RoomType;
  cost: number;          // EN cost to build
  productionPerWave?: number;  // EN generated per wave (production only)
  attackDamage?: number;       // damage per shot (attack only)
  attackRange?: number;        // tiles (attack only)
  attackCooldown?: number;     // seconds between shots (attack only)
  maxHp: number;
}

const ROOM_CONFIGS: Record<RoomType, RoomConfig> = {
  production: { type: 'production', cost: 2, productionPerWave: 3, maxHp: 10 },
  attack:     { type: 'attack', cost: 3, attackDamage: 2, attackRange: 2, attackCooldown: 1.5, maxHp: 8 },
  furnace:    { type: 'furnace', cost: 0, maxHp: 50 },
};

// === GAME STATE ===
type GamePhase = 'build' | 'defend' | 'result';

interface GameState {
  map: GameMap;
  resources: Resources;
  enemies: Enemy[];
  wave: number;
  maxWaves: number;       // 10
  phase: GamePhase;
  furnacePosition: {x: number, y: number};
  spawnPoints: {x: number, y: number}[];  // fixed map edge points
  projectiles: Projectile[];  // for attack room animations
}

interface Projectile {
  id: string;
  fromX: number; fromY: number;
  toX: number; toY: number;
  progress: number;  // 0-1 animation progress
  damage: number;
}
```

### Core Algorithms

#### Pathfinding
- Use **BFS (Breadth-First Search)** on the tile grid.
- Valid path tiles: `corridor` and `room` type tiles.
- Each enemy computes path from its spawn point to the furnace tile at spawn time.
- If no valid path exists, enemies do NOT spawn from that point (or stand idle).
- Recalculate paths when new rooms/corridors are built between waves.

```
function findPath(map: GameMap, from: {x,y}, to: {x,y}): {x,y}[]
  - BFS from `from` to `to`
  - Walkable: tile.type === 'corridor' || tile.type === 'room'
  - Return array of grid positions, or empty if unreachable
```

#### Attack Room Targeting
- Each frame during defend phase, for each Attack Room:
  1. Find enemies within `attackRange` tiles (Manhattan or Euclidean distance).
  2. If cooldown elapsed, pick closest enemy, create Projectile, apply damage.
  3. If enemy HP <= 0, remove enemy, play death animation.

#### Wave Spawning
- Each wave spawns `N` enemies (N = wave number + 2) from random fixed spawn points.
- Enemies spawn with 0.5–1.0 second intervals (staggered).
- Wave ends when all enemies are dead or furnace destroyed.

#### Energy Production
- At the start of each Build phase (after a Defend phase):
  `resources.energy += sum(productionRooms.map(r => r.productionPerWave))`

#### Deposit
- Player can tap Furnace and choose how much EN to deposit.
- `resources.depositedEnergy += amount; resources.energy -= amount;`
- If `depositedEnergy >= targetEnergy` → VICTORY.

### Rendering

#### Grid Rendering
- Each tile is a **64×64 pixel** square (configurable).
- Rock tiles: dark grey/brown texture.
- Corridor tiles: lighter stone texture.
- Room tiles: colored by type (yellow=production, red=attack, gold=furnace).
- Room icon drawn centered in tile.

#### UI Overlay
- Top bar: EN counter (yellow), Deposited EN / Target (gold progress bar), Furnace HP bar (red), Wave counter.
- Bottom bar: Room build buttons (with costs), "Start Wave" button, "Deposit EN" button.
- Click tile → if rock adjacent to corridor/room → show build menu.
- Click room → show room info panel.

#### Defend Phase Animation
- Enemies rendered as colored circles/sprites moving along path.
- Projectiles rendered as small fast-moving dots from attack room to enemy.
- Damage numbers float up from enemies when hit.
- Screen shake when Furnace takes damage.

### Game Loop

```
INIT:
  Create 9×9 grid, all rock except center = furnace
  Set 4 fixed spawn points at map edges (N, S, E, W center tiles of edges)
  resources = { energy: 5, depositedEnergy: 0, targetEnergy: 300 }
  wave = 0, maxWaves = 10, phase = 'build'

BUILD PHASE:
  Player places rooms and corridors (click interactions)
  Player can deposit EN into furnace
  Player clicks "Start Wave" → phase = 'defend', wave++

DEFEND PHASE (real-time, requestAnimationFrame loop):
  Spawn enemies over time from spawn points
  Each frame:
    Move enemies along paths
    Attack rooms fire at enemies in range
    Animate projectiles
    Check: enemy reaches furnace → damage furnace
    Check: furnace HP <= 0 → DEFEAT
    Check: all enemies dead → end wave → phase = 'build'
      Run energy production
      Check: depositedEnergy >= target → VICTORY

RESULT:
  Show victory or defeat screen with stats
```

### File Structure

```
src/
  main.ts              # entry point, game init
  types.ts             # all interfaces and types
  config.ts            # ROOM_CONFIGS, WAVE_CONFIGS, constants
  state.ts             # GameState creation and management
  grid.ts              # tile grid operations, room placement, corridor drawing
  pathfinding.ts       # BFS pathfinder
  combat.ts            # attack room logic, projectile system
  enemies.ts           # enemy spawning, movement, wave management
  economy.ts           # energy production, deposit logic
  renderer.ts          # canvas rendering (grid, rooms, enemies, projectiles, UI)
  input.ts             # mouse/touch input handling
  ui.ts                # HUD overlay, buttons, panels
  gameLoop.ts          # main requestAnimationFrame loop, phase management
index.html             # single HTML file with canvas element
```

### Acceptance Criteria

- [ ] 9×9 grid renders with furnace in center
- [ ] Player can place Production and Attack rooms on rock tiles adjacent to existing rooms/corridors
- [ ] Player can draw corridors between rooms
- [ ] Enemies spawn from 4 fixed edge points and pathfind to furnace
- [ ] Attack rooms fire at enemies within range
- [ ] Enemies that reach furnace deal damage to it
- [ ] Furnace HP reaching 0 = defeat screen
- [ ] Production rooms generate EN after each wave
- [ ] Player can deposit EN into furnace
- [ ] Depositing 300 EN = victory screen
- [ ] 10 waves with escalating enemy count
- [ ] Smooth 60fps rendering and animations

---

## Phase 2: 迷霧 Fog

### New/Modified Data Structures

```typescript
// === TILE ADDITIONS ===
interface Tile {
  // ... all Phase 1 fields, plus:
  visible: boolean;       // is this tile visible to the player?
  revealed: boolean;      // has this tile ever been seen? (dimmer than active)
  hasPortal: boolean;     // portal currently active on this tile
  portalHp?: number;      // portal durability
  detectionLevel?: number; // 0-4, how well detected (for Detection Room range)
}

type RoomType = 'production' | 'attack' | 'furnace' | 'detection' | 'teleport';

// === PORTAL ===
interface Portal {
  id: string;
  x: number;
  y: number;
  hp: number;            // HP to destroy (player spends EN)
  spawnRate: number;      // enemies per second
  spawnTimer: number;     // countdown to next spawn
  detected: boolean;      // has a Detection Room found this?
  active: boolean;
}

// === VISIBILITY SYSTEM ===
interface VisibilityState {
  visibleTiles: Set<string>;  // "x,y" keys
  detectedPortals: Portal[];
  portalHints: PortalHint[];  // directional hints for undetected portals
}

interface PortalHint {
  direction: 'N' | 'NE' | 'E' | 'SE' | 'S' | 'SW' | 'W' | 'NW';
  distance: 'near' | 'far';  // rough distance category
}

// === TELEPORT LINK ===
interface TeleportLink {
  roomA: {x: number, y: number};
  roomB: {x: number, y: number};
}

// === ROOM CONFIGS ADDITIONS ===
const ROOM_CONFIGS_P2 = {
  ...ROOM_CONFIGS,
  detection: { type: 'detection', cost: 3, detectionRadius: 3, maxHp: 6 },
  teleport:  { type: 'teleport', cost: 4, maxHp: 6 },
};
```

### Core Algorithms

#### Visibility Calculation
```
function recalcVisibility(map, rooms, teleportLinks):
  visibleTiles = new Set()

  // 1. All room tiles and their corridors are visible
  for each tile where tile.type === 'room' || tile.type === 'corridor':
    visibleTiles.add(tile)
    // Also add immediately adjacent tiles (1-tile border)
    for each neighbor of tile:
      visibleTiles.add(neighbor)

  // 2. Detection rooms extend visibility
  for each Detection Room:
    for each tile within detectionRadius:
      visibleTiles.add(tile)
      tile.detectionLevel = max(tile.detectionLevel, room.level)

  // 3. Update all tile visibility flags
  for each tile in map:
    tile.visible = visibleTiles.has(tile)
    if tile.visible: tile.revealed = true
```

#### Portal Spawning (replaces fixed spawn points)
```
function spawnPortals(map, wave, rooms):
  numPortals = 1 + floor(rooms.length / 5)  // more rooms = more portals
  numPortals = min(numPortals, wave)         // capped by wave number

  validSpawnTiles = map.tiles where:
    tile.type === 'rock' AND
    tile is not adjacent to furnace AND
    tile is at least 2 tiles away from any room

  for i in 0..numPortals:
    tile = random(validSpawnTiles)
    create Portal at tile position
    tile.hasPortal = true
```

#### Portal Hints
```
function generateHints(portals, furnacePos):
  hints = []
  for each portal where !portal.detected:
    dx = portal.x - furnacePos.x
    dy = portal.y - furnacePos.y
    direction = angleToCardinal(dx, dy)  // N, NE, E, etc.
    distance = magnitude(dx, dy) > 4 ? 'far' : 'near'
    hints.push({ direction, distance })
  return hints
```

#### Portal Destruction
- Player clicks detected portal → spend 5 EN → portal destroyed.
- Portal removal stops enemy spawning from that location.

#### Enemy Spawning from Portals
- Each active portal spawns enemies at `spawnRate` intervals.
- Enemies pathfind from portal position to furnace (using BFS, which may go through fog — enemies know the path even if player doesn't see it).
- If no valid path exists from portal to furnace (completely walled off), portal despawns.

### Rendering Changes

#### Fog of War
- Non-visible tiles render as **solid dark overlay** (black, 90% opacity).
- `revealed` but not currently `visible` tiles render with **50% dark overlay** (player remembers the terrain but can't see current activity).
- Visible tiles render normally.
- Detection Room radius shown as **translucent blue circle overlay**.

#### Portal Rendering
- Detected portal: swirling black vortex animation at tile center.
- Undetected portal: invisible (in fog). Only hints shown.
- Portal hints: red directional arrows at the edge of the visible area, pulsing.

#### UI Changes
- Remove fixed spawn point indicators.
- Add portal hint arrows during Defend phase.
- Add "Collapse Portal (5 EN)" button when clicking a detected portal.
- Detection Room build option in toolbar.
- Teleport Room build option in toolbar.
- When two Teleport Rooms exist, render glowing connecting line.

### Acceptance Criteria

- [ ] Fog of war renders correctly — only built areas + detection radius visible
- [ ] Portals spawn in fog at random positions each wave
- [ ] Portal count scales with dungeon size
- [ ] Directional hints appear for undetected portals
- [ ] Detection Rooms reveal portals within range
- [ ] Player can spend EN to destroy detected portals
- [ ] Enemies spawn continuously from active portals
- [ ] Teleport Rooms link and allow instant "camera jump" between them
- [ ] Visibility recalculates when rooms are built
- [ ] Fog dissolve animation when new areas are revealed

---

## Phase 3: 五行 Elements

### New/Modified Data Structures

```typescript
// === ELEMENTS ===
type Element = 'wood' | 'fire' | 'earth' | 'metal' | 'water';

const GENERATION: Record<Element, Element> = {
  wood: 'fire', fire: 'earth', earth: 'metal', metal: 'water', water: 'wood'
};
const RESTRAINT: Record<Element, Element> = {
  wood: 'earth', earth: 'water', water: 'fire', fire: 'metal', metal: 'wood'
};

// === TILE ADDITIONS ===
interface Tile {
  // ... all previous fields, plus:
  element: Element;       // inherent element based on grid position
}

// === ELEMENT MAP GENERATION ===
// Grid divided into 5 zones based on position:
//   North = Water, South = Fire, East = Wood, West = Metal, Center = Earth
// Transition zones blend elements (e.g., NE corner = Water or Wood, random)

function assignElements(map: GameMap): void {
  for each tile:
    // Use distance from center + angle to determine element
    const cx = map.width / 2, cy = map.height / 2;
    const angle = atan2(tile.y - cy, tile.x - cx);
    const dist = distance(tile, {x: cx, y: cy});
    if (dist < 2) tile.element = 'earth';       // center = earth
    else assign by angle quadrant with some noise
}

// === KI FLOW ===
interface KiFlow {
  fromRoom: {x: number, y: number};
  toRoom: {x: number, y: number};
  element: Element;
  relationship: 'generation' | 'restraint' | 'neutral';
  strength: number;  // 1.0 for adjacent, 0.5 for 2-away, 0.1 for 3+
}

// === ROOM MODIFIER ===
interface RoomModifier {
  outputMultiplier: number;  // 1.0 = base, affected by ki flows
  kiFlows: KiFlow[];         // all flows affecting this room
}

// === ENEMY ADDITIONS ===
interface Enemy {
  // ... all previous fields, plus:
  element: Element;
}

// === SENTAN RESOURCE ===
interface Resources {
  energy: number;
  depositedEnergy: number;
  targetEnergy: number;
  sentan: number;           // NEW
}

// === UPGRADE TILE ===
interface UpgradeTile {
  id: string;
  x: number;
  y: number;
  type: UpgradeType;
  element?: Element;        // elemental affinity (optional)
  bonus: number;            // flat stat bonus
}

type UpgradeType = 'damage_boost' | 'production_boost' | 'range_boost' | 'cooldown_reduction';

// === ROOM CONFIGS ADDITIONS ===
type RoomType = 'production' | 'attack' | 'furnace' | 'detection' | 'teleport' | 'refinery';

const ROOM_CONFIGS_P3 = {
  ...ROOM_CONFIGS_P2,
  refinery: { type: 'refinery', cost: 3, sentanPerWave: 2, maxHp: 8 },
};

// === UPGRADE SHOP (non-random) ===
interface UpgradeShop {
  available: UpgradeTile[];  // fixed selection per wave, refreshes each wave
  prices: Record<UpgradeType, number>;  // sentan cost
}
```

### Core Algorithms

#### Ki Flow Calculation
```
function calculateKiFlows(map, rooms):
  flows = []
  for each room R:
    connectedRooms = findConnectedRooms(R, map)  // rooms linked by corridors
    for each connected room C:
      distance = corridorDistance(R, C)  // number of corridor tiles between
      strength = distance === 1 ? 1.0 : distance === 2 ? 0.5 : 0.1

      if GENERATION[C.element] === R.element:
        relationship = 'generation'   // C generates R's element
      else if RESTRAINT[C.element] === R.element:
        relationship = 'restraint'    // C restrains R's element
      else:
        relationship = 'neutral'

      flows.push({ from: C, to: R, element: C.element, relationship, strength })

  // Apply modifiers to rooms
  for each room R:
    roomFlows = flows.filter(f => f.to === R)
    multiplier = 1.0
    for each flow:
      if flow.relationship === 'generation':  multiplier += 0.30 * flow.strength
      if flow.relationship === 'restraint':   multiplier -= 0.20 * flow.strength
      if flow.relationship === 'neutral':     multiplier += 0.05 * flow.strength
    R.modifier.outputMultiplier = max(0.1, multiplier)
    R.modifier.kiFlows = roomFlows
```

#### Elemental Damage
```
function calculateDamage(attackRoom, enemy):
  baseDamage = attackRoom.attackDamage * attackRoom.modifier.outputMultiplier
  // Apply upgrade tile bonuses
  baseDamage += sum(adjacentUpgradeTiles.filter(t => t.type === 'damage_boost').map(t => t.bonus))

  if RESTRAINT[attackRoom.element] === enemy.element:
    return baseDamage * 1.5  // super effective
  else if RESTRAINT[enemy.element] === attackRoom.element:
    return baseDamage * 0.5  // resisted
  else:
    return baseDamage
```

#### Element-Typed Enemy Waves
```
WAVE_CONFIGS = [
  // waves 1-5: mixed soldiers (no element)
  // wave 6+: start introducing elemental enemies
  { wave: 6, enemies: [{type: 'archer', element: 'wood', count: 3}] },
  { wave: 8, enemies: [{type: 'monk', element: 'water', count: 2}] },
  // etc.
]
```

#### Upgrade Tile Placement
- Player buys upgrade tile from shop (costs Sentan).
- Player places it on any `rock` tile adjacent to a room.
- The tile becomes a special non-room tile that provides bonuses.
- Upgrade tile bonuses are calculated per-frame for adjacent rooms.

### Rendering Changes

- Tiles have subtle element-colored backgrounds.
- Ki flow lines rendered as animated dashed lines through corridors (green=generation, red=restraint, white=neutral).
- Room info panel shows: element icon, ki flows list, output multiplier, upgrade level.
- Enemy sprites/circles have elemental color tint.
- "克！" popup on super-effective hits; grey damage on resisted hits.
- Sentan counter (green) in top bar.
- Upgrade shop panel during Build phase.

### Acceptance Criteria

- [ ] Grid tiles have element assignments based on position
- [ ] Rooms inherit element from their tile
- [ ] Ki flows calculate correctly between connected rooms
- [ ] Generation gives +30% output, restraint gives -20%
- [ ] Ki flow lines render visually through corridors
- [ ] Elemental enemies appear with correct elements
- [ ] Attack rooms deal bonus/reduced damage based on element matchup
- [ ] Refinery Room produces Sentan
- [ ] Upgrade tiles can be purchased with Sentan and placed on grid
- [ ] Upgrade tile adjacency bonuses apply correctly
- [ ] Room info panel shows element, ki flows, and modifier

---

## Phase 4: 命運 Fate

### New/Modified Data Structures

```typescript
// === GACHA SYSTEM ===
type Rarity = 'common' | 'uncommon' | 'rare' | 'legendary';

interface GachaTile {
  id: string;
  rarity: Rarity;
  type: 'room' | 'upgrade' | 'beast_token' | 'special';
  roomType?: RoomType;
  upgradeType?: UpgradeType;
  beastType?: BeastType;
  element?: Element;
  // special items: energy_burst, reveal_all, portal_bomb, etc.
  specialEffect?: string;
}

interface GachaShop {
  options: GachaTile[];    // 3 tiles to choose from
  rerollCost: number;      // increases each reroll (3 → 6 → 12 → ...)
  rerollCount: number;
  pityCounter: number;     // brews since last rare+
  pityLegendary: number;   // brews since last legendary
}

const RARITY_WEIGHTS: Record<Rarity, number> = {
  common: 60, uncommon: 25, rare: 12, legendary: 3
};

// === IMMORTAL BEASTS (仙獸) ===
type BeastType = 'digger' | 'firebird' | 'waterdragon' | 'metalbeetle' | 'woodspirit';

interface Beast {
  id: string;
  type: BeastType;
  element: Element;
  level: number;
  hp: number;
  maxHp: number;
  patrolRoute: {x: number, y: number}[];  // ordered room positions
  patrolIndex: number;
  x: number; y: number;                    // current pixel position
  mutation?: Mutation;
  // type-specific stats
  carryCapacity?: number;    // digger
  attackDamage?: number;     // firebird
  visionRadius?: number;     // waterdragon
  blockStrength?: number;    // metalbeetle
  healRate?: number;         // woodspirit
}

interface Mutation {
  name: string;
  effect: string;           // human-readable
  statModifier: Record<string, number>;  // e.g., { attackDamage: 1.5 }
}

const MUTATION_CHANCE = 0.15;
const MUTATIONS: Mutation[] = [
  { name: 'Blazing', effect: 'Attack speed +50%', statModifier: { attackCooldown: 0.5 } },
  { name: 'Far-Sighted', effect: 'Vision radius x2', statModifier: { visionRadius: 2.0 } },
  { name: 'Swift', effect: 'Move speed +30%', statModifier: { speed: 1.3 } },
  { name: 'Ironhide', effect: 'Damage taken -40%', statModifier: { damageTaken: 0.6 } },
  { name: 'Lucky', effect: 'Room output +10%', statModifier: { outputBonus: 1.1 } },
];

// === AWAKENING SYSTEM ===
interface Awakening {
  level: number;            // 1-6
  threshold: number;        // EN required
  mapSize: number;          // grid size at this level
  unlockedRooms: RoomType[];
  unlockedBeasts: BeastType[];
  portalCount: number;      // base portals per wave
  newEnemyTypes: string[];
  triggered: boolean;
}

const AWAKENINGS: Awakening[] = [
  { level: 1, threshold: 0,    mapSize: 5,  unlockedRooms: ['production', 'attack'],  unlockedBeasts: ['digger'],       portalCount: 1, newEnemyTypes: ['soldier'],          triggered: false },
  { level: 2, threshold: 100,  mapSize: 7,  unlockedRooms: ['detection', 'teleport'], unlockedBeasts: ['waterdragon'],  portalCount: 2, newEnemyTypes: ['archer'],           triggered: false },
  { level: 3, threshold: 300,  mapSize: 9,  unlockedRooms: ['refinery'],              unlockedBeasts: ['firebird'],     portalCount: 3, newEnemyTypes: ['monk'],             triggered: false },
  { level: 4, threshold: 600,  mapSize: 11, unlockedRooms: ['teleport_v2'],           unlockedBeasts: ['metalbeetle'],  portalCount: 4, newEnemyTypes: ['ninja', 'samurai'],  triggered: false },
  { level: 5, threshold: 1000, mapSize: 13, unlockedRooms: ['warehouse', 'excavation'], unlockedBeasts: ['woodspirit'], portalCount: 5, newEnemyTypes: ['hero'],             triggered: false },
  { level: 6, threshold: 2000, mapSize: 13, unlockedRooms: [],                        unlockedBeasts: [],               portalCount: 99, newEnemyTypes: ['boss'],            triggered: false },
];

// === NARRATIVE EVENTS ===
interface NarrativeEvent {
  id: string;
  name: string;
  nameCN: string;
  description: string;
  effect: (state: GameState) => void;
  probability: number;      // chance to trigger per wave (0-1)
  minWave: number;           // earliest wave this can appear
}

// === FINAL BOSS ===
interface Boss {
  id: string;
  name: string;             // '鎮龍將'
  x: number; y: number;
  hp: number;
  maxHp: number;
  currentElement: Element;
  elementCycleTimer: number;  // seconds until next element switch
  suppressionRadius: number;  // tiles around boss that are suppressed
  phase: 'siege' | 'march' | 'core';
  ritualTimer?: number;       // countdown in core phase
  path: {x: number, y: number}[];  // path to furnace
  pathIndex: number;
  portalTrailTimer: number;   // seconds until next portal spawned at position
}

// === HIDDEN TREASURES ===
interface Treasure {
  x: number; y: number;
  type: 'resources' | 'rare_tile' | 'beast_egg' | 'trap';
  revealed: boolean;          // discovered by scout or detection
  collected: boolean;
  contents: GachaTile | { energy: number, sentan: number } | Portal;
}

// === DRAGON VEIN RESONANCE ===
interface ResonanceChain {
  rooms: {x: number, y: number}[];  // rooms forming the chain
  elements: Element[];               // [wood, fire, earth, metal, water]
  active: boolean;
  turnsRemaining: number;            // 3 turns of bonus when activated
}

// === RUN SUMMARY ===
interface RunSummary {
  victory: boolean;
  awakeningReached: number;
  energyDeposited: number;
  roomsBuilt: number;
  beastsSummoned: number;
  portalsDestroyed: number;
  portalsBreached: number;
  fengShuiRating: number;       // 0-100, based on ki flow efficiency
  bestLuckMoment: string;
  seed: string;                  // procedural map seed for replay
  wavesCompleted: number;
  totalPlayTime: number;         // seconds
}
```

### Core Algorithms

#### Gacha Roll
```
function rollGacha(shop: GachaShop): GachaTile[] {
  const options: GachaTile[] = [];
  for (let i = 0; i < 3; i++) {
    let rarity = weightedRandom(RARITY_WEIGHTS);

    // Pity protection
    if (shop.pityCounter >= 10 && rarity === 'common') rarity = 'rare';
    if (shop.pityLegendary >= 30) rarity = 'legendary';

    const tile = generateTileOfRarity(rarity);
    options.push(tile);
  }
  return options;
}
```

#### Beast Patrol System
```
function updateBeastPatrols(beasts: Beast[], map: GameMap, dt: number):
  for each beast:
    targetRoom = beast.patrolRoute[beast.patrolIndex]
    move beast toward targetRoom at beast.speed * dt

    if beast arrived at targetRoom:
      // Execute role-specific action
      switch beast.type:
        case 'digger': transferResources(currentRoom, beast)
        case 'firebird': attackNearbyEnemies(beast)
        case 'waterdragon': revealFogInRadius(beast, map)
        case 'metalbeetle': blockCorridor(beast)
        case 'woodspirit': healRoom(currentRoom, beast)

      beast.patrolIndex = (beast.patrolIndex + 1) % beast.patrolRoute.length

    // Vision: beast reveals tiles in small radius around current position
    revealTilesAroundBeast(beast, map)
```

#### Awakening Trigger
```
function checkAwakenings(state: GameState):
  for each awakening in AWAKENINGS:
    if !awakening.triggered && state.resources.depositedEnergy >= awakening.threshold:
      awakening.triggered = true
      expandMap(state.map, awakening.mapSize)
      unlockRooms(awakening.unlockedRooms)
      unlockBeasts(awakening.unlockedBeasts)
      spawnTreasuresInNewArea(state.map)
      playAwakeningAnimation()
```

#### Map Expansion
```
function expandMap(map: GameMap, newSize: number):
  oldSize = map.width
  if newSize <= oldSize: return

  // Create new larger grid, copy old grid to center
  newMap = createGrid(newSize, newSize)
  offset = (newSize - oldSize) / 2
  for y in 0..oldSize:
    for x in 0..oldSize:
      newMap[y + offset][x + offset] = map.tiles[y][x]

  // New tiles are rock + fogged, some contain treasures
  for each new tile (not copied from old):
    tile.type = 'rock'
    tile.visible = false
    tile.revealed = false
    assignElement(tile)
    if random() < 0.08: placeTreasure(tile)  // 8% chance

  map.tiles = newMap.tiles
  map.width = newSize
  map.height = newSize
  // Recalculate furnace position (now offset)
```

#### Dragon Vein Resonance Detection
```
function checkResonance(map, rooms):
  // Find any chain of 5 connected rooms with all 5 elements in generation order
  for each room R where R.element === 'wood':
    chain = [R]
    current = R
    for next_element in ['fire', 'earth', 'metal', 'water']:
      neighbor = findConnectedRoomWithElement(current, next_element, map)
      if neighbor: chain.push(neighbor); current = neighbor
      else: break
    if chain.length === 5:
      return { rooms: chain, elements: [...], active: true, turnsRemaining: 3 }
  return null
```

#### Final Boss AI
```
function updateBoss(boss: Boss, map: GameMap, state: GameState, dt: number):
  switch boss.phase:
    case 'siege':
      // Open all portals on the map
      openAllRemainingPortals(map, state)
      // After 15 seconds, transition to march
      if siege_timer > 15: boss.phase = 'march'; computeBossPath(boss, map)

    case 'march':
      // Move along path toward furnace
      moveBossAlongPath(boss, dt)
      // Suppress rooms within radius
      suppressRoomsNearBoss(boss, map, state)
      // Cycle element every 10 seconds
      boss.elementCycleTimer -= dt
      if boss.elementCycleTimer <= 0:
        boss.currentElement = nextElement(boss.currentElement)
        boss.elementCycleTimer = 10
      // Spawn portal trail
      boss.portalTrailTimer -= dt
      if boss.portalTrailTimer <= 0:
        spawnPortalAtPosition(boss.x, boss.y, map)
        boss.portalTrailTimer = 8

      if bossReachedFurnace(boss, state):
        boss.phase = 'core'
        boss.ritualTimer = 60

    case 'core':
      boss.ritualTimer -= dt
      if state.resonanceActive:
        // Furnace fights back — damage boss periodically
        boss.hp -= RESONANCE_DAMAGE * dt
        // Briefly disable suppression aura
      if boss.ritualTimer <= 0: DEFEAT('sealed')
      if boss.hp <= 0: VICTORY()
```

### Rendering Changes (Phase 4 additions)

- Gacha shop: animated brewing cauldron UI, 3 tiles revealed with rarity glow borders
- Beast sprites: small animated creatures on patrol routes, dotted line showing their route
- Awakening animation: golden pulse from furnace, grid border expansion
- Treasure: glowing chest icons in fog, opening animation
- Narrative events: full-screen illustrated popup overlay
- Boss: large multi-tile sprite, suppression aura as dark circle, element indicator cycling, ritual countdown bar
- Resonance: golden energy beams connecting the 5-element chain rooms

### Acceptance Criteria

- [ ] Alchemy Gacha generates 3 options with correct rarity weights
- [ ] Reroll costs escalate, pity counter works
- [ ] All 5 仙獸 types functional with unique behaviors
- [ ] Patrol routes settable and beasts follow them
- [ ] Beast mutations trigger at 15% chance with correct stat modifiers
- [ ] Awakening triggers at correct EN thresholds
- [ ] Map expands correctly, preserving existing rooms
- [ ] New fog area contains treasures and traps
- [ ] Narrative events trigger randomly with correct effects
- [ ] Dragon Vein Resonance detects valid 5-element chains
- [ ] Resonance bonus (+50% output, reveal fog, bonus EN) works
- [ ] Final boss 3-phase fight works (siege → march → core)
- [ ] Boss suppression aura disables nearby rooms
- [ ] Boss element cycling and elemental weakness system works
- [ ] Boss ritual countdown → defeat if not stopped
- [ ] Resonance counters boss during core phase
- [ ] Victory/defeat screens with full run summary
- [ ] Seed code generated for replay
- [ ] Endless mode unlocks after victory

---

*End of Technical Build Spec.*
*技術建造規格書結束。*
