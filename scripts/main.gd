extends Node2D

var base_room: Node2D
var second_room: Node2D
var corridor_node: Node2D
var units_node: Node2D
var wormhole_node: Node2D  # visual entity inside room 2

var protectors: Array = []
var enemies: Array = []

# Wormhole state
var wormhole_active: bool = false
var wormhole_spawn_time: float = 6.0
var wormhole_timer: float = 0.0
var wormhole_hp: int = 120
var wormhole_max_hp: int = 120

# Enemy spawning
var spawn_timer: float = 0.0
var spawn_interval: float = 2.0
var total_enemies_spawned: int = 0

# Base resources
var base_resources: int = 100
var max_resources: int = 100
var drain_rate: int = 2

var game_over: bool = false
var game_won: bool = false
var unit_script: GDScript
var hud: Control

func _ready() -> void:
	unit_script = load("res://scripts/unit.gd")
	_build_world()
	_spawn_protectors(4)
	_update_hud()

func _build_world() -> void:
	# Corridor (rendered behind rooms)
	var corridor_script: GDScript = load("res://scripts/corridor.gd")
	corridor_node = Node2D.new()
	corridor_node.set_script(corridor_script)
	add_child(corridor_node)

	var room_script: GDScript = load("res://scripts/room.gd")

	# Room 1: Main Base (left)
	base_room = Node2D.new()
	base_room.set_script(room_script)
	add_child(base_room)
	base_room.setup(base_room.RoomType.BASE, 280.0, 200.0, "Main Base")
	base_room.global_position = Vector2(250, 360)
	base_room.set_door("right")

	# Room 2: Second room (right) — normal room, always visible
	second_room = Node2D.new()
	second_room.set_script(room_script)
	add_child(second_room)
	second_room.setup(second_room.RoomType.OUTPOST, 220.0, 160.0, "Outpost")
	second_room.global_position = Vector2(1000, 360)
	second_room.set_door("left")

	# Corridor between doors
	corridor_node.setup(base_room.get_door_world(), second_room.get_door_world())

	# Wormhole entity (hidden until activated)
	wormhole_node = Node2D.new()
	wormhole_node.set_script(load("res://scripts/wormhole.gd"))
	add_child(wormhole_node)
	wormhole_node.global_position = second_room.global_position
	wormhole_node.visible = false

	# Units container
	units_node = Node2D.new()
	units_node.name = "Units"
	add_child(units_node)

	# HUD
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.name = "UILayer"
	add_child(canvas)

	hud = Control.new()
	hud.set_script(load("res://scripts/hud.gd"))
	hud.name = "HUD"
	canvas.add_child(hud)

func _spawn_protectors(count: int) -> void:
	for i in range(count):
		var unit: Node2D = _create_unit(0, 20, 3, 55.0)
		unit.global_position = base_room.get_center() + Vector2(-30 * i, 0)
		protectors.append(unit)
	# First protector is the leader — patrols
	# Rest follow the one in front
	_assign_group_patrol()

func _create_unit(team: int, hp: int, atk: int, spd: float) -> Node2D:
	var unit: Node2D = Node2D.new()
	unit.set_script(unit_script)
	units_node.add_child(unit)
	unit.setup(team, hp, atk, spd)
	unit.died.connect(_on_unit_died)
	return unit

func _assign_group_patrol() -> void:
	var shared_path: Array = [
		base_room.get_center(),
		base_room.get_door_world(),
		second_room.get_door_world(),
		second_room.get_center(),
		second_room.get_door_world(),
		base_room.get_door_world(),
		base_room.get_center(),
	]
	for i in range(protectors.size()):
		var unit: Node2D = protectors[i]
		if not is_instance_valid(unit) or unit.is_dead:
			continue
		if i == 0:
			# Leader patrols on waypoints
			unit.follow_target_unit = null
			unit.set_patrol(shared_path)
		else:
			# Followers follow the unit in front with spacing
			unit.follow_target_unit = protectors[i - 1]
			unit.follow_distance = 35.0
			unit.is_patrolling = false
			unit.has_move_target = false
			# Slightly slower so spacing builds naturally
			unit.speed = 55.0 - i * 2.0

func _reassign_patrol_for(unit: Node2D) -> void:
	# After combat, rejoin the group by following the leader
	if protectors.size() > 0 and is_instance_valid(protectors[0]) and not protectors[0].is_dead:
		unit.follow_target_unit = protectors[0]
		unit.follow_distance = 30.0
		unit.is_patrolling = false

func _process(delta: float) -> void:
	if game_over or game_won:
		return

	# Wormhole appearance timer
	if not wormhole_active:
		wormhole_timer += delta
		if wormhole_timer >= wormhole_spawn_time:
			_activate_wormhole()
	else:
		# Spawn enemies
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_timer = max(1.2, spawn_interval - total_enemies_spawned * 0.04)
			_spawn_enemy()

		# Enemies drain base resources
		_process_enemy_drain()

		# Protectors near wormhole attack it
		_process_protector_wormhole_attack()

	# Combat AI
	_update_enemy_ai()
	_update_protector_ai()

	# Win/lose checks
	if wormhole_active and wormhole_hp <= 0:
		_victory()
	if base_resources <= 0:
		_defeat()

	_update_hud()

func _activate_wormhole() -> void:
	wormhole_active = true
	wormhole_node.visible = true
	spawn_timer = 2.0

func _spawn_enemy() -> void:
	total_enemies_spawned += 1
	var scaling: float = 1.0 + total_enemies_spawned * 0.06
	var unit: Node2D = _create_unit(
		1,
		int(10 * scaling),
		int(2 * scaling),
		50.0 + total_enemies_spawned * 1.0
	)
	# Spawn near the wormhole inside room 2
	unit.global_position = second_room.get_center() + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	enemies.append(unit)

	# Path: room 2 door → base door → inside base
	unit.set_move_path([
		second_room.get_door_world(),
		base_room.get_door_world(),
		base_room.get_random_interior_pos(),
	])

func _process_enemy_drain() -> void:
	for e in enemies:
		if not is_instance_valid(e) or e.is_dead:
			continue
		# Enemy inside base with no target → drain
		if base_room.is_inside(e.global_position):
			if e.target == null or not is_instance_valid(e.target) or e.target.is_dead:
				if e.drain_timer <= 0:
					e.drain_timer = e.drain_cooldown
					base_resources = max(0, base_resources - drain_rate)

func _process_protector_wormhole_attack() -> void:
	if wormhole_hp <= 0:
		return
	for p in protectors:
		if not is_instance_valid(p) or p.is_dead:
			continue
		# If protector is near the wormhole (inside room 2), attack it
		var dist: float = p.global_position.distance_to(wormhole_node.global_position)
		if dist < 60.0:
			# Only attack if not fighting an enemy
			if p.target == null or not is_instance_valid(p.target) or p.target.is_dead:
				p.attack_timer -= get_process_delta_time()
				if p.attack_timer <= 0:
					p.attack_timer = p.attack_cooldown
					wormhole_hp = max(0, wormhole_hp - p.attack_damage)
					# Brief flash on wormhole
					wormhole_node.flash()

func _update_enemy_ai() -> void:
	for e in enemies:
		if not is_instance_valid(e) or e.is_dead:
			continue
		if e.target == null or not is_instance_valid(e.target) or e.target.is_dead:
			e.target = null
			# If near a protector, fight them
			var closest: Node2D = _find_closest_unit(e.global_position, protectors, 100.0)
			if closest:
				e.target = closest
				e.has_move_target = false

func _update_protector_ai() -> void:
	for p in protectors:
		if not is_instance_valid(p) or p.is_dead:
			continue
		if p.target == null or not is_instance_valid(p.target) or p.target.is_dead:
			p.target = null
			# Find nearby enemy to fight
			var closest: Node2D = _find_closest_unit(p.global_position, enemies, 150.0)
			if closest:
				p.target = closest
				p.is_patrolling = false
			elif not p.is_patrolling:
				# Resume patrol
				_reassign_patrol_for(p)

func _find_closest_unit(pos: Vector2, units: Array, max_range: float) -> Node2D:
	var closest: Node2D = null
	var closest_dist: float = max_range
	for u in units:
		if not is_instance_valid(u) or u.is_dead:
			continue
		var d: float = pos.distance_to(u.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = u
	return closest

func _on_unit_died(unit: Node2D) -> void:
	if unit.team == 0:
		protectors.erase(unit)
	else:
		enemies.erase(unit)

func _victory() -> void:
	game_won = true
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	enemies.clear()
	wormhole_node.visible = false
	if hud and hud.has_method("show_victory"):
		hud.show_victory(total_enemies_spawned, base_resources)

func _defeat() -> void:
	game_over = true
	if hud and hud.has_method("show_defeat"):
		hud.show_defeat(total_enemies_spawned)

func _update_hud() -> void:
	if hud and hud.has_method("update_info"):
		var alive: int = 0
		for p in protectors:
			if is_instance_valid(p) and not p.is_dead:
				alive += 1
		hud.update_info(alive, base_resources, max_resources, wormhole_hp, wormhole_max_hp, wormhole_active)

func restart() -> void:
	for u in protectors + enemies:
		if is_instance_valid(u):
			u.queue_free()
	protectors.clear()
	enemies.clear()
	wormhole_active = false
	wormhole_timer = 0.0
	wormhole_hp = wormhole_max_hp
	wormhole_node.visible = false
	base_resources = max_resources
	total_enemies_spawned = 0
	spawn_timer = 0.0
	game_over = false
	game_won = false
	_spawn_protectors(4)
	_update_hud()
