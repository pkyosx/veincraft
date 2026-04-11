extends RefCounted
class_name GameData

const GRID_W: int = 18
const GRID_H: int = 12
const CELL_SIZE: int = 60
const GRID_OFFSET: Vector2 = Vector2(20, 30)

# Cell types
enum Cell { EMPTY, ROCK, TREE, PATH, TOWER, UPGRADE }

# Tower types
enum TowerType { TURRET, TREBUCHET, FROST, TESLA, RACER, POLICE, FIRETRUCK, MONSTERTRUCK }

# Tile item types (what goes in the bag)
enum ItemType { TURRET, TREBUCHET, FROST, TESLA, UPGRADE_DMG, UPGRADE_SPEED, UPGRADE_RANGE, BOMB, RACER, MEGA_BOMB, UPGRADE_MEGA_DMG, POLICE, FIRETRUCK, MONSTERTRUCK }

const TOWER_CONFIGS: Dictionary = {
	TowerType.TURRET: {
		"name": "Turret",
		"damage": 3,
		"range": 2.0,
		"cooldown": 0.8,
		"color": Color(0.8, 0.2, 0.2),
		"icon": "+",
		"cost": 8,
		"item": ItemType.TURRET,
	},
	TowerType.TREBUCHET: {
		"name": "Trebuchet",
		"damage": 10,
		"range": 3.5,
		"cooldown": 2.0,
		"color": Color(0.7, 0.4, 0.1),
		"icon": "T",
		"cost": 18,
		"item": ItemType.TREBUCHET,
	},
	TowerType.FROST: {
		"name": "Frost",
		"damage": 1,
		"range": 2.0,
		"cooldown": 0.5,
		"color": Color(0.3, 0.7, 0.95),
		"icon": "*",
		"cost": 12,
		"item": ItemType.FROST,
		"slow": 0.4,  # slows enemies by 40%
	},
	TowerType.TESLA: {
		"name": "Tesla",
		"damage": 5,
		"range": 1.8,
		"cooldown": 1.2,
		"color": Color(0.6, 0.3, 0.9),
		"icon": "Z",
		"cost": 20,
		"item": ItemType.TESLA,
		"chain": 3,  # hits up to 3 enemies
	},
	TowerType.RACER: {
		"name": "Racer",
		"damage": 20,
		"range": 4.0,
		"cooldown": 3.0,
		"color": Color(0.9, 0.1, 0.1),
		"icon": "R",
		"cost": 50,
		"item": ItemType.RACER,
		"pierce": 5,
	},
	TowerType.POLICE: {
		"name": "Police",
		"damage": 12,
		"range": 3.0,
		"cooldown": 2.0,
		"color": Color(0.15, 0.25, 0.5),
		"icon": "P",
		"cost": 35,
		"item": ItemType.POLICE,
		"slow": 0.5,
		"pierce": 3,
	},
	TowerType.FIRETRUCK: {
		"name": "FireTruck",
		"damage": 8,
		"range": 2.5,
		"cooldown": 1.5,
		"color": Color(0.8, 0.15, 0.15),
		"icon": "F",
		"cost": 40,
		"item": ItemType.FIRETRUCK,
		"burn": 4,  # 4 damage per second for 3 seconds
		"pierce": 3,
	},
	TowerType.MONSTERTRUCK: {
		"name": "Monster",
		"damage": 35,
		"range": 3.5,
		"cooldown": 4.0,
		"color": Color(0.2, 0.2, 0.25),
		"icon": "M",
		"cost": 60,
		"item": ItemType.MONSTERTRUCK,
		"pierce": 8,
		"knockback": 2,  # push enemies back 2 cells
	},
}

const ITEM_CONFIGS: Dictionary = {
	ItemType.TURRET: {"name": "Turret", "color": Color(0.8, 0.2, 0.2), "type": "tower", "tower": TowerType.TURRET, "cost": 8},
	ItemType.TREBUCHET: {"name": "Trebuchet", "color": Color(0.7, 0.4, 0.1), "type": "tower", "tower": TowerType.TREBUCHET, "cost": 18},
	ItemType.FROST: {"name": "Frost", "color": Color(0.3, 0.7, 0.95), "type": "tower", "tower": TowerType.FROST, "cost": 12},
	ItemType.TESLA: {"name": "Tesla", "color": Color(0.6, 0.3, 0.9), "type": "tower", "tower": TowerType.TESLA, "cost": 20},
	ItemType.UPGRADE_DMG: {"name": "+DMG", "color": Color(1.0, 0.5, 0.1), "type": "upgrade", "stat": "damage", "value": 2, "cost": 8},
	ItemType.UPGRADE_SPEED: {"name": "+SPD", "color": Color(0.2, 0.7, 1.0), "type": "upgrade", "stat": "cooldown", "value": -0.15, "cost": 8},
	ItemType.UPGRADE_RANGE: {"name": "+RNG", "color": Color(0.3, 0.9, 0.3), "type": "upgrade", "stat": "range", "value": 0.8, "cost": 8},
	ItemType.BOMB: {"name": "Bomb", "color": Color(1.0, 0.8, 0.0), "type": "bomb", "cost": 3},
	ItemType.RACER: {"name": "Racer", "color": Color(0.9, 0.1, 0.1), "type": "tower", "tower": TowerType.RACER, "cost": 50},
	ItemType.MEGA_BOMB: {"name": "MegaBomb", "color": Color(1.0, 0.4, 0.0), "type": "mega_bomb", "cost": 20},
	ItemType.UPGRADE_MEGA_DMG: {"name": "++DMG", "color": Color(1.0, 0.3, 0.0), "type": "upgrade", "stat": "damage", "value": 8, "cost": 30},
	ItemType.POLICE: {"name": "Police", "color": Color(0.15, 0.25, 0.5), "type": "tower", "tower": TowerType.POLICE, "cost": 35},
	ItemType.FIRETRUCK: {"name": "FireTruck", "color": Color(0.8, 0.15, 0.15), "type": "tower", "tower": TowerType.FIRETRUCK, "cost": 40},
	ItemType.MONSTERTRUCK: {"name": "Monster", "color": Color(0.2, 0.2, 0.25), "type": "tower", "tower": TowerType.MONSTERTRUCK, "cost": 60},
}

# Shop slot machine weights
const SHOP_POOL: Array = [
	{"item": ItemType.TURRET, "weight": 20},
	{"item": ItemType.TREBUCHET, "weight": 10},
	{"item": ItemType.FROST, "weight": 12},
	{"item": ItemType.TESLA, "weight": 8},
	{"item": ItemType.UPGRADE_DMG, "weight": 18},
	{"item": ItemType.UPGRADE_SPEED, "weight": 12},
	{"item": ItemType.UPGRADE_RANGE, "weight": 12},
	{"item": ItemType.BOMB, "weight": 8},
]

# Premium shop pool ($50 spin)
const PREMIUM_POOL: Array = [
	{"item": ItemType.RACER, "weight": 15},
	{"item": ItemType.POLICE, "weight": 15},
	{"item": ItemType.FIRETRUCK, "weight": 15},
	{"item": ItemType.MONSTERTRUCK, "weight": 12},
	{"item": ItemType.TESLA, "weight": 10},
	{"item": ItemType.MEGA_BOMB, "weight": 12},
	{"item": ItemType.UPGRADE_MEGA_DMG, "weight": 12},
	{"item": ItemType.UPGRADE_RANGE, "weight": 9},
]

const SPIN_COST: int = 10
const PREMIUM_SPIN_COST: int = 50
const MAX_BAG: int = 8
const MAX_HP: int = 3
const STARTING_GOLD: int = 30
const KILL_GOLD: int = 3

# Winding path through the 18x12 grid
const ENEMY_PATH: Array[Vector2i] = [
	# Enter from top-left, go right
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
	Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1),
	# Turn down
	Vector2i(8, 2), Vector2i(8, 3),
	# Go left
	Vector2i(7, 3), Vector2i(6, 3), Vector2i(5, 3), Vector2i(4, 3),
	Vector2i(3, 3), Vector2i(2, 3), Vector2i(1, 3),
	# Turn down
	Vector2i(1, 4), Vector2i(1, 5),
	# Go right across
	Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5),
	Vector2i(6, 5), Vector2i(7, 5), Vector2i(8, 5), Vector2i(9, 5),
	Vector2i(10, 5), Vector2i(11, 5), Vector2i(12, 5),
	# Turn down
	Vector2i(12, 6), Vector2i(12, 7),
	# Go left
	Vector2i(11, 7), Vector2i(10, 7), Vector2i(9, 7), Vector2i(8, 7),
	Vector2i(7, 7), Vector2i(6, 7), Vector2i(5, 7), Vector2i(4, 7),
	# Turn down
	Vector2i(4, 8), Vector2i(4, 9),
	# Go right to exit
	Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9), Vector2i(8, 9),
	Vector2i(9, 9), Vector2i(10, 9), Vector2i(11, 9), Vector2i(12, 9),
	Vector2i(13, 9), Vector2i(14, 9), Vector2i(15, 9), Vector2i(16, 9), Vector2i(17, 9),
]

# Enemy types
enum EnemyType { SLIME, SKELETON, GOBLIN, WOLF, MUSHROOM, BAT, ORC, WRAITH, DRAGON, GOLEM, NOOB_BOSS }

const ENEMY_CONFIGS: Dictionary = {
	EnemyType.SLIME: {
		"name": "Slime", "hp_mult": 0.8, "speed_mult": 0.9,
		"color": Color(0.4, 0.7, 0.3), "color_light": Color(0.5, 0.8, 0.4),
		"radius": 10.0, "gold": 2, "sprite": "monster_slime_sheet.png", "frames": 6,
	},
	EnemyType.SKELETON: {
		"name": "Skeleton", "hp_mult": 0.6, "speed_mult": 1.6,
		"color": Color(0.8, 0.8, 0.7), "color_light": Color(0.9, 0.9, 0.8),
		"radius": 10.0, "gold": 3, "sprite": "monster_skeleton.png",
	},
	EnemyType.GOBLIN: {
		"name": "Goblin", "hp_mult": 1.0, "speed_mult": 1.2,
		"color": Color(0.4, 0.55, 0.25), "color_light": Color(0.5, 0.65, 0.35),
		"radius": 10.0, "gold": 3, "sprite": "monster_goblin.png",
	},
	EnemyType.WOLF: {
		"name": "Wolf", "hp_mult": 0.7, "speed_mult": 2.0,
		"color": Color(0.5, 0.5, 0.55), "color_light": Color(0.65, 0.65, 0.7),
		"radius": 10.0, "gold": 3, "sprite": "monster_wolf.png",
	},
	EnemyType.MUSHROOM: {
		"name": "Mushroom", "hp_mult": 2.0, "speed_mult": 0.6,
		"color": Color(0.5, 0.3, 0.6), "color_light": Color(0.6, 0.4, 0.7),
		"radius": 12.0, "gold": 5, "sprite": "monster_mushroom_sheet.png", "frames": 6,
	},
	EnemyType.BAT: {
		"name": "Bat", "hp_mult": 0.5, "speed_mult": 1.8,
		"color": Color(0.3, 0.2, 0.4), "color_light": Color(0.4, 0.3, 0.5),
		"radius": 10.0, "gold": 3, "sprite": "monster_bat.png",
	},
	EnemyType.ORC: {
		"name": "Orc", "hp_mult": 2.5, "speed_mult": 0.7,
		"color": Color(0.3, 0.5, 0.3), "color_light": Color(0.4, 0.6, 0.4),
		"radius": 14.0, "gold": 6, "sprite": "monster_orc.png",
	},
	EnemyType.WRAITH: {
		"name": "Wraith", "hp_mult": 0.8, "speed_mult": 1.7,
		"color": Color(0.3, 0.3, 0.4), "color_light": Color(0.4, 0.4, 0.5),
		"radius": 10.0, "gold": 4, "sprite": "monster_wraith.png",
	},
	EnemyType.DRAGON: {
		"name": "Dragon", "hp_mult": 3.0, "speed_mult": 0.8,
		"color": Color(0.7, 0.3, 0.2), "color_light": Color(0.8, 0.4, 0.3),
		"radius": 14.0, "gold": 8, "sprite": "monster_dragon.png",
	},
	EnemyType.GOLEM: {
		"name": "Golem", "hp_mult": 3.5, "speed_mult": 0.5,
		"color": Color(0.4, 0.4, 0.45), "color_light": Color(0.5, 0.5, 0.55),
		"radius": 14.0, "gold": 8, "sprite": "monster_golem.png",
	},
	EnemyType.NOOB_BOSS: {
		"name": "Noob Boss", "hp_mult": 200.0, "speed_mult": 0.25,
		"color": Color(0.96, 0.8, 0.19), "color_light": Color(1.0, 0.9, 0.3),
		"radius": 30.0, "gold": 500, "sprite": "monster_noob_boss_4dir.png", "frames": 8, "vframes": 4,
		"boss": true,
	},
}

static func get_enemies_per_wave(wave: int) -> int:
	return 5 + wave * 2

static func get_base_hp(wave: int) -> int:
	return 12 + wave * 5

static func get_base_speed(wave: int) -> float:
	return 42.0 + wave * 2.0

static func get_wave_composition(wave: int) -> Array:
	var comp: Array = []
	var total: int = get_enemies_per_wave(wave)
	# Each wave introduces a new monster type
	var wave_pool: Array = []
	match wave:
		1: wave_pool = [EnemyType.SLIME]
		2: wave_pool = [EnemyType.SLIME]
		3: wave_pool = [EnemyType.SLIME, EnemyType.SKELETON]
		4: wave_pool = [EnemyType.SLIME, EnemyType.SKELETON, EnemyType.GOBLIN]
		5: wave_pool = [EnemyType.GOBLIN, EnemyType.WOLF, EnemyType.SKELETON]
		6: wave_pool = [EnemyType.WOLF, EnemyType.MUSHROOM, EnemyType.GOBLIN]
		7: wave_pool = [EnemyType.BAT, EnemyType.MUSHROOM, EnemyType.WOLF]
		8: wave_pool = [EnemyType.ORC, EnemyType.BAT, EnemyType.GOBLIN]
		9: wave_pool = [EnemyType.WRAITH, EnemyType.ORC, EnemyType.BAT]
		10: wave_pool = [EnemyType.DRAGON, EnemyType.GOLEM, EnemyType.WRAITH]
		20: wave_pool = [EnemyType.DRAGON, EnemyType.GOLEM, EnemyType.WRAITH]
		_: wave_pool = [EnemyType.DRAGON, EnemyType.GOLEM, EnemyType.WRAITH, EnemyType.ORC]

	# Wave 20: Boss wave! Add Noob Boss at the end
	if wave == 20:
		for i in range(total):
			comp.append(wave_pool[i % wave_pool.size()])
		comp.append(EnemyType.NOOB_BOSS)
		return comp

	for i in range(total):
		comp.append(wave_pool[i % wave_pool.size()])
	return comp

static func roll_shop_item(premium: bool = false) -> int:
	var pool: Array = PREMIUM_POOL if premium else SHOP_POOL
	var total_weight: int = 0
	for entry in pool:
		total_weight += entry["weight"]
	var roll: int = randi() % total_weight
	var cumulative: int = 0
	for entry in pool:
		cumulative += entry["weight"]
		if roll < cumulative:
			return entry["item"]
	return ItemType.TURRET
