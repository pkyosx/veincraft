extends Node2D

# State
var grid: Array = []  # 2D [y][x] of Cell type
var towers: Dictionary = {}  # Vector2i -> {type, damage, range, cooldown, timer}
var upgrades: Dictionary = {}  # Vector2i -> item_type
var bag: Array = []  # Array of ItemType, max 4
var gold: int = GameData.STARTING_GOLD
var hp: int = GameData.MAX_HP
var wave: int = 0
var max_waves: int = 20

var enemies: Array = []
var projectiles: Array = []
var spawn_queue: int = 0
var spawn_timer: float = 0.0
var phase: String = "build"  # "build" or "fight"
var game_over: bool = false

var selected_bag_index: int = -1
var hovered_cell: Vector2i = Vector2i(-1, -1)

# Hidden treasures under obstacles
var hidden_treasures: Dictionary = {}  # Vector2i -> item_type or "gold"
var treasure_notification: String = ""
var treasure_notify_timer: float = 0.0

# Path cells set for quick lookup
var path_set: Dictionary = {}

# Screen shake
var shake_timer: float = 0.0
var shake_intensity: float = 0.0

# Tower sprite sheet (4 towers, each 64x64)
var tower_texture: Texture2D = null

# Terrain textures
var tree_texture: Texture2D = null
var rock_textures: Array[Texture2D] = []
var grass_texture: Texture2D = null
var tree_anim_timer: float = 0.0
var tree_anim_frame: int = 0
@onready var camera: Camera2D = $Camera
@onready var enemy_container: Node2D = $EnemyContainer
@onready var projectile_container: Node2D = $ProjectileContainer

func _ready() -> void:
	tower_texture = load("res://sprites/tower_sheet.png")
	tree_texture = load("res://sprites/tree.png")
	rock_textures.append(load("res://sprites/rock1.png"))
	rock_textures.append(load("res://sprites/rock2.png"))
	grass_texture = load("res://sprites/tilemap_grass.png")
	_init_grid()
	_update_hud()

func _init_grid() -> void:
	grid.clear()
	towers.clear()
	upgrades.clear()
	path_set.clear()
	for y in range(GameData.GRID_H):
		var row: Array = []
		for x in range(GameData.GRID_W):
			row.append(GameData.Cell.EMPTY)
		grid.append(row)

	# Mark path
	for p in GameData.ENEMY_PATH:
		grid[p.y][p.x] = GameData.Cell.PATH
		path_set[p] = true

	# Place some rocks and trees
	var obstacles: Array[Vector2i] = [
		Vector2i(3, 0), Vector2i(7, 0), Vector2i(10, 1),
		Vector2i(0, 3), Vector2i(8, 2), Vector2i(9, 3),
		Vector2i(3, 7), Vector2i(7, 4), Vector2i(10, 4),
		Vector2i(0, 6), Vector2i(4, 7), Vector2i(8, 0),
	]
	for obs in obstacles:
		if grid[obs.y][obs.x] == GameData.Cell.EMPTY:
			grid[obs.y][obs.x] = GameData.Cell.ROCK if randf() > 0.4 else GameData.Cell.TREE
			# ~40% chance to hide a treasure
			if randf() < 0.4:
				var treasure_roll: float = randf()
				if treasure_roll < 0.3:
					hidden_treasures[obs] = "gold"  # bonus gold
				elif treasure_roll < 0.55:
					hidden_treasures[obs] = GameData.ItemType.TURRET
				elif treasure_roll < 0.75:
					hidden_treasures[obs] = GameData.ItemType.UPGRADE_DMG
				elif treasure_roll < 0.9:
					hidden_treasures[obs] = GameData.ItemType.UPGRADE_SPEED
				else:
					hidden_treasures[obs] = GameData.ItemType.TREBUCHET

func cell_to_world(pos: Vector2i) -> Vector2:
	return GameData.GRID_OFFSET + Vector2(pos.x * GameData.CELL_SIZE + GameData.CELL_SIZE / 2, pos.y * GameData.CELL_SIZE + GameData.CELL_SIZE / 2)

func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local: Vector2 = world_pos - GameData.GRID_OFFSET
	return Vector2i(int(local.x / GameData.CELL_SIZE), int(local.y / GameData.CELL_SIZE))

func is_valid_cell(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GameData.GRID_W and pos.y >= 0 and pos.y < GameData.GRID_H

func can_place_tower(pos: Vector2i) -> bool:
	if not is_valid_cell(pos):
		return false
	return grid[pos.y][pos.x] == GameData.Cell.EMPTY

func can_place_upgrade(pos: Vector2i) -> bool:
	if not is_valid_cell(pos):
		return false
	if grid[pos.y][pos.x] != GameData.Cell.EMPTY:
		return false
	# Must be adjacent to a tower
	var neighbors: Array[Vector2i] = [pos + Vector2i(0,-1), pos + Vector2i(0,1), pos + Vector2i(-1,0), pos + Vector2i(1,0)]
	for n in neighbors:
		if n in towers:
			return true
	return false

func place_item(pos: Vector2i, item_type: int) -> bool:
	var config: Dictionary = GameData.ITEM_CONFIGS[item_type]
	if config["type"] == "tower":
		if not can_place_tower(pos):
			return false
		var tower_type: int = config["tower"]
		var tc: Dictionary = GameData.TOWER_CONFIGS[tower_type]
		grid[pos.y][pos.x] = GameData.Cell.TOWER
		towers[pos] = {"type": tower_type, "damage": tc["damage"], "range": tc["range"], "cooldown": tc["cooldown"], "timer": 0.0}
		_recalc_tower_upgrades(pos)
		get_node("/root/Audio").play_sfx("place")
		return true
	elif config["type"] == "upgrade":
		if not can_place_upgrade(pos):
			return false
		grid[pos.y][pos.x] = GameData.Cell.UPGRADE
		upgrades[pos] = item_type
		get_node("/root/Audio").play_sfx("place")
		# Recalc adjacent towers
		var neighbors: Array[Vector2i] = [pos + Vector2i(0,-1), pos + Vector2i(0,1), pos + Vector2i(-1,0), pos + Vector2i(1,0)]
		for n in neighbors:
			if n in towers:
				_recalc_tower_upgrades(n)
		return true
	elif config["type"] == "bomb":
		if not is_valid_cell(pos):
			return false
		var cell_type: int = grid[pos.y][pos.x]
		if cell_type == GameData.Cell.ROCK or cell_type == GameData.Cell.TREE:
			grid[pos.y][pos.x] = GameData.Cell.EMPTY
			get_node("/root/Audio").play_sfx("kill", 2.0)
			# Check for hidden treasure
			if pos in hidden_treasures:
				get_node("/root/Audio").play_sfx("treasure", 3.0)
				var treasure = hidden_treasures[pos]
				hidden_treasures.erase(pos)
				if treasure == "gold":
					gold += 15
					_show_treasure_notification("Found 15 gold!", pos)
				else:
					if bag.size() < GameData.MAX_BAG:
						bag.append(treasure)
						var tname: String = GameData.ITEM_CONFIGS[treasure]["name"]
						_show_treasure_notification("Found " + tname + "!", pos)
					else:
						gold += 10
						_show_treasure_notification("Bag full! +10 gold", pos)
			return true
		elif cell_type == GameData.Cell.TOWER:
			towers.erase(pos)
			grid[pos.y][pos.x] = GameData.Cell.EMPTY
			get_node("/root/Audio").play_sfx("kill", 2.0)
			# Recalc nearby towers that may have lost adjacency to upgrades
			var neighbors: Array[Vector2i] = [pos + Vector2i(0,-1), pos + Vector2i(0,1), pos + Vector2i(-1,0), pos + Vector2i(1,0)]
			for n in neighbors:
				if n in towers:
					_recalc_tower_upgrades(n)
			return true
		elif cell_type == GameData.Cell.UPGRADE:
			upgrades.erase(pos)
			grid[pos.y][pos.x] = GameData.Cell.EMPTY
			get_node("/root/Audio").play_sfx("kill", 2.0)
			# Recalc adjacent towers that lost this upgrade
			var neighbors: Array[Vector2i] = [pos + Vector2i(0,-1), pos + Vector2i(0,1), pos + Vector2i(-1,0), pos + Vector2i(1,0)]
			for n in neighbors:
				if n in towers:
					_recalc_tower_upgrades(n)
			return true
		return false
	elif config["type"] == "mega_bomb":
		if not is_valid_cell(pos):
			return false
		# Destroy everything in 3x3 area
		var destroyed: int = 0
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var target: Vector2i = pos + Vector2i(dx, dy)
				if not is_valid_cell(target):
					continue
				var ct: int = grid[target.y][target.x]
				if ct == GameData.Cell.ROCK or ct == GameData.Cell.TREE:
					grid[target.y][target.x] = GameData.Cell.EMPTY
					if target in hidden_treasures:
						hidden_treasures.erase(target)
						gold += 10
					destroyed += 1
				elif ct == GameData.Cell.TOWER:
					towers.erase(target)
					grid[target.y][target.x] = GameData.Cell.EMPTY
					destroyed += 1
				elif ct == GameData.Cell.UPGRADE:
					upgrades.erase(target)
					grid[target.y][target.x] = GameData.Cell.EMPTY
					destroyed += 1
		if destroyed > 0:
			get_node("/root/Audio").play_sfx("kill", 4.0)
			screen_shake(10.0, 0.3)
			_show_treasure_notification("BOOM! Cleared " + str(destroyed) + " tiles!", pos)
			# Recalc all towers
			for t_pos in towers:
				_recalc_tower_upgrades(t_pos)
			return true
		return false
	return false

func _recalc_tower_upgrades(tower_pos: Vector2i) -> void:
	if tower_pos not in towers:
		return
	var tower: Dictionary = towers[tower_pos]
	var tc: Dictionary = GameData.TOWER_CONFIGS[tower["type"]]
	tower["damage"] = tc["damage"]
	tower["range"] = tc["range"]
	tower["cooldown"] = tc["cooldown"]
	# Apply adjacent upgrades
	var neighbors: Array[Vector2i] = [tower_pos + Vector2i(0,-1), tower_pos + Vector2i(0,1), tower_pos + Vector2i(-1,0), tower_pos + Vector2i(1,0)]
	for n in neighbors:
		if n in upgrades:
			var uc: Dictionary = GameData.ITEM_CONFIGS[upgrades[n]]
			var stat: String = uc["stat"]
			tower[stat] += uc["value"]
	tower["cooldown"] = max(0.2, tower["cooldown"])

func _show_treasure_notification(text: String, pos: Vector2i) -> void:
	treasure_notification = text
	treasure_notify_timer = 2.0
	# Spawn a floating text at the position
	var dmg_script: GDScript = load("res://scripts/damage_number.gd")
	var label: Node2D = Node2D.new()
	label.set_script(dmg_script)
	add_child(label)
	label.setup(text, cell_to_world(pos) + Vector2(0, -20))
	label.lifetime = 1.5

var wave_composition: Array = []

func start_wave() -> void:
	if phase != "build" or game_over:
		return
	wave += 1
	phase = "fight"
	wave_composition = GameData.get_wave_composition(wave)
	spawn_queue = wave_composition.size()
	spawn_timer = 0.5
	selected_bag_index = -1
	_update_hud()

func screen_shake(intensity: float = 4.0, duration: float = 0.15) -> void:
	shake_intensity = intensity
	shake_timer = duration

func _process(delta: float) -> void:
	if treasure_notify_timer > 0:
		treasure_notify_timer -= delta
	# Screen shake
	if shake_timer > 0:
		shake_timer -= delta
		camera.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		if shake_timer <= 0:
			camera.offset = Vector2.ZERO
	# Tree sway animation
	tree_anim_timer += delta
	if tree_anim_timer >= 0.15:
		tree_anim_timer = 0.0
		tree_anim_frame = (tree_anim_frame + 1) % 8
	if game_over:
		return
	if phase == "fight":
		_process_spawning(delta)
		_process_towers(delta)
		_process_enemies(delta)
		_process_projectiles(delta)
		_check_wave_end()
	queue_redraw()

func _process_spawning(delta: float) -> void:
	if spawn_queue <= 0:
		return
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = 0.55
		spawn_queue -= 1
		var enemy_type: int = wave_composition.pop_front() if wave_composition.size() > 0 else 0
		_spawn_enemy(enemy_type)

func _spawn_enemy(enemy_type: int) -> void:
	var script: GDScript = load("res://scripts/enemy.gd")
	var e: Node2D = Node2D.new()
	e.set_script(script)
	enemy_container.add_child(e)
	e.setup(GameData.ENEMY_PATH, GameData.get_base_hp(wave), GameData.get_base_speed(wave), self, enemy_type)
	enemies.append(e)

func _process_towers(delta: float) -> void:
	for pos in towers:
		var tower: Dictionary = towers[pos]
		tower["timer"] -= delta
		if tower["timer"] > 0:
			continue
		var tower_world: Vector2 = cell_to_world(pos)
		var best_enemy: Node2D = null
		var best_progress: float = -1.0
		for e in enemies:
			if not is_instance_valid(e) or e.is_dead:
				continue
			var dist: float = tower_world.distance_to(e.global_position) / GameData.CELL_SIZE
			if dist <= tower["range"]:
				if e.path_progress > best_progress:
					best_progress = e.path_progress
					best_enemy = e
		if best_enemy:
			tower["timer"] = tower["cooldown"]
			var tc: Dictionary = GameData.TOWER_CONFIGS[tower["type"]]

			# Frost tower: slow enemies
			if "slow" in tc:
				best_enemy.apply_slow(tc["slow"], 2.0)

			# Tesla tower: chain to nearby enemies
			if "chain" in tc:
				var chain_count: int = tc["chain"]
				var hit_enemies: Array = [best_enemy]
				best_enemy.take_damage(tower["damage"])
				_spawn_projectile(tower_world, best_enemy.global_position)
				# Chain to nearby enemies
				var last_pos: Vector2 = best_enemy.global_position
				for _c in range(chain_count - 1):
					var next_enemy: Node2D = null
					var next_dist: float = 2.0 * GameData.CELL_SIZE
					for e in enemies:
						if not is_instance_valid(e) or e.is_dead or e in hit_enemies:
							continue
						var d: float = last_pos.distance_to(e.global_position)
						if d < next_dist:
							next_dist = d
							next_enemy = e
					if next_enemy:
						next_enemy.take_damage(tower["damage"])
						_spawn_projectile(last_pos, next_enemy.global_position)
						hit_enemies.append(next_enemy)
						last_pos = next_enemy.global_position
					else:
						break
			elif "pierce" in tc:
				# Racer: car pierces through multiple enemies along the path
				var pierce_count: int = tc["pierce"]
				var dir_to_target: Vector2 = (best_enemy.global_position - tower_world).normalized()
				var hit_enemies: Array = []
				# Find all enemies roughly in the line of fire
				for e in enemies:
					if not is_instance_valid(e) or e.is_dead:
						continue
					var to_e: Vector2 = e.global_position - tower_world
					var proj: float = to_e.dot(dir_to_target)
					if proj > 0:
						var perp_dist: float = abs(to_e.cross(dir_to_target))
						if perp_dist < GameData.CELL_SIZE * 0.6:
							hit_enemies.append({"enemy": e, "dist": proj})
				hit_enemies.sort_custom(func(a, b): return a["dist"] < b["dist"])
				var hits: int = 0
				var last_pos: Vector2 = tower_world
				for entry in hit_enemies:
					if hits >= pierce_count:
						break
					entry["enemy"].take_damage(tower["damage"])
					_spawn_projectile(last_pos, entry["enemy"].global_position)
					last_pos = entry["enemy"].global_position
					hits += 1
					screen_shake(6.0, 0.1)
				if hits == 0:
					best_enemy.take_damage(tower["damage"])
					_spawn_projectile(tower_world, best_enemy.global_position)
			else:
				best_enemy.take_damage(tower["damage"])
				_spawn_projectile(tower_world, best_enemy.global_position)

			get_node("/root/Audio").play_sfx("shoot", -3.0)

func _spawn_coins(pos: Vector2, value: int) -> void:
	var coin_script: GDScript = load("res://scripts/coin_fly.gd")
	var count: int = mini(value, 5)  # cap at 5 coins visually
	for i in range(count):
		var coin: Node2D = Node2D.new()
		coin.set_script(coin_script)
		add_child(coin)
		var offset: Vector2 = Vector2(randf_range(-15, 15), randf_range(-15, 15))
		coin.setup(pos + offset, 1)
		# Stagger slightly so they don't all fly at once
		coin.progress = -i * 0.08

func _spawn_projectile(from: Vector2, to: Vector2) -> void:
	var script: GDScript = load("res://scripts/projectile.gd")
	var p: Node2D = Node2D.new()
	p.set_script(script)
	projectile_container.add_child(p)
	p.setup(from, to)
	projectiles.append(p)

func _process_enemies(_delta: float) -> void:
	var to_remove: Array = []
	for e in enemies:
		if not is_instance_valid(e):
			to_remove.append(e)
			continue
		if e.is_dead:
			gold += e.gold_value
			to_remove.append(e)
			get_node("/root/Audio").play_sfx("kill")
			_spawn_coins(e.global_position, e.gold_value)
			screen_shake(5.0, 0.12)
		elif e.reached_end:
			hp -= 1
			e.queue_free()
			to_remove.append(e)
			get_node("/root/Audio").play_sfx("warn", 3.0)
			screen_shake(8.0, 0.25)
			if hp <= 0:
				_game_over()
	for e in to_remove:
		enemies.erase(e)
	_update_hud()

func _process_projectiles(_delta: float) -> void:
	var to_remove: Array = []
	for p in projectiles:
		if not is_instance_valid(p):
			to_remove.append(p)
		elif p.done:
			p.queue_free()
			to_remove.append(p)
	for p in to_remove:
		projectiles.erase(p)

func _check_wave_end() -> void:
	if spawn_queue > 0:
		return
	for e in enemies:
		if is_instance_valid(e) and not e.is_dead and not e.reached_end:
			return
	# Wave complete
	phase = "build"
	gold += 5 + wave * 2  # wave bonus
	_update_hud()

func _game_over() -> void:
	game_over = true
	phase = "over"
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hovered_cell = world_to_cell(get_global_mouse_position())
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(get_global_mouse_position())
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		selected_bag_index = -1

func _handle_click(pos: Vector2) -> void:
	if game_over:
		return
	if phase != "build":
		return
	# Check if clicking on HUD area (handled by HUD)
	# Check grid placement
	var cell: Vector2i = world_to_cell(pos)
	if selected_bag_index >= 0 and selected_bag_index < bag.size():
		var item: int = bag[selected_bag_index]
		if place_item(cell, item):
			bag.remove_at(selected_bag_index)
			selected_bag_index = -1
			_update_hud()

func buy_spin() -> void:
	if gold < GameData.SPIN_COST:
		return
	if bag.size() >= GameData.MAX_BAG:
		return
	gold -= GameData.SPIN_COST
	var item: int = GameData.roll_shop_item()
	bag.append(item)
	_update_hud()

func select_bag_item(index: int) -> void:
	if index >= 0 and index < bag.size():
		selected_bag_index = index
	else:
		selected_bag_index = -1

func _update_hud() -> void:
	var hud: Control = $UILayer/HUD
	if hud and hud.has_method("refresh"):
		hud.refresh(hp, gold, wave, max_waves, bag, selected_bag_index, phase, game_over)

func restart() -> void:
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	enemies.clear()
	for p in projectiles:
		if is_instance_valid(p):
			p.queue_free()
	projectiles.clear()
	grid.clear()
	towers.clear()
	upgrades.clear()
	hidden_treasures.clear()
	bag.clear()
	gold = GameData.STARTING_GOLD
	hp = GameData.MAX_HP
	wave = 0
	phase = "build"
	game_over = false
	spawn_queue = 0
	selected_bag_index = -1
	_init_grid()
	_update_hud()

# === DRAWING ===

func _draw() -> void:
	_draw_grid()
	_draw_path_arrows()
	_draw_towers()
	_draw_upgrades()
	_draw_treasure_sparkles()
	_draw_hover()
	_draw_notification()

func _draw_grid() -> void:
	# Grass tile from tilemap: center tile at row 1, col 1 (64x64 each in 576x384 sheet)
	var grass_src: Rect2 = Rect2(64, 64, 64, 64)
	for y in range(GameData.GRID_H):
		for x in range(GameData.GRID_W):
			var rect: Rect2 = Rect2(GameData.GRID_OFFSET + Vector2(x * GameData.CELL_SIZE, y * GameData.CELL_SIZE), Vector2(GameData.CELL_SIZE, GameData.CELL_SIZE))
			var cell: int = grid[y][x]
			# Draw grass ground for all cells
			if grass_texture:
				draw_texture_rect_region(grass_texture, rect, grass_src)
			else:
				draw_rect(rect, Color(0.18, 0.18, 0.22))
			# Draw dirt path overlay
			if cell == GameData.Cell.PATH:
				draw_rect(rect, Color(0.55, 0.42, 0.28))
			# Draw decorations on top
			match cell:
				GameData.Cell.ROCK:
					_draw_rock(rect.get_center(), x + y)
				GameData.Cell.TREE:
					_draw_tree(rect.get_center())
			# Cell border (subtle)
			draw_rect(rect, Color(0.2, 0.3, 0.15, 0.3), false, 1.0)

func _draw_rock(center: Vector2, seed_val: int = 0) -> void:
	if rock_textures.size() > 0:
		var tex: Texture2D = rock_textures[seed_val % rock_textures.size()]
		var dst: Rect2 = Rect2(center - Vector2(30, 30), Vector2(60, 60))
		draw_texture_rect(tex, dst, false)
	else:
		var pts: PackedVector2Array = PackedVector2Array([
			center + Vector2(-12, 8), center + Vector2(-8, -10), center + Vector2(4, -12),
			center + Vector2(14, -4), center + Vector2(10, 10), center + Vector2(-4, 12),
		])
		draw_colored_polygon(pts, Color(0.4, 0.38, 0.35))

func _draw_tree(center: Vector2) -> void:
	if tree_texture:
		# Tree sprite: 1536x256, 8 frames of 192x256
		var frame_w: float = 192.0
		var frame_h: float = 256.0
		var src: Rect2 = Rect2(tree_anim_frame * frame_w, 0, frame_w, frame_h)
		var dst_h: float = 80.0
		var dst_w: float = dst_h * (frame_w / frame_h)
		var dst: Rect2 = Rect2(center.x - dst_w / 2, center.y - dst_h * 0.6, dst_w, dst_h)
		draw_texture_rect_region(tree_texture, dst, src)
	else:
		draw_rect(Rect2(center.x - 3, center.y, 6, 14), Color(0.35, 0.22, 0.1))
		draw_circle(center + Vector2(0, -6), 14, Color(0.15, 0.45, 0.2))

func _draw_path_arrows() -> void:
	for i in range(GameData.ENEMY_PATH.size() - 1):
		var from: Vector2 = cell_to_world(GameData.ENEMY_PATH[i])
		var to: Vector2 = cell_to_world(GameData.ENEMY_PATH[i + 1])
		var mid: Vector2 = (from + to) / 2
		var dir: Vector2 = (to - from).normalized()
		var perp: Vector2 = Vector2(-dir.y, dir.x)
		# Arrow chevron
		var tip: Vector2 = mid + dir * 8
		draw_line(tip, tip - dir * 10 + perp * 6, Color(0.4, 0.4, 0.45, 0.5), 2.0)
		draw_line(tip, tip - dir * 10 - perp * 6, Color(0.4, 0.4, 0.45, 0.5), 2.0)

func _draw_towers() -> void:
	# Tower sprite order in sheet: TURRET=0, TREBUCHET=1, FROST=2, TESLA=3, RACER=4
	var tower_frame_map: Dictionary = {
		GameData.TowerType.TURRET: 0,
		GameData.TowerType.TREBUCHET: 1,
		GameData.TowerType.FROST: 2,
		GameData.TowerType.TESLA: 3,
		GameData.TowerType.RACER: 4,
	}
	for pos in towers:
		var tower: Dictionary = towers[pos]
		var center: Vector2 = cell_to_world(pos)
		var tc: Dictionary = GameData.TOWER_CONFIGS[tower["type"]]
		# Draw tower sprite
		if tower_texture:
			var frame: int = tower_frame_map.get(tower["type"], 0)
			var src_rect: Rect2 = Rect2(frame * 64, 0, 64, 64)
			var dst_size: float = 56.0
			var dst_rect: Rect2 = Rect2(center - Vector2(dst_size / 2, dst_size / 2), Vector2(dst_size, dst_size))
			draw_texture_rect_region(tower_texture, dst_rect, src_rect)
		else:
			# Fallback: colored rectangles
			draw_rect(Rect2(center - Vector2(20, 20), Vector2(40, 40)), tc["color"].darkened(0.3))
			draw_rect(Rect2(center - Vector2(16, 16), Vector2(32, 32)), tc["color"])
		# Range circle (build phase only)
		if phase == "build":
			draw_arc(center, tower["range"] * GameData.CELL_SIZE, 0, TAU, 48, Color(1, 1, 1, 0.1), 1.0)

func _draw_upgrades() -> void:
	for pos in upgrades:
		var item_type: int = upgrades[pos]
		var config: Dictionary = GameData.ITEM_CONFIGS[item_type]
		var center: Vector2 = cell_to_world(pos)
		draw_rect(Rect2(center - Vector2(14, 14), Vector2(28, 28)), config["color"].darkened(0.2))
		draw_string(ThemeDB.fallback_font, center + Vector2(-12, 4), config["name"], HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.WHITE)

func _draw_hover() -> void:
	if not is_valid_cell(hovered_cell) or phase != "build":
		return
	var rect: Rect2 = Rect2(GameData.GRID_OFFSET + Vector2(hovered_cell.x * GameData.CELL_SIZE, hovered_cell.y * GameData.CELL_SIZE), Vector2(GameData.CELL_SIZE, GameData.CELL_SIZE))
	var color: Color = Color(1, 1, 1, 0.15)
	if selected_bag_index >= 0 and selected_bag_index < bag.size():
		var item: int = bag[selected_bag_index]
		var config: Dictionary = GameData.ITEM_CONFIGS[item]
		if config["type"] == "tower" and can_place_tower(hovered_cell):
			color = Color(0.3, 1, 0.3, 0.25)
		elif config["type"] == "upgrade" and can_place_upgrade(hovered_cell):
			color = Color(0.3, 0.7, 1, 0.25)
		elif config["type"] == "bomb" and is_valid_cell(hovered_cell) and grid[hovered_cell.y][hovered_cell.x] in [GameData.Cell.ROCK, GameData.Cell.TREE, GameData.Cell.TOWER, GameData.Cell.UPGRADE]:
			color = Color(1, 0.8, 0, 0.3)
		elif config["type"] == "mega_bomb" and is_valid_cell(hovered_cell):
			color = Color(1, 0.5, 0, 0.3)
		else:
			color = Color(1, 0.2, 0.2, 0.2)
	draw_rect(rect, color)
	# Draw 3x3 area for mega bomb
	if selected_bag_index >= 0 and selected_bag_index < bag.size():
		var item: int = bag[selected_bag_index]
		var cfg: Dictionary = GameData.ITEM_CONFIGS[item]
		if cfg["type"] == "mega_bomb" and is_valid_cell(hovered_cell):
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if dx == 0 and dy == 0:
						continue
					var neighbor: Vector2i = hovered_cell + Vector2i(dx, dy)
					if is_valid_cell(neighbor):
						var nr: Rect2 = Rect2(GameData.GRID_OFFSET + Vector2(neighbor.x * GameData.CELL_SIZE, neighbor.y * GameData.CELL_SIZE), Vector2(GameData.CELL_SIZE, GameData.CELL_SIZE))
						draw_rect(nr, Color(1, 0.5, 0, 0.15))
	draw_rect(rect, Color(1, 1, 1, 0.4), false, 2.0)

func _draw_treasure_sparkles() -> void:
	var t: float = Time.get_ticks_msec() / 1000.0
	for pos in hidden_treasures:
		if not is_valid_cell(pos):
			continue
		if grid[pos.y][pos.x] != GameData.Cell.ROCK and grid[pos.y][pos.x] != GameData.Cell.TREE:
			continue
		var center: Vector2 = cell_to_world(pos)
		# Subtle twinkling sparkle — 2 small dots that pulse
		var sparkle_alpha: float = 0.3 + sin(t * 3.0 + pos.x * 1.5) * 0.25
		var offset1: Vector2 = Vector2(sin(t * 2.0 + pos.y) * 8, cos(t * 1.7 + pos.x) * 6)
		var offset2: Vector2 = Vector2(cos(t * 2.5 + pos.x) * 10, sin(t * 1.9 + pos.y) * 7)
		draw_circle(center + offset1, 2.0, Color(1.0, 0.9, 0.4, sparkle_alpha))
		draw_circle(center + offset2, 1.5, Color(1.0, 1.0, 0.8, sparkle_alpha * 0.7))

func _draw_notification() -> void:
	if treasure_notify_timer > 0 and treasure_notification != "":
		var alpha: float = min(1.0, treasure_notify_timer)
		var pos: Vector2 = Vector2(450, 40)
		draw_string(ThemeDB.fallback_font, pos + Vector2(1, 1), treasure_notification, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(0, 0, 0, alpha * 0.5))
		draw_string(ThemeDB.fallback_font, pos, treasure_notification, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(1.0, 0.9, 0.2, alpha))
