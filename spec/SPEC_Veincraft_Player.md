# Veincraft — Player Experience Spec
# 玩家體驗規格書

> What the player **sees, does, and feels** at each phase.
> 每個階段玩家**看到什麼、做什麼、感受什麼**。

---

## Phase 1: 骨架 Skeleton

### Opening Screen / 開始畫面
The player sees a **9×9 tile grid** representing underground rock. The center tile is the **Dragon Furnace (龍穴炉)** — a glowing golden tile that's always visible. An Energy bar at the top shows "0 / 300 EN" — the win target. A Furnace HP bar shows the Furnace's health.

### Build Phase — What the Player Does / 建造階段
1. The player is given **3 Energy** to start (enough to build 1–2 rooms).
2. The player taps any rock tile adjacent to an existing room or the Furnace. A menu appears with two options:
   - **Production Room** (cost: 2 EN) — depicted as a glowing yellow tile
   - **Attack Room** (cost: 3 EN) — depicted as a red tile with a crossbow icon
3. After placing a room, the player **draws a corridor** connecting it to the Furnace or another room. Corridors are 1-tile-wide paths. Enemies will walk through corridors.
4. A "Start Wave" button pulses when the player is ready.

### Defend Phase — What the Player Sees / 防禦階段
1. **Soldiers** (simple humanoid sprites) spawn from **fixed points on the map edges** (marked with red arrows before the wave).
2. Soldiers walk through corridors toward the Dragon Furnace.
3. When a Soldier passes through or adjacent to an **Attack Room**, the room fires a projectile (arrow/bolt animation). Damage numbers pop up.
4. If a Soldier reaches the Furnace, it attacks — the Furnace HP bar decreases with a screen shake.
5. The wave ends when all Soldiers are dead or the Furnace is destroyed.

### Between Waves / 波次之間
1. Each **Production Room** generates Energy (e.g., +3 EN per room per wave). The Energy counter ticks up with a satisfying sound.
2. The player can **deposit Energy** into the Furnace by tapping it. Deposited Energy goes toward the 300 EN win target and is removed from the player's spendable pool.
3. The player can build more rooms or save Energy.
4. A wave counter shows "Wave 2 / 10".

### What Victory Looks Like / 勝利畫面
When the player deposits 300 EN, the Furnace erupts with golden light. "龍脈復甦 — Dragon Vein Restored" text appears. Simple stats: waves survived, rooms built, energy deposited.

### What Defeat Looks Like / 失敗畫面
The Furnace cracks, goes dark. "龍穴炉崩毀 — Dragon Furnace Destroyed" text appears. Stats show how far the player got.

### The Feel / 遊戲感覺
Simple, clean, satisfying. Like a stripped-down puzzle. "I want to try a different room layout." The core question the player asks themselves: **"Where should I build, and when should I deposit?"**

---

## Phase 2: 迷霧 Fog

### What Changes Visually / 視覺上的變化
The 9×9 grid is now mostly **dark/fogged**. Only the Dragon Furnace tile and its immediate neighbors are visible at game start. The rest of the grid is covered in a dark fog texture with faint swirling particles.

The fixed enemy spawn arrows from Phase 1 are **gone**. Instead, the map edges are just fog.

### Build Phase — New Experience / 建造階段新體驗
1. Building a room **reveals its tile and adjacent corridors** — the fog pulls back with a smooth dissolve animation.
2. Two new room types are available:
   - **Detection Room** (cost: 3 EN) — depicted as a blue tile with an eye icon. When built, a translucent blue circle expands outward showing its detection radius (2 tiles beyond the room). Tiles in this radius become dimly visible (not fully clear, but enough to see if a portal is there).
   - **Teleport Room** (cost: 4 EN) — depicted as a purple swirl tile. When a second Teleport Room is built, a glowing line connects them. The player can tap one to instantly jump the camera (or eventually the player character) to the other.
3. The player now sees their dungeon as an **island of light** in a sea of fog.

### Defend Phase — The Portal Hunt / 防禦階段——蟲洞獵殺
1. At wave start, a **rumbling sound** plays. Directional indicators appear at the edge of the visible area — glowing red arrows pointing roughly toward portal locations (e.g., "something stirs to the northeast").
2. If a Detection Room covers the portal's location, the portal is **revealed on the map** as a swirling black vortex. The player can see enemies pouring out.
3. If no Detection Room covers it, the player only knows the direction. Enemies emerge from fog into visible corridors — the player sees them appear suddenly at the boundary of their vision.
4. **Portals are destructible.** The player must place an Attack Room near them, or in a later phase, send units. For now, the player can "spend" 5 EN to collapse a detected portal (temporary mechanic until 仙獸 arrive in Phase 4).
5. Each portal pumps out **1 Soldier every 3 seconds** until destroyed. A wave timer (60 seconds) counts down — surviving portals close when the timer ends, but damage is done.

### New Tension the Player Feels / 玩家感受到的新張力
- **"I can't see everything."** The player peers into fog, hearing rumbles, seeing enemies appear from nowhere. It's tense.
- **"Should I build outward to see more, or stay compact to defend?"** Each new room reveals more map but also adds portal spawn surface area.
- **"I need Detection Rooms but they don't produce or attack."** The information-vs-economy tradeoff is visceral.

### What a Typical Wave Feels Like / 典型波次的感覺
Wave starts. Rumble from the east. The player's Detection Room pings — portal spotted 3 tiles east. Enemies start pouring out. The player spends 5 EN to collapse it, but then a second rumble from the south — no detection coverage there. Soldiers appear at the south corridor unexpectedly. The player scrambles to decide: build an Attack Room to intercept, or sacrifice some Furnace HP and save resources for next wave?

---

## Phase 3: 五行 Elements

### What Changes Visually / 視覺上的變化
The grid tiles now have **subtle elemental coloring**:
- 🟤 Earth (brown) — center regions
- 🔴 Fire (red-orange) — south regions
- 🔵 Water (blue) — north regions
- 🟢 Wood (green) — east regions
- ⚪ Metal (silver/white) — west regions

When a room is built, it inherits the tile's element. The room tile gains an elemental icon in its corner. **Glowing ki lines** flow visually through corridors between connected rooms — green for generation (good), red for restraint (bad), white for neutral.

### New Room & Resource / 新房間與資源
- **Refinery Room (錬丹房)** (cost: 3 EN) — a green tile with a cauldron icon. Produces **Sentan (仙丹)**, a new resource shown as a green counter next to the yellow Energy counter.
- **Upgrade Tiles** — during Build phase, the player can spend Sentan to buy Upgrade Tiles from a simple shop (not random yet — fixed selection). Upgrade Tiles are placed adjacent to rooms and boost their stats. A small "+" icon appears on the upgraded room.

### Elemental Combat / 元素戰鬥
- Enemies now have elemental types, shown by colored auras: **Archer (Wood/green)**, **Monk (Water/blue)**, **Ninja (Metal/white)**, **Samurai (Fire/red)**, **Hero (Earth/brown)**.
- When an Attack Room's element **restrains** the enemy's element, damage numbers appear **larger and golden** with a "克！" (restrain!) popup.
- When elements are mismatched (restrained by enemy), damage numbers are **small and grey**.

### Ki Flow — What the Player Sees / 氣流——玩家看到的
- After building or connecting rooms, ki flow lines update in real-time.
- A room receiving generation ki shows a **green upward arrow** and a tooltip: "+30% output."
- A room receiving restraint ki shows a **red downward arrow**: "-20% output."
- The player can tap any room to see a detailed panel: element, current ki sources, output modifier, upgrade level.

### New Player Behavior / 玩家的新行為
The player now spends time in Build phase **staring at the element map**, planning: "If I build a Wood Production Room here, and connect it to this Fire Attack Room, the Wood generates Fire... that's +30% attack power!" The grid becomes a puzzle board. Bad placement has visible consequences — red arrows, reduced output.

### The Feel / 遊戲感覺
Deeper. More "aha!" moments. The player starts seeing the grid as a network of energy flows, not just a tower layout. "I didn't just place a room — I engineered a synergy."

---

## Phase 4: 命運 Fate

### What Changes Visually / 視覺上的變化
The UI is now richer. A new **Alchemy Furnace** icon appears in the Build phase toolbar — a bubbling cauldron. 仙獸 (small animated creatures) roam corridors on patrol paths shown as dotted lines. The map can now **expand** — when an Awakening triggers, the grid border pulses outward with golden light and new fog tiles appear.

### The Alchemy Gacha / 煉丹抽獎爐
1. Player taps the Alchemy Furnace. A brewing animation plays — three tiles spin/shuffle and reveal.
2. Each tile has a rarity glow: white (Common), green (Uncommon), purple (Rare), gold (Legendary).
3. Player picks one. A "Reroll" button costs increasing Sentan (3 → 6 → 12 → ...).
4. Tiles obtained include: room tiles, upgrade tiles, 仙獸 summon tokens, special items.
5. A small **pity counter** is visible: "Rare guaranteed in 4 brews."

### 仙獸 on the Map / 仙獸在地圖上
- **掘子仙 (Earth/brown)**: a mole-like creature carrying glowing orbs, running along corridors between Production and other rooms.
- **火鴉 (Fire/red)**: a flaming bird perched on Attack Rooms, swooping at enemies in range.
- **水蛟 (Water/blue)**: a serpentine creature leaving a blue trail as it scouts through fog, revealing tiles temporarily.
- **金甲蟲 (Metal/white)**: a beetle blocking a corridor, enemies stacking up against it.
- **木靈 (Wood/green)**: a wispy spirit floating over a damaged room, slowly repairing it (HP bar ticking up).

The player sets patrol routes during Manage phase by tapping a beast and dragging a path through rooms. Beasts follow these routes automatically during Defend phase.

### Dragon Vein Awakening / 龍脈覺醒
When the player deposits enough EN to cross an Awakening threshold:
1. **Screen shakes. Golden energy pulses from the Furnace outward.**
2. The grid border **expands** — new tiles appear shrouded in fog with sparkle particles (some are treasures, some are danger).
3. A popup announces the Awakening tier and what's unlocked: "龍脈三醒 — Alchemy Furnace now open!"
4. New enemy types appear in the next wave. The portal count increases.
5. The player feels: **"I just made the game harder on purpose... but now I have new tools."**

### Discovering Hidden Treasures / 發現隱藏寶物
When a 水蛟 scout or Detection Room reveals a fog tile containing a treasure:
- A **glowing chest icon** appears on the tile.
- The player must build a room or corridor to that tile to collect it.
- Opening it plays a loot animation: could be resources, a rare tile, a 仙獸 egg, or... a trap (mini-portal spawns!).

### Narrative Events / 敘事事件
Every few waves, a full-screen popup appears with illustrated art:
- 🏯 **"A merchant caravan has found your dungeon entrance."** — Special one-time shop with unique tiles.
- 🌪️ **"A Feng Shui storm sweeps through the earth!"** — All room elements shift one step. Ki flows rearrange. The player scrambles to assess damage/opportunity.
- 🧙 **"A wandering sage offers to bless one room..."** — Free upgrade, but the sage picks which room (could be your best room, could be your worst).

### The Final Boss: 鎮龍將 / 最終Boss
At 2000 EN deposited (龍脈圓滿):
1. **Cutscene**: The earth trembles. The sky above (shown as a top-bar illustration) darkens. A massive figure descends — the 鎮龍將, an armored general wreathed in sealing energy.
2. **Phase 1 — Siege**: ALL remaining portals open at once. The screen is chaos. Enemies flood from every direction. The player's 仙獸, Attack Rooms, and Detection network are tested to their limit.
3. **Phase 2 — March**: The 鎮龍將 appears on the map as a large tile-entity. It moves through corridors toward the Furnace. Rooms near it go dark (suppression aura). The player watches their defenses shut down in the boss's wake. The boss changes element every 10 seconds — the player must have diverse elemental Attack Rooms along its path.
4. **Phase 3 — Core**: The boss reaches the Furnace chamber. A ritual countdown begins (60 seconds). The player must throw everything at the boss. If Dragon Vein Resonance is active, the Furnace fires back — golden beams hit the boss, creating openings.
5. **Victory**: The boss shatters. The Furnace erupts in a pillar of golden light that fills the entire screen. "龍脈圓滿 — The Dragon Vein is Restored." Full run summary with stats, seed code, and Endless Mode unlock.

### The Feel / 遊戲感覺
Epic. The whole game has been building to this. Every system matters — your Feng Shui layout determines if the boss's element cycling is manageable, your Detection network determines if you can track the siege portals, your 仙獸 patrols determine if you can hold the line while the boss marches. The Gacha tiles you collected over 35 waves are your arsenal. It all comes together.

---

*End of Player Experience Spec.*
*玩家體驗規格書結束。*
