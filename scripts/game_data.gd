extends RefCounted
class_name GameData

const GRID_W: int = 12
const GRID_H: int = 8
const CELL_SIZE: int = 72
const GRID_OFFSET: Vector2 = Vector2(40, 80)

# Cell types
enum Cell { EMPTY, ROCK, TREE, PATH, TOWER, UPGRADE }

# Tower types
enum TowerType { TURRET, TREBUCHET }

# Tile item types (what goes in the bag)
enum ItemType { TURRET, TREBUCHET, UPGRADE_DMG, UPGRADE_SPEED, UPGRADE_RANGE, BOMB }

const TOWER_CONFIGS: Dictionary = {
	TowerType.TURRET: {
		"name": "Turret",
		"damage": 3,
		"range": 2.0,
		"cooldown": 0.8,
		"color": Color(0.8, 0.2, 0.2),
		"icon": "+",
		"cost": 5,
		"item": ItemType.TURRET,
	},
	TowerType.TREBUCHET: {
		"name": "Trebuchet",
		"damage": 8,
		"range": 3.5,
		"cooldown": 2.0,
		"color": Color(0.7, 0.4, 0.1),
		"icon": "T",
		"cost": 15,
		"item": ItemType.TREBUCHET,
	},
}

const ITEM_CONFIGS: Dictionary = {
	ItemType.TURRET: {"name": "Turret", "color": Color(0.8, 0.2, 0.2), "type": "tower", "tower": TowerType.TURRET, "cost": 5},
	ItemType.TREBUCHET: {"name": "Trebuchet", "color": Color(0.7, 0.4, 0.1), "type": "tower", "tower": TowerType.TREBUCHET, "cost": 15},
	ItemType.UPGRADE_DMG: {"name": "+DMG", "color": Color(1.0, 0.5, 0.1), "type": "upgrade", "stat": "damage", "value": 2, "cost": 8},
	ItemType.UPGRADE_SPEED: {"name": "+SPD", "color": Color(0.2, 0.7, 1.0), "type": "upgrade", "stat": "cooldown", "value": -0.15, "cost": 8},
	ItemType.UPGRADE_RANGE: {"name": "+RNG", "color": Color(0.3, 0.9, 0.3), "type": "upgrade", "stat": "range", "value": 0.8, "cost": 8},
	ItemType.BOMB: {"name": "Bomb", "color": Color(1.0, 0.8, 0.0), "type": "bomb", "cost": 3},
}

# Shop slot machine weights
const SHOP_POOL: Array = [
	{"item": ItemType.TURRET, "weight": 30},
	{"item": ItemType.TREBUCHET, "weight": 15},
	{"item": ItemType.UPGRADE_DMG, "weight": 20},
	{"item": ItemType.UPGRADE_SPEED, "weight": 15},
	{"item": ItemType.UPGRADE_RANGE, "weight": 15},
	{"item": ItemType.BOMB, "weight": 5},
]

const SPIN_COST: int = 10
const MAX_BAG: int = 4
const MAX_HP: int = 3
const STARTING_GOLD: int = 30
const KILL_GOLD: int = 3

# S-shaped path through the grid (grid coords)
const ENEMY_PATH: Array[Vector2i] = [
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1),
	Vector2i(5, 2), Vector2i(5, 3),
	Vector2i(4, 3), Vector2i(3, 3), Vector2i(2, 3), Vector2i(1, 3),
	Vector2i(1, 4), Vector2i(1, 5),
	Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5),
	Vector2i(6, 6),
	Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 6), Vector2i(10, 6), Vector2i(11, 6),
]

static func get_enemies_per_wave(wave: int) -> int:
	return 4 + wave * 2

static func get_enemy_hp(wave: int) -> int:
	return 6 + wave * 3

static func get_enemy_speed(wave: int) -> float:
	return 55.0 + wave * 3.0

static func roll_shop_item() -> int:
	var total_weight: int = 0
	for entry in SHOP_POOL:
		total_weight += entry["weight"]
	var roll: int = randi() % total_weight
	var cumulative: int = 0
	for entry in SHOP_POOL:
		cumulative += entry["weight"]
		if roll < cumulative:
			return entry["item"]
	return ItemType.TURRET
