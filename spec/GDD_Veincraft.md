# Veincraft
## Game Design Document / 遊戲設計文件

> **Genre / 類型**: Roguelike Tower Defense × Dungeon-Building Simulation
> **References / 參考作品**: 仙窟活龍大戰 (Chaos Seed), Tile Tactics
> **Version / 版本**: 0.3 Draft
> **Date / 日期**: 2026-04-04

---

## Table of Contents / 目錄

1. [Game Vision / 遊戲願景](#1-game-vision--遊戲願景)
2. [Core Pillars / 核心支柱](#2-core-pillars--核心支柱)
3. [Game Loop / 遊戲循環](#3-game-loop--遊戲循環)
4. [The Grid & Room Tiles / 棋盤與房間圖塊](#4-the-grid--room-tiles--棋盤與房間圖塊)
5. [Feng Shui & Five Elements / 風水與五行系統](#5-feng-shui--five-elements--風水與五行系統)
6. [Fog of War & Portal Hunt / 戰爭迷霧與蟲洞獵殺](#6-fog-of-war--portal-hunt--戰爭迷霧與蟲洞獵殺)
7. [Economy: Energy & Sentan / 經濟系統：靈氣與仙丹](#7-economy-energy--sentan--經濟系統靈氣與仙丹)
8. [Alchemy Gacha Shop / 煉丹抽獎爐](#8-alchemy-gacha-shop--煉丹抽獎爐)
9. [Immortal Beasts (仙獸) / 仙獸系統](#9-immortal-beasts-仙獸--仙獸系統)
10. [Luck & Surprise Systems / 運氣與驚喜系統](#10-luck--surprise-systems--運氣與驚喜系統)
11. [Dragon Vein Awakening / 龍脈覺醒里程碑系統](#11-dragon-vein-awakening--龍脈覺醒里程碑系統)
12. [Victory, Defeat & Final Boss / 勝敗條件與最終 Boss](#12-victory-defeat--final-boss--勝敗條件與最終-boss)
13. [Wave Structure & Difficulty / 波次結構與難度曲線](#13-wave-structure--difficulty--波次結構與難度曲線)
14. [Key Differentiators / 核心差異化](#14-key-differentiators--核心差異化)
15. [Development Phases / 開發階段路線圖](#15-development-phases--開發階段路線圖)

---

## 1. Game Vision / 遊戲願景

**EN**: You are a 洞仙 (Cave Immortal) tasked with building a subterranean sanctuary to channel the earth's spiritual energy. But the surface world sees you as a threat — soldiers, monks, and heroes invade your dungeon through mysterious portals. You must build, defend, and adapt from *inside* your own dungeon, with limited visibility and unpredictable threats. Every run is different. Every layout is a new puzzle.

**CN**: 你扮演一位「洞仙」，在地底建造靈穴，引導大地靈氣修復龍脈。然而地表世界視你為威脅——士兵、僧侶、英雄透過神秘的蟲洞入侵你的仙窟。你必須在自己的仙窟**內部**建造、防禦、應變，視野有限，威脅不可預測。每次遊戲都是全新的局面，每種佈局都是獨特的謎題。

---

## 2. Core Pillars / 核心支柱

### Pillar 1: Build from Within / 從內部建造
**EN**: Unlike traditional TD where you have a god's-eye view, you exist *inside* the dungeon. You only see what your rooms and patrols reveal. Information is a resource.
**CN**: 不同於傳統 TD 的上帝視角，你存在於仙窟**內部**。你只能看到房間和巡邏隊所揭露的範圍。情報本身就是一種資源。

### Pillar 2: Elemental Harmony / 五行調和
**EN**: The Feng Shui Five Elements system makes spatial layout a deep strategic puzzle. Where you build matters as much as what you build.
**CN**: 風水五行系統讓空間佈局成為深度策略謎題。「在哪裡建」和「建什麼」同等重要。

### Pillar 3: Controlled Chaos / 可控的混沌
**EN**: Luck and randomness (gacha shop, portal spawns, hidden treasures) keep every run fresh, but player skill and knowledge always provide agency.
**CN**: 運氣與隨機性（煉丹抽獎、蟲洞位置、隱藏寶物）讓每次遊玩都充滿新鮮感，但玩家的技術和知識始終掌握主導權。

---

## 3. Game Loop / 遊戲循環

```
┌─────────────────────────────────────────────────────────┐
│                   SINGLE TURN / 單回合                    │
│                                                           │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐            │
│  │  BUILD    │───▶│  DEFEND   │───▶│  MANAGE   │───┐      │
│  │  建造階段  │    │  防禦階段  │    │  管理階段  │   │      │
│  └──────────┘    └──────────┘    └──────────┘   │      │
│       ▲                                          │      │
│       └──────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
```

### Phase 1: BUILD / 建造階段
**EN**: Spend Energy to dig new rooms, place tiles, connect corridors. The Feng Shui element of each room is determined by its grid position. You visit the **Alchemy Gacha Shop** to draft new room tiles and upgrades.
**CN**: 消耗靈氣開鑿新房間、放置圖塊、連接走廊。每個房間的五行屬性由其在棋盤上的位置決定。前往**煉丹抽獎爐**抽取新的房間圖塊與升級道具。

### Phase 2: DEFEND / 防禦階段 (Real-Time)
**EN**: Portals (蟲洞) spawn in hidden locations. Enemies pour out continuously. You must detect portal locations, travel to them through your dungeon, and destroy them — all while enemies flood your corridors. Your 仙獸 patrols fight automatically along their routes.
**CN**: 蟲洞在隱藏位置生成，敵人持續湧出。你必須偵測蟲洞位置、穿越仙窟抵達並摧毀它——同時敵人不斷湧入走廊。你的仙獸巡邏隊沿路線自動戰鬥。

### Phase 3: MANAGE / 管理階段
**EN**: Tally phase. Upgrade rooms using Sentan. Reassign 仙獸 patrol routes. Review fog-of-war intel. Prepare for the next wave.
**CN**: 結算階段。使用仙丹升級房間。重新分配仙獸巡邏路線。檢視迷霧情報。為下一波做準備。

---

## 4. The Grid & Room Tiles / 棋盤與房間圖塊

**EN**: The dungeon is built on a tile grid. Each tile can become a room or corridor. Rooms are the core building blocks, inspired by Chaos Seed's 9 room types merged with Tile Tactics' physical-tile-as-upgrade philosophy.

**CN**: 仙窟建立在圖塊棋盤上。每個圖塊可以成為房間或走廊。房間是核心建造單位，融合了仙窟活龍大戰的 9 種房間類型與 Tile Tactics 的「物理圖塊即升級」理念。

### Room Types / 房間類型

| Icon | Room Type | 房間類型 | Function (EN) | 功能 (CN) |
|------|-----------|---------|---------------|-----------|
| ⚡ | **Production Room** | 生產房 | Generates Energy (靈氣), the primary win-condition resource. Deposits into the Dragon Furnace. | 產生靈氣，主要勝利條件資源。存入龍穴炉。 |
| 🧪 | **Refinery Room** | 錬丹房 | Produces Sentan (仙丹) used to upgrade rooms and brew in the Gacha Shop. | 產生仙丹，用於升級房間和在抽獎爐中煉製。 |
| 🐉 | **Summoning Room** | 召喚房 | Summons 仙獸 (Immortal Beasts) for patrol, combat, and logistics. | 召喚仙獸，執行巡邏、戰鬥和物流任務。 |
| ⚔️ | **Attack Room** | 攻擊房 | Automated trap/tower. Damages enemies passing through. The "tower" of our TD. | 自動陷阱/塔。對經過的敵人造成傷害。本遊戲的「塔防塔」。 |
| 📦 | **Warehouse** | 倉庫房 | Stores items and overflow resources. Increases carry capacity. | 儲存道具和溢出的資源。增加負載量。 |
| ⛏️ | **Excavation Room** | 掘削房 | Digs up hidden items, reveals map secrets. Chance to find rare tiles. | 挖掘隱藏道具，揭示地圖秘密。有機率挖出稀有圖塊。 |
| 👁️ | **Detection Room** | 探知房 | Reveals fog of war in a radius. Detects portal locations. **Critical for the visibility mechanic.** | 揭示一定範圍的戰爭迷霧。偵測蟲洞位置。**視野機制的關鍵。** |
| 🌀 | **Teleport Room** | 轉送房 | Allows instant travel between linked Teleport Rooms. Essential for large dungeons. | 允許在已連結的轉送房之間瞬間移動。大型仙窟的必需品。 |
| 🔥 | **Dragon Furnace** | 龍穴炉 | The core. Deposit Energy here to progress. Always present. Must be defended at all costs. | 核心。在此存入靈氣以推進進度。始終存在。必須不惜一切代價防守。 |

### Upgrade Tiles (Tile Tactics Influence) / 升級圖塊

**EN**: In addition to room tiles, players can acquire **Upgrade Tiles** from the Alchemy Gacha. These are placed **adjacent** to rooms to boost their stats — just like Tile Tactics. An Upgrade Tile next to a Production Room increases its Energy output; next to an Attack Room, it increases damage or adds elemental effects.

**CN**: 除了房間圖塊外，玩家還可以從煉丹抽獎爐獲取**升級圖塊**。這些圖塊放置在房間**相鄰位置**以提升屬性——就像 Tile Tactics 一樣。升級圖塊放在生產房旁邊會增加靈氣產出；放在攻擊房旁邊則增加傷害或附加五行效果。

---

## 5. Feng Shui & Five Elements / 風水與五行系統

**EN**: This is the game's signature strategic layer. Every tile on the grid has an inherent elemental attribute based on its position. When you build a room on that tile, the room inherits that element.

**CN**: 這是本遊戲的標誌性策略層。棋盤上每個圖塊根據位置擁有固有的五行屬性。當你在該圖塊上建造房間時，房間繼承該屬性。

### The Five Elements / 五行

```
        木 Wood
       ↗     ↘
    水 Water   火 Fire        ← 相生 (Generation Cycle)
       ↖     ↙                  Flows clockwise
        金 Metal ← 土 Earth


        木 Wood
       ↗     ↘
    土 Earth   金 Metal       ← 相剋 (Restraint Cycle)
       ↖     ↙                  Star pattern
        火 Fire ← 水 Water
```

### Generation Cycle / 相生循環
**Wood → Fire → Earth → Metal → Water → Wood**

**EN**: When a room receives ki (energy flow) from a room of its *generating* element through a connecting corridor, it gets a significant **production bonus** (+30% base output) and unlocks special upgrade paths.

**CN**: 當房間透過連接走廊從其「相生」元素的房間接收氣（能量流）時，獲得顯著的**產出加成**（+30% 基礎產出）並解鎖特殊升級路徑。

### Restraint Cycle / 相剋循環
**Wood → Earth → Water → Fire → Metal → Wood**

**EN**: Ki from a *restraining* element causes a **production penalty** (-20% base output) and may disable certain upgrades. However, restraint relationships can be *weaponized* — an Attack Room receiving restrained ki deals bonus elemental damage to enemies of the restrained element.

**CN**: 來自「相剋」元素的氣會造成**產出懲罰**（-20% 基礎產出）並可能禁用某些升級。然而，相剋關係可以被**武器化**——接收被剋氣的攻擊房對被剋屬性的敵人造成額外元素傷害。

### Neutral Relations / 中性關係
**EN**: All other element pairings provide a small bonus (+5%). This encourages diverse layouts rather than mono-element builds.

**CN**: 所有其他元素配對提供小幅加成（+5%）。這鼓勵多元佈局而非單一屬性的建法。

### Feng Shui Flow Rules / 風水流動規則

1. **Ki flows through corridors only** / 氣只透過走廊流動 — no diagonal or wall-penetrating flow. Corridor design IS Feng Shui design. / 不能對角或穿牆流動。走廊設計就是風水設計。
2. **Ki strength decays with distance** / 氣的強度隨距離衰減 — adjacent rooms get full effect, 2 rooms away get 50%, 3+ rooms get 10%. / 相鄰房間獲得完整效果，隔2間獲得50%，3間以上獲得10%。
3. **Multiple ki sources stack** / 多重氣源可疊加 — but with diminishing returns. / 但遞減效益。
4. **Dragon Vein Resonance** / 龍脈共鳴 — when all 5 elements are present in a connected chain (Wood→Fire→Earth→Metal→Water), a powerful resonance bonus activates for the entire chain. This is the "jackpot" layout. / 當五行元素在一條連通鏈中全部出現（木→火→土→金→水）時，整條鏈啟動強力共鳴加成。這就是「大獎」佈局。

---

## 6. Fog of War & Portal Hunt / 戰爭迷霧與蟲洞獵殺

> **This is the single biggest differentiator from standard TD games.**
> **這是與標準 TD 遊戲最大的差異化設計。**

### The Problem with Standard TD / 傳統 TD 的問題

**EN**: In most tower defense games, the player has **global visibility** — you see every enemy, every path, every tile. The entire challenge is optimization with perfect information. This makes games feel like math puzzles rather than living, reactive experiences.

**CN**: 在大多數塔防遊戲中，玩家擁有**全局視野**——看到每個敵人、每條路徑、每個格子。整個挑戰就是在完美資訊下做最佳化。這讓遊戲感覺像數學題而非鮮活的、需要即時應變的體驗。

### Our Approach: Limited Visibility / 我們的做法：有限視野

**EN**: The player can only see:

**CN**: 玩家只能看到：

1. **Built rooms and their immediate corridors** / 已建造的房間及其直接走廊
2. **Detection Room radius** (scales with room level) / 探知房的偵測半徑（隨房間等級擴大）
3. **仙獸 patrol vision** — beasts on patrol reveal tiles along their route / 仙獸巡邏視野——巡邏中的仙獸揭示路線上的圖塊
4. **Temporary reveals** — from items, abilities, or lucky events / 暫時揭示——來自道具、技能或幸運事件

**Everything else is fog.** / **其他一切都是迷霧。**

### Portal Mechanics / 蟲洞機制

**EN**: At the start of each Defend phase, **1–N portals** spawn at random locations on the grid (including in fog). Each portal continuously pumps out enemies until it is destroyed. The number of portals scales with dungeon size — a larger dungeon means more potential spawn points.

**CN**: 每個防禦階段開始時，**1到N個蟲洞**在棋盤隨機位置生成（包括在迷霧中）。每個蟲洞持續湧出敵人，直到被摧毀。蟲洞數量隨仙窟規模擴增——更大的仙窟意味著更多潛在生成點。

### Detection & Response / 偵測與應對

```
Portal Spawns in Fog                Enemies appear at dungeon border
       │                                        │
       ▼                                        ▼
Detection Room picks up signal          "Something is coming from the east"
       │                                        │
       ▼                                        ▼
Player sees portal ping on map          Player must investigate
       │                                        │
       ▼                                        ▼
Travel to portal (or send 仙獸)         Destroy portal to stop flow
```

**EN**: Detection Rooms provide varying levels of intel:

**CN**: 探知房提供不同等級的情報：

| Level / 等級 | Intel Quality / 情報品質 | EN | CN |
|---|---|---|---|
| Lv.1 | **Ping** | "A portal exists somewhere in the north quadrant" | 「北方象限某處存在蟲洞」 |
| Lv.2 | **Direction** | "A portal is 4 tiles northeast of Detection Room" | 「蟲洞在探知房東北方4格處」 |
| Lv.3 | **Precise** | Exact tile revealed on map, plus enemy type preview | 精確圖塊在地圖上顯示，附帶敵人類型預覽 |
| Lv.4 | **Precognition** | Reveals portal location **before** it spawns (1 turn advance warning) | 在蟲洞生成**之前**揭示其位置（提前1回合預警） |

### Why This Creates Strategy / 為什麼這創造了策略

**EN**:
- **Compact vs. Sprawling dungeon dilemma**: Small dungeon = easy to defend, few blind spots, but less economy. Large dungeon = powerful economy, but more fog, more portals, longer response time.
- **Detection is an investment**: Detection Rooms don't produce or kill — they provide information. Early game, they feel like a luxury. Late game, they're survival.
- **Teleport Rooms become critical infrastructure**: Without them, a portal on the far side of a large dungeon may be unreachable before it overwhelms you.
- **仙獸 patrols serve triple duty**: logistics (carrying resources), combat (fighting enemies), and **scouting** (providing vision along their route).

**CN**:
- **緊湊 vs. 擴張的仙窟困境**：小仙窟=容易防守、盲點少，但經濟弱。大仙窟=經濟強大，但迷霧多、蟲洞多、反應時間長。
- **偵測是一種投資**：探知房不生產也不殺敵——它提供情報。前期感覺是奢侈品，後期就是生存必需品。
- **轉送房成為關鍵基礎設施**：沒有它們，大型仙窟遠端的蟲洞可能在壓垮你之前無法到達。
- **仙獸巡邏身兼三職**：物流（搬運資源）、戰鬥（對抗敵人）和**偵察**（沿路線提供視野）。

---

## 7. Economy: Energy & Sentan / 經濟系統：靈氣與仙丹

### Two-Resource Model / 雙資源模型

| Resource / 資源 | Symbol | Source / 來源 | Use / 用途 |
|---|---|---|---|
| **Energy / 靈氣** | ⚡ EN | Production Rooms / 生產房 | Deposit into Dragon Furnace (win condition). Also powers room operations. / 存入龍穴炉（勝利條件）。也為房間運作供電。 |
| **Sentan / 仙丹** | 🧪 SN | Refinery Rooms / 錬丹房 | Upgrade rooms, brew in Gacha Shop, summon 仙獣. / 升級房間、在抽獎爐煉製、召喚仙獣。 |

### Economic Tension / 經濟張力

**EN**: Every room **consumes** Energy to operate. If a room's consumption exceeds the Energy flowing to it, it gradually shuts down. This means:
- You can't just build unlimited rooms — each one is an ongoing cost
- 仙獸 (via Digger Beasts) must transport Energy from Production Rooms to other rooms
- Over-investing in Refineries starves your Energy pipeline
- Over-investing in Production means no upgrades

**CN**: 每個房間都**消耗**靈氣來運作。如果房間的消耗超過流入的靈氣，它會逐漸停擺。這意味著：
- 你不能無限建造房間——每間都是持續成本
- 仙獸（透過掘子仙）必須將靈氣從生產房搬運到其他房間
- 過度投資錬丹房會餓死靈氣管線
- 過度投資生產房則意味著沒有升級

---

## 8. Alchemy Gacha Shop / 煉丹抽獎爐

> **Inspired by Tile Tactics' Slot Shop, themed as Daoist alchemy.**
> **靈感來自 Tile Tactics 的老虎機商店，主題化為道家煉丹。**

### How It Works / 運作方式

**EN**: Between waves (during the Build phase), you can visit the **煉丹爐 (Alchemy Furnace)**. Spend Sentan to "brew" a batch of random tiles. You're presented with 3 options. You may:
1. **Pick one** (free)
2. **Reroll** (costs additional Sentan — each reroll costs more)
3. **Skip** (save your Sentan)

**CN**: 在波次之間（建造階段），你可以造訪**煉丹爐**。消耗仙丹「煉製」一批隨機圖塊。你會看到3個選項。你可以：
1. **選擇一個**（免費）
2. **重新煉製**（消耗額外仙丹——每次重煉費用遞增）
3. **跳過**（保存仙丹）

### Tile Rarity / 圖塊稀有度

| Rarity / 稀有度 | Drop Rate / 掉落率 | Example / 範例 |
|---|---|---|
| 🤍 Common / 普通 | 60% | Basic room tiles, minor upgrades / 基礎房間圖塊、小升級 |
| 💚 Uncommon / 稀有 | 25% | Leveled rooms, elemental upgrade tiles / 進階房間、元素升級圖塊 |
| 💜 Rare / 珍貴 | 12% | Dual-element rooms, powerful trap tiles / 雙屬性房間、強力陷阱圖塊 |
| 💛 Legendary / 傳說 | 3% | Dragon Vein tiles, mythic 仙獸 summons / 龍脈圖塊、神話級仙獸召喚 |

### Bad Luck Protection / 保底機制

**EN**: After 10 brews without a Rare or better, the next brew is guaranteed Rare+. After 30 brews without a Legendary, the next is guaranteed Legendary. This prevents frustration while preserving the thrill.

**CN**: 連續10次煉製未出珍貴或以上時，下次煉製保證出珍貴+。連續30次未出傳說時，下次保證出傳說。這在保留刺激感的同時防止挫敗感。

---

## 9. Immortal Beasts (仙獸) / 仙獸系統

**EN**: 仙獸 are your automated workforce and army. Summoned from Summoning Rooms, they perform three critical roles simultaneously.

**CN**: 仙獸是你的自動化勞動力和軍隊。從召喚房召喚，同時執行三個關鍵角色。

### Roles / 角色

| Role / 角色 | EN | CN |
|---|---|---|
| 🚚 **Logistics** | Transport Energy and Sentan between rooms along patrol routes | 沿巡邏路線在房間之間搬運靈氣和仙丹 |
| ⚔️ **Combat** | Fight enemies encountered along patrol routes | 對抗巡邏路線上遇到的敵人 |
| 👁️ **Scouting** | Reveal fog-of-war tiles along their patrol path | 揭示巡邏路徑上的戰爭迷霧圖塊 |

### Beast Types / 仙獸類型

| Beast / 仙獸 | Element / 屬性 | Specialty / 專長 | EN | CN |
|---|---|---|---|---|
| 掘子仙 | Earth / 土 | Logistics-focused, high carry capacity | Heavy hauler, moves resources fast | 重型搬運者，快速搬運資源 |
| 火鴉 | Fire / 火 | Combat-focused, area damage | Burns enemies in patrol zone | 在巡邏區域燒傷敵人 |
| 水蛟 | Water / 水 | Scouting-focused, wide vision | Reveals large fog area | 揭示大範圍迷霧 |
| 金甲蟲 | Metal / 金 | Defense-focused, blocks corridors | Tanks damage, slows enemies | 承受傷害，減緩敵人 |
| 木靈 | Wood / 木 | Support-focused, heals rooms | Repairs damaged rooms over time | 隨時間修復受損房間 |

### Mutation System / 突變系統

**EN**: When summoned, each 仙獸 has a small chance (15%) to mutate with a random bonus trait. Mutations are permanent for that beast and add replayability through emergent combinations.

**CN**: 召喚時，每隻仙獸有小機率（15%）突變獲得隨機加成特質。突變對該仙獸永久有效，透過湧現的組合增加重玩價值。

**Example Mutations / 突變範例:**
- 🔥 **Blazing** / 熾焰 — attack speed +50%
- 👁️ **Far-Sighted** / 遠見 — scout vision radius doubled
- 💨 **Swift** / 迅捷 — movement speed +30%
- 🛡️ **Ironhide** / 鐵甲 — damage taken -40%
- ✨ **Lucky** / 福星 — rooms this beast visits produce +10% resources

---

## 10. Luck & Surprise Systems / 運氣與驚喜系統

> **Design Philosophy: Luck should create memorable moments, not determine outcomes.**
> **設計理念：運氣應該創造難忘的時刻，而不是決定結果。**

### Luck Event Categories / 運氣事件分類

#### A. Alchemy Gacha (Controlled Luck / 可控運氣)
**EN**: The shop is the primary luck injection. Players choose *when* to engage with it and *how much* to invest in rerolls. Bad luck protection ensures no one gets permanently screwed.
**CN**: 商店是主要的運氣注入點。玩家選擇*何時*參與以及*投入多少*在重煉上。保底機制確保沒人被永久坑。

#### B. Portal Spawn RNG (Reactive Luck / 應變運氣)
**EN**: Portal locations are random each wave. Sometimes they spawn conveniently near your Attack Rooms (lucky!). Sometimes they spawn deep in uncharted fog (terrifying!). This forces adaptive play.
**CN**: 蟲洞位置每波隨機。有時它們恰好生成在攻擊房附近（幸運！）。有時它們生成在未探索的深層迷霧中（恐怖！）。這迫使玩家適應性遊玩。

#### C. Hidden Treasures (Exploration Luck / 探索運氣)
**EN**: Inspired by Tile Tactics' destructible terrain. Certain fog tiles contain hidden caches:
- 💰 Resource caches (bonus Energy/Sentan)
- 🎁 Rare room tiles or upgrade tiles
- ⚠️ Trap tiles (surprise! — mini-portal or enemy ambush)
- 🐉 Ancient 仙獸 eggs (hatch into pre-mutated legendary beasts)

Excavation Rooms and scouting 仙獸 can discover these. Risk/reward: exploring fog means stretching your visibility thin.

**CN**: 靈感來自 Tile Tactics 的可破壞地形。某些迷霧圖塊包含隱藏寶箱：
- 💰 資源寶箱（額外靈氣/仙丹）
- 🎁 稀有房間圖塊或升級圖塊
- ⚠️ 陷阱圖塊（驚喜！——迷你蟲洞或敵人伏擊）
- 🐉 遠古仙獸蛋（孵化為預突變的傳說級仙獸）

掘削房和偵察仙獸可以發現這些。風險/回報：探索迷霧意味著拉伸你的視野。

#### D. Dragon Vein Resonance (Achievement Luck / 成就運氣)
**EN**: When you successfully create a full 5-element generation chain (Wood→Fire→Earth→Metal→Water, all connected), the 龍脈共鳴 (Dragon Vein Resonance) triggers:
- All rooms in the chain get **+50% output** for 3 turns
- A burst of light reveals **all fog** temporarily
- The Dragon Furnace generates bonus Energy automatically
- A rare "Golden Tile" appears in the next Gacha shop

This is the "jackpot" — hard to achieve, massively rewarding, and it feels *earned* rather than random.

**CN**: 當你成功建立完整的五行相生鏈（木→火→土→金→水，全部連通）時，龍脈共鳴觸發：
- 鏈中所有房間**+50% 產出**持續3回合
- 一道光芒暫時揭示**所有迷霧**
- 龍穴炉自動產生額外靈氣
- 下次抽獎爐出現稀有「黃金圖塊」

這就是「大獎」——難以達成、回報豐厚，而且感覺是*靠實力獲得*而非隨機。

#### E. Critical Events (Narrative Luck / 敘事運氣)
**EN**: Every few waves, a random narrative event occurs:
- 🏯 **Merchant caravan** — special one-time shop with unique tiles
- 🌪️ **Feng Shui storm** — all room elements shift one step in the generation cycle (massive disruption + opportunity)
- 🧙 **Wandering Sage** — offers to upgrade one room for free, but you must let them choose which one
- ☯️ **Yin-Yang Reversal** — generation and restraint cycles swap for 2 turns (chaos!)
- 🎋 **Spirit Bloom** — one random room gains a permanent +1 level

**CN**: 每隔幾波，會發生隨機敘事事件：
- 🏯 **商隊到訪** — 特殊一次性商店，販售獨特圖塊
- 🌪️ **風水風暴** — 所有房間屬性沿相生循環移動一步（巨大動盪+機遇）
- 🧙 **遊方仙人** — 提議免費升級一間房間，但必須讓他選擇是哪間
- ☯️ **陰陽逆轉** — 相生和相剋循環交換2回合（大混亂！）
- 🎋 **靈華綻放** — 一間隨機房間永久獲得+1等級

---

## 11. Dragon Vein Awakening / 龍脈覺醒里程碑系統

> **The Dragon Furnace is not a bucket to fill — it is a tree that grows.**
> **龍穴炉不是一個要裝滿的水桶——它是一棵會成長的樹。**

### Core Concept / 核心概念

**EN**: Instead of a single "deposit X Energy to win" goal, the Dragon Furnace has multiple **awakening thresholds**. Each time you deposit enough Energy to reach a threshold, the 龍脈 (Dragon Vein) "awakens" one level, triggering three simultaneous effects: the buildable map expands, new game mechanics unlock, and threats escalate. The final awakening summons the ultimate boss.

**CN**: 龍穴炉不是單一的「存入X靈氣就贏」目標，而是有多個**覺醒門檻**。每次你存入足夠靈氣達到門檻，龍脈就「覺醒」一層，同時觸發三件事：可建築地圖擴張、新遊戲機制解鎖、威脅升級。最終覺醒將召喚終極 Boss。

### Awakening Milestones / 覺醒里程碑

| Awakening / 覺醒 | EN Threshold / 靈氣門檻 | Map Expansion / 地圖擴張 | Unlocks (EN) | 解鎖內容 (CN) | New Threat (EN) | 新威脅 (CN) |
|---|---|---|---|---|---|---|
| 🌱 **初醒 — First Stirring** | 100 EN | Starting zone only (5×5) | Basic rooms: Production, Attack, Warehouse. First 仙獸: 掘子仙 | 基礎房間：生產、攻擊、倉庫。首隻仙獸：掘子仙 | 1 portal/wave, Soldiers only | 每波1蟲洞，僅士兵 |
| 🌿 **二醒 — Roots Spread** | 300 EN | +Ring 1 expansion (7×7) | Detection Room, Fog of War fully activates, 水蛟 (scout beast) | 探知房、戰爭迷霧正式啟動、水蛟（偵察仙獸） | 2 portals/wave, Archers appear | 每波2蟲洞，弓手出現 |
| 🌳 **三醒 — Branches Reach** | 600 EN | +Ring 2 expansion (9×9) | Refinery Room, Alchemy Gacha Shop opens, 火鴉 (combat beast) | 錬丹房、煉丹抽獎爐開放、火鴉（戰鬥仙獸） | 3 portals/wave, Monks (healers) appear | 每波3蟲洞，僧侶（治療者）出現 |
| 🌲 **四醒 — Crown Rises** | 1000 EN | +Ring 3 expansion (11×11) | Teleport Room, Summoning Room upgrades, Five Element restraint weaponization, 金甲蟲 (tank beast) | 轉送房、召喚房升級、五行相剋武器化、金甲蟲（坦克仙獸） | 4 portals/wave, Ninjas (bypass rooms), Samurai (destroy rooms) | 每波4蟲洞，忍者（繞過房間）、武士（破壞房間）出現 |
| 🐉 **五醒 — Dragon Vein Pulses** | 1500 EN | +Ring 4 expansion (13×13), hidden chambers appear | Dragon Vein Resonance activatable, Legendary tiles in Gacha, 木靈 (healer beast), Narrative events begin | 龍脈共鳴可觸發、傳說級圖塊出現、木靈（治療仙獸）、敘事事件開始 | 5+ portals/wave, Hero (boss unit) appears, Elite portals possible | 每波5+蟲洞，英雄（Boss單位）出現、精英蟲洞可能出現 |
| ☯️ **圓滿 — Dragon Vein Restored** | 2000 EN | Full map revealed | — | — | **FINAL BOSS: 鎮龍將 (Dragon Suppressor General) arrives** | **最終Boss：鎮龍將 降臨** |

### Design Intent / 設計意圖

**EN**:

- **Natural tutorial**: Players start with only 3 room types. No information overload. Each awakening introduces 1–2 new systems when the player is ready.
- **Pacing reset**: Each awakening feels like a "mini new game" — new map area, new tools, new enemies. The game constantly evolves rather than repeating.
- **Self-imposed difficulty**: Depositing Energy to trigger awakenings is *voluntary*. Players actively make the game harder in exchange for progress. This creates a strategic choice: "Am I ready for the next awakening, or should I consolidate?"
- **Delayed deposit strategy**: Advanced players may hoard Energy in Production Rooms to strengthen infrastructure before triggering an awakening in one large deposit. This creates a "rush" vs. "turtle" strategic spectrum.

**CN**:

- **自然教學**：玩家起始只有3種房間。無資訊過載。每次覺醒在玩家準備好時引入1-2個新系統。
- **節奏重置**：每次覺醒感覺像「迷你新開局」——新地圖區域、新工具、新敵人。遊戲持續進化而非重複。
- **自主加難**：存入靈氣觸發覺醒是*自願的*。玩家主動讓遊戲變難以換取進度。這創造了策略選擇：「我準備好迎接下一次覺醒了嗎？還是應該先鞏固？」
- **延遲存入策略**：進階玩家可能會將靈氣囤在生產房中以強化基礎設施，再一次大量存入觸發覺醒。這產生了「速攻」vs.「穩紮穩打」的策略光譜。

### Map Expansion Visual / 地圖擴張示意

```
  Awakening 1 (初醒)        Awakening 3 (三醒)         Awakening 5 (五醒)
  ┌─────────┐              ┌─────────────────┐        ┌─────────────────────┐
  │ · · · · │              │ ░ ░ ░ ░ ░ ░ ░ ░│        │ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓│
  │ · · 炉 · │              │ ░ · · · · · · ░│        │ ▓ ░ ░ ░ ░ ░ ░ ░ ░ ▓│
  │ · · · · │              │ ░ · · · · · · ░│        │ ▓ ░ · · · · · · ░ ▓│
  │ · · · · │              │ ░ · · 炉 · · · ░│        │ ▓ ░ · · · · · · ░ ▓│
  └─────────┘              │ ░ · · · · · · ░│        │ ▓ ░ · · 炉 · · · ░ ▓│
   5×5 tiles                │ ░ · · · · · · ░│        │ ▓ ░ · · · · · · ░ ▓│
   Known & safe             │ ░ ░ ░ ░ ░ ░ ░ ░│        │ ▓ ░ · · · · · · ░ ▓│
                            └─────────────────┘        │ ▓ ░ ░ ░ ░ ░ ░ ░ ░ ▓│
                             9×9 tiles                  │ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓│
                             ░ = new fog zone            └─────────────────────┘
                                                         13×13 tiles
   · = explored/buildable                                ▓ = deep fog (treasures & danger)
```

---

## 12. Victory, Defeat & Final Boss / 勝敗條件與最終 Boss

### Victory: Defeat the 鎮龍將 / 勝利：擊敗鎮龍將

**EN**: When the player deposits 2000 EN (triggering 龍脈圓滿), the final event begins. The Dragon Vein's full restoration sends a shockwave to the surface world, and the surface kingdom dispatches their ultimate weapon: the **鎮龍將 (Dragon Suppressor General)** — a legendary warrior whose sole purpose is to seal Dragon Veins permanently.

The final boss does not simply walk down a corridor. The 鎮龍將 arrives with a **full-scale invasion force** and **unique boss mechanics** that test everything the player has built.

**CN**: 當玩家存入 2000 靈氣（觸發龍脈圓滿）時，最終事件開始。龍脈完全復甦的衝擊波傳到地表，地表王國派出終極武器：**鎮龍將**——一位傳說中的戰士，唯一使命就是永久封印龍脈。

最終 Boss 不會只是走過走廊。鎮龍將帶著**全面入侵部隊**和**獨特Boss機制**到來，考驗玩家所建造的一切。

### Final Boss: 鎮龍將 (Dragon Suppressor General) / 最終Boss：鎮龍將

#### Phase 1: The Siege / 第一階段：圍攻

**EN**: The 鎮龍將 opens **ALL remaining portals simultaneously** across the entire map. The dungeon is flooded with enemies from every direction. The player must rely on their full infrastructure — Attack Rooms, 仙獸 patrols, Detection network — to manage the chaos while the boss approaches.

**CN**: 鎮龍將同時開啟地圖上**所有剩餘蟲洞**。仙窟從四面八方被敵人淹沒。玩家必須依靠完整基礎設施——攻擊房、仙獸巡邏、探知網路——來管控混亂，同時Boss逼近。

#### Phase 2: The March / 第二階段：進軍

**EN**: The 鎮龍將 begins moving toward the Dragon Furnace, choosing the **most direct path** through your dungeon. Key boss traits:

- **Dragon Seal Aura (封龍結界)**: Rooms within 2 tiles of the boss are **suppressed** — Attack Rooms stop firing, Production Rooms stop generating, Detection Rooms go dark. The boss creates a moving dead zone.
- **Element Breaker (破行者)**: The boss cycles through all 5 elements. It is only vulnerable to the element that **restrains** its current element. Players must position the correct elemental Attack Rooms along its path or use the right elemental 仙獸.
- **Portal Commander (蟲洞指揮)**: Every N seconds, the boss spawns a new portal at its current location, leaving a trail of portals behind it.

**CN**: 鎮龍將開始向龍穴炉前進，選擇穿過你仙窟的**最直接路徑**。關鍵Boss特性：

- **封龍結界**：Boss 2格範圍內的房間被**壓制**——攻擊房停止開火、生產房停止產出、探知房變暗。Boss創造一個移動的死區。
- **破行者**：Boss在五行之間循環切換。它只對**剋制**其當前屬性的元素易傷。玩家必須沿其路徑布置正確屬性的攻擊房或使用正確屬性的仙獸。
- **蟲洞指揮**：每N秒，Boss在當前位置生成新蟲洞，在身後留下一串蟲洞。

#### Phase 3: The Core / 第三階段：核心

**EN**: When the 鎮龍將 reaches the Dragon Furnace chamber, it begins a **channeling ritual** to seal the Dragon Vein. A countdown appears. The player has a limited window to deal enough damage to interrupt the ritual. If the player has achieved **Dragon Vein Resonance** (full 5-element chain), the Furnace fights back — emitting bursts of energy that damage the boss and briefly dispel the Dragon Seal Aura.

Victory = destroy the 鎮龍將 before the ritual completes. The Dragon Vein is permanently restored. The surface world is forced to acknowledge the Cave Immortal.

**CN**: 當鎮龍將抵達龍穴炉房間時，開始**封印儀式**以封鎖龍脈。出現倒數計時。玩家有限時間造成足夠傷害以打斷儀式。如果玩家已達成**龍脈共鳴**（完整五行鏈），龍穴炉會反擊——釋放能量爆發傷害Boss並短暫驅散封龍結界。

勝利 = 在儀式完成前摧毀鎮龍將。龍脈永久復甦。地表世界被迫承認洞仙的存在。

### Defeat Conditions / 失敗條件

| Condition / 條件 | Trigger (EN) | 觸發條件 (CN) | Feel / 感受 |
|---|---|---|---|
| 🔥 **Dragon Furnace Destroyed / 龍穴炉被摧毀** | Enemies deal enough damage to reduce Furnace HP to 0 | 敵人對龍穴炉造成足夠傷害使其HP歸零 | Sudden, dramatic. Classic "base destroyed" TD fail. / 突然、戲劇性。經典「基地被毀」TD失敗。 |
| 🌑 **Total Blackout / 全面停擺** | All rooms lose Energy simultaneously — no Production Rooms operating, no stored Energy anywhere | 所有房間同時失去靈氣——無生產房運作、無任何靈氣儲存 | Slow, economic death. Over-expanded, under-produced, or key rooms destroyed without recovery. / 緩慢的經濟死亡。過度擴張、產出不足、或關鍵房間被毀無法恢復。 |
| ☯️ **Dragon Vein Sealed / 龍脈被封印** | (Final boss only) 鎮龍將 completes the sealing ritual at the Dragon Furnace | （僅限最終Boss）鎮龍將在龍穴炉完成封印儀式 | Narrative defeat. You built everything, reached the end, but couldn't stop the final threat. / 敘事性失敗。你建造了一切、走到了終點，卻無法阻止最後的威脅。 |

### Post-Run / 單局結束後

**EN**: Regardless of victory or defeat, each run generates a **Run Summary** showing:
- Total Energy deposited / awakening level reached
- Rooms built, tiles placed, 仙獸 summoned
- Portals destroyed vs. portals that breached
- Feng Shui efficiency rating (how well elements were chained)
- Best luck moment (highest rarity gacha pull, biggest treasure find)
- A **seed code** to replay the same procedural map layout

Roguelike meta-progression (optional): each run unlocks new starting base perks, new 仙獸 types, or new tile varieties for future runs.

**CN**: 無論勝敗，每局遊戲都會生成**單局總結**顯示：
- 總存入靈氣/達到的覺醒等級
- 建造的房間、放置的圖塊、召喚的仙獸
- 摧毀的蟲洞 vs. 突破的蟲洞
- 風水效率評級（五行鏈的好壞）
- 最佳幸運時刻（最高稀有度抽獎、最大寶物發現）
- 一個**種子碼**用於重玩相同的程序生成地圖佈局

Roguelike 跨局進化（可選）：每局遊戲解鎖新的起始基地特權、新仙獸類型或新圖塊種類供未來使用。

---

## 13. Wave Structure & Difficulty / 波次結構與難度曲線

### Wave Progression (Aligned with Awakening) / 波次推進（對應覺醒系統）

**EN**: Waves are no longer a flat linear progression. They are tied to the Awakening milestones — each Awakening tier has its own set of waves, and the difficulty resets partially when a new tier begins (new tools offset new threats). The game ends definitively at the Final Boss.

**CN**: 波次不再是平坦的線性推進。它們與覺醒里程碑掛鉤——每個覺醒階段有自己的波次組，新階段開始時難度部分重置（新工具抵消新威脅）。遊戲在最終Boss處明確結束。

| Awakening Tier / 覺醒階段 | Waves / 波次 | Phase Name / 階段名 | Characteristics (EN) | 特徵 (CN) |
|---|---|---|---|---|
| 🌱 初醒 (100 EN) | 1–5 | **Foundation / 奠基** | 1 portal/wave, Soldiers only. Learn building, resource flow, basic combat. | 每波1蟲洞，僅士兵。學習建造、資源流動、基礎戰鬥。 |
| 🌿 二醒 (300 EN) | 6–12 | **Fog Awakens / 迷霧初現** | 2 portals/wave, Archers appear. Fog of war activates. Must learn detection. | 每波2蟲洞，弓手出現。迷霧啟動。必須學會偵測。 |
| 🌳 三醒 (600 EN) | 13–20 | **Alchemy & Chaos / 煉丹與混沌** | 3 portals/wave, Monks (healers) appear. Gacha shop opens — luck enters the equation. | 每波3蟲洞，僧侶出現。抽獎爐開放——運氣進入方程式。 |
| 🌲 四醒 (1000 EN) | 21–28 | **Five Elements War / 五行之戰** | 4 portals/wave, Ninjas + Samurai. Elemental warfare fully online. Teleport critical. | 每波4蟲洞，忍者+武士。元素戰全面啟動。轉送房至關重要。 |
| 🐉 五醒 (1500 EN) | 29–35 | **Dragon Vein Pulses / 龍脈脈動** | 5+ portals/wave, Heroes appear. Narrative events. Legendary tiles. Full system mastery. | 每波5+蟲洞，英雄出現。敘事事件。傳說圖塊。全系統精通。 |
| ☯️ 圓滿 (2000 EN) | **36** | **THE FINAL WAVE / 終局之戰** | 鎮龍將 arrives with all portals open. Survive and destroy the boss. No more waves after. | 鎮龍將帶著所有蟲洞降臨。存活並擊敗Boss。此後再無波次。 |

### Post-Victory: Endless Mode (Optional) / 勝利後：無盡模式（可選）

**EN**: After defeating the 鎮龍將, players unlock **Endless Mode** — the Dragon Vein is restored but the surface world refuses to stop. Waves continue infinitely with escalating modifiers, leaderboard scoring, and increasingly absurd portal combinations. This is for players who want to push their dungeon to its absolute limit.

**CN**: 擊敗鎮龍將後，玩家解鎖**無盡模式**——龍脈已復甦但地表世界拒絕停手。波次無限持續，帶有不斷升級的修正值、排行榜計分和越來越誇張的蟲洞組合。這是給想把仙窟推到極限的玩家。

### Enemy Types / 敵人類型

| Enemy / 敵人 | Element / 屬性 | Behavior (EN) | 行為 (CN) |
|---|---|---|---|
| 士兵 Soldier | None / 無 | Basic melee, walks corridors | 基礎近戰，沿走廊行走 |
| 弓手 Archer | Wood / 木 | Ranged attack, stays back | 遠程攻擊，保持距離 |
| 僧侶 Monk | Water / 水 | Heals other enemies | 治療其他敵人 |
| 忍者 Ninja | Metal / 金 | Fast, can bypass some rooms | 快速，可繞過某些房間 |
| 武士 Samurai | Fire / 火 | High HP, destroys rooms | 高血量，會破壞房間 |
| 英雄 Hero | Earth / 土 | Boss unit, targets Dragon Furnace | Boss單位，目標是龍穴炉 |

---

## 14. Key Differentiators / 核心差異化

### vs. Standard TD / 對比標準塔防

| Aspect / 面向 | Standard TD / 標準塔防 | Our Game / 本遊戲 |
|---|---|---|
| **Visibility / 視野** | Global — see everything | Fog of War — information is earned |
| **全局——看到一切** | | **戰爭迷霧——情報靠爭取** |
| **Enemy Pathing / 敵人路徑** | Fixed lanes or maze | Portals spawn randomly in fog |
| **固定路線或迷宮** | | **蟲洞在迷霧中隨機生成** |
| **Player Role / 玩家角色** | Omniscient architect | Explorer inside the dungeon |
| **全知建築師** | | **仙窟內部的探索者** |
| **Tower Upgrades / 塔升級** | Click to level up | Physical adjacency tiles (Feng Shui + Tile Tactics) |
| **點擊升級** | | **物理相鄰圖塊（風水 + Tile Tactics）** |
| **Luck / 運氣** | Minimal | Multi-layered (Gacha, portals, treasures, events) |
| **極少** | | **多層次（抽獎、蟲洞、寶物、事件）** |
| **Automation / 自動化** | Towers fire automatically | 仙獸 patrols with designed routes (logistics + combat + scout) |
| **塔自動開火** | | **仙獸巡邏搭配設計的路線（物流+戰鬥+偵察）** |

### vs. Tile Tactics / 對比 Tile Tactics

| Aspect / 面向 | Tile Tactics | Our Game / 本遊戲 |
|---|---|---|
| **Theme** | Generic pixel art | Daoist mythology, Feng Shui |
| **Adjacency System** | Simple buff tiles | Five Elements generation/restraint cycles |
| **Visibility** | Global | Fog of War + portal hunt |
| **Shop** | Slot machine | Alchemy Furnace (thematic) |
| **Automation** | None (manual only) | 仙獸 patrol system |

### vs. Chaos Seed / 對比仙窟活龍大戰

| Aspect / 面向 | Chaos Seed / 仙窟活龍大戰 | Our Game / 本遊戲 |
|---|---|---|
| **Genre** | Action RPG + Sim | Tower Defense + Roguelike |
| **Combat** | Real-time action (skill-based) | Automated (Attack Rooms + 仙獸) + strategic |
| **Runs** | Story-driven stages | Roguelike procedural runs |
| **Luck** | Minimal | Core design pillar |
| **Shop** | None | Alchemy Gacha with rerolls |

---

## 15. Development Phases / 開發階段路線圖

> **Principle: Each phase must be playable and testable on its own.**
> **原則：每個階段都必須獨立可玩、可測試。**

```
Phase 1          Phase 2          Phase 3          Phase 4
骨架 Skeleton    迷霧 Fog         五行 Elements    命運 Fate
─────────── ──▶ ─────────── ──▶ ─────────── ──▶ ───────────
Grid + Rooms     + Fog of War     + Five Elements   + Gacha, Luck
+ Enemies        + Portals        + Adjacency       + 仙獸 system
+ 1 resource     + Detection      + Ki flow         + Awakenings
                                                    + Final Boss
```

---

### Phase 1: 骨架 Skeleton — "Is the core TD loop fun?"

> **Goal / 目標**: Prove the basic grid-building TD is satisfying.
> **Validate / 驗證**: Does placing rooms on a grid and watching enemies get destroyed feel good?

#### What's IN / 包含：
- Tile grid map (fixed size, e.g. 9×9)
- 3 room types only: **Production Room** (generates EN), **Attack Room** (shoots enemies), **Dragon Furnace** (deposit EN to win)
- Corridors connecting rooms (player draws paths)
- 1 resource: **Energy (EN)** — produced, spent to build, deposited to win
- Simple enemies: **Soldiers** walk from map edge toward Furnace
- Fixed enemy spawn points (no fog yet — enemies come from visible edges)
- Win: deposit X Energy into Furnace
- Lose: Furnace HP reaches 0
- Basic Build → Defend → Build cycle (turn-based)

#### What's OUT / 不含：
- No fog of war
- No five elements / Feng Shui
- No Sentan / second resource
- No gacha shop
- No 仙獸
- No portals (enemies use fixed spawn points)
- No detection / teleport / excavation rooms

#### Key Questions to Answer / 需要回答的問題：
- EN: Is the build-place-defend loop satisfying on a grid?
- EN: Does the corridor/pathing feel intuitive?
- EN: Is the pacing between build and defend phases right?
- CN: 在格子上建造-放置-防禦的循環是否令人滿足？
- CN: 走廊/路徑的感覺是否直覺？
- CN: 建造和防禦階段之間的節奏是否恰當？

---

### Phase 2: 迷霧 Fog — "Does limited visibility change everything?"

> **Goal / 目標**: Introduce the core differentiator — fog of war + portal hunting.
> **Validate / 驗證**: Does hiding information transform the TD experience from "optimize" to "react and explore"?

#### What's ADDED / 新增：
- **Fog of war**: only built rooms + corridors are visible
- **Portals (蟲洞)**: replace fixed spawn points. Spawn randomly in fog each wave. Continuously pump enemies until destroyed.
- **Detection Room (探知房)**: reveals fog in a radius, pings portal locations
- **Teleport Room (轉送房)**: fast travel between two linked rooms
- Portal count scales with number of built rooms (growth dilemma)
- Basic directional hints ("rumbling from the east") when portals spawn

#### What's STILL OUT / 仍不含：
- No five elements (rooms have no elemental attribute yet)
- No Sentan / gacha
- No 仙獸 (player must personally reach portals)
- No upgrade tiles

#### Key Questions to Answer / 需要回答的問題：
- EN: Does fog of war make the game feel fundamentally different from standard TD?
- EN: Is the portal hunt exciting or frustrating?
- EN: Is the Detection Room valuable enough that players want to build it?
- EN: Does the "bigger dungeon = more portals" dilemma create interesting choices?
- CN: 戰爭迷霧是否讓遊戲感覺與標準TD根本不同？
- CN: 蟲洞獵殺是刺激的還是令人沮喪的？
- CN: 探知房是否有足夠價值讓玩家想建造？
- CN: 「更大仙窟=更多蟲洞」的困境是否產生有趣的選擇？

#### Design Note / 設計筆記：
**EN**: This phase will tell us if our core hook works. If fog + portals feels good, the game has legs. If it feels annoying, we need to tune detection radius, portal count, or hint quality before moving forward.
**CN**: 這個階段會告訴我們核心賣點是否成立。如果迷霧+蟲洞感覺很好，遊戲就有前途。如果感覺煩人，我們需要先調整偵測半徑、蟲洞數量或提示品質，再往下走。

---

### Phase 3: 五行 Elements — "Does spatial puzzle add depth?"

> **Goal / 目標**: Layer the Feng Shui five-element system onto the existing grid.
> **Validate / 驗證**: Does the elemental adjacency system make room placement a deeper, more rewarding puzzle?

#### What's ADDED / 新增：
- **Five Elements (五行)**: each grid tile has an inherent element based on position
- **Ki flow through corridors**: adjacent rooms affect each other (generation bonus / restraint penalty)
- **Element-typed enemies**: Archers (Wood), Monks (Water), Ninjas (Metal), Samurai (Fire), Heroes (Earth)
- **Elemental damage**: Attack Rooms deal bonus damage to enemies weak to their element
- **Sentan (仙丹)** as second resource: produced by new **Refinery Room (錬丹房)**
- **Room upgrades**: spend Sentan to level up rooms during Manage phase
- **Upgrade Tiles**: physical adjacency-based buffs (Tile Tactics influence) — acquired via Sentan, not gacha yet
- Visual indicator for elemental flow between rooms

#### What's STILL OUT / 仍不含：
- No gacha shop (upgrade tiles are bought, not random)
- No 仙獸 (still no automation)
- No luck/random events
- No awakening milestones (fixed map size)

#### Key Questions to Answer / 需要回答的問題：
- EN: Does the five-element system add satisfying depth or just confusion?
- EN: Do players naturally discover generation/restraint through play, or does it need heavy tutorialization?
- EN: Is the Sentan economy balanced against Energy?
- EN: Do Upgrade Tiles feel good as physical objects on the grid?
- CN: 五行系統是增加了令人滿足的深度，還是只是混亂？
- CN: 玩家是否能自然地在遊玩中發現相生/相剋，還是需要大量教學？
- CN: 仙丹經濟與靈氣之間是否平衡？
- CN: 升級圖塊作為棋盤上的物理物件，感覺是否良好？

---

### Phase 4: 命運 Fate — "Does luck make it magical?"

> **Goal / 目標**: Add all remaining systems — luck, automation, progression, and the endgame.
> **Validate / 驗證**: Does the full game loop with randomness and 仙獸 create the "one more run" feeling?

#### What's ADDED / 新增：
- **Alchemy Gacha Shop (煉丹抽獎爐)**: random tile drafting with rerolls, rarity tiers, bad luck protection
- **仙獸 System**: Summoning Room, 5 beast types, patrol routes (logistics + combat + scouting), mutation system
- **Dragon Vein Awakening (龍脈覺醒)**: 6-tier milestone progression, map expansion, mechanic unlocking, threat escalation
- **Hidden Treasures**: fog tiles with discoverable caches, traps, ancient beast eggs
- **Narrative Events**: Merchant caravans, Feng Shui storms, Wandering Sage, Yin-Yang Reversal, Spirit Bloom
- **Dragon Vein Resonance**: full 5-element chain jackpot bonus
- **Final Boss: 鎮龍將**: 3-phase boss fight (Siege → March → Core)
- **Warehouse (倉庫房)** and **Excavation Room (掘削房)**
- **Post-run summary** and seed codes
- **Endless Mode** (post-victory)
- Roguelike meta-progression (optional)

#### Key Questions to Answer / 需要回答的問題：
- EN: Does the gacha feel exciting without feeling pay-to-win?
- EN: Do 仙獸 patrols reduce tedium or add too much complexity?
- EN: Does the Awakening system pace the game well?
- EN: Is the Final Boss a satisfying climax that tests all systems?
- EN: Do players want to do "one more run"?
- CN: 抽獎爐是否令人興奮而不讓人覺得是付費贏？
- CN: 仙獸巡邏是減少了枯燥，還是增加了太多複雜性？
- CN: 覺醒系統是否良好地控制了遊戲節奏？
- CN: 最終Boss是否是一個令人滿足的、考驗所有系統的高潮？
- CN: 玩家是否想「再來一局」？

---

### Phase Summary / 階段摘要

```
        Phase 1          Phase 2          Phase 3          Phase 4
        骨架              迷霧              五行              命運
       ┌──────┐         ┌──────┐         ┌──────┐         ┌──────┐
Rooms  │ 3    │ ──────▶ │ 5    │ ──────▶ │ 6    │ ──────▶ │ 9    │
       └──────┘         └──────┘         └──────┘         └──────┘
       Prod,Atk,        +Detect,         +Refinery        +Summon,
       Furnace          Teleport                          Warehouse,
                                                          Excavation

       ┌──────┐         ┌──────┐         ┌──────┐         ┌──────┐
Enemies│ 1    │ ──────▶ │ 1    │ ──────▶ │ 6    │ ──────▶ │ 6+Boss│
       └──────┘         └──────┘         └──────┘         └──────┘
       Soldier          Soldier          +5 elemental     +鎮龍將
                        (from portals)   types

       ┌──────┐         ┌──────┐         ┌──────┐         ┌──────┐
Systems│ Grid  │ ──────▶ │ +Fog  │ ──────▶ │ +5行  │ ──────▶ │ +Gacha│
       │ Build │         │ +Portal│        │ +Ki   │         │ +仙獸 │
       │ Defend│         │ +Detect│        │ +SN   │         │ +Awake│
       └──────┘         └──────┘         │ +Upgr │         │ +Boss │
                                         └──────┘         └──────┘
```

### What to Build First / 最優先建造

**EN**: Start with Phase 1. It is the smallest possible game that still feels like "our game." If the grid-based room placement + corridor design + enemy wave loop is satisfying at this minimal level, every subsequent phase only makes it better. If Phase 1 feels flat, we fix the foundation before adding features.

**CN**: 從Phase 1開始。這是最小的可能遊戲，但仍然感覺像「我們的遊戲」。如果在這個最小程度下，基於格子的房間放置 + 走廊設計 + 敵人波次循環是令人滿足的，那每個後續階段只會讓它更好。如果Phase 1感覺平淡，我們先修好基礎再加功能。

---

*End of Veincraft GDD v0.3 — Phased development roadmap added.*
*Veincraft GDD v0.3 結束——已新增階段性開發路線圖。*
