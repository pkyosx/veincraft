extends Node2D

enum Team { PROTECTOR, ENEMY }

var team: int = Team.PROTECTOR
var hp: int = 10
var max_hp: int = 10
var attack_damage: int = 2
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0
var speed: float = 60.0
var target: Node2D = null
var move_target: Vector2 = Vector2.ZERO
var has_move_target: bool = false
var move_waypoints: Array = []
var is_dead: bool = false

# Patrol system
var is_patrolling: bool = false
var patrol_points: Array = []
var patrol_index: int = 0

# Resource drain (enemies)
var drain_timer: float = 0.0
var drain_cooldown: float = 1.5

# Formation offset (protectors walk in line)
var formation_offset: Vector2 = Vector2.ZERO
var follow_target_unit: Node2D = null  # unit to follow (for line formation)
var follow_distance: float = 30.0

const UNIT_RADIUS: float = 10.0
const HP_BAR_W: float = 24.0
const HP_BAR_H: float = 3.0

signal died(unit: Node2D)

func setup(p_team: int, p_hp: int, p_attack: int, p_speed: float) -> void:
	team = p_team
	hp = p_hp
	max_hp = p_hp
	attack_damage = p_attack
	speed = p_speed

func _process(delta: float) -> void:
	if is_dead:
		return

	# Drain timer countdown (for enemies in base)
	if drain_timer > 0:
		drain_timer -= delta

	# Follower mode: follow another unit instead of patrol
	if follow_target_unit != null and is_instance_valid(follow_target_unit) and not follow_target_unit.is_dead:
		if target == null or not is_instance_valid(target) or target.is_dead:
			target = null
			var dist: float = global_position.distance_to(follow_target_unit.global_position)
			if dist > follow_distance:
				var dir: Vector2 = (follow_target_unit.global_position - global_position).normalized()
				global_position += dir * speed * delta
			queue_redraw()
			return

	# Combat target takes priority
	if target != null and is_instance_valid(target) and not target.is_dead:
		var dist: float = global_position.distance_to(target.global_position)
		if dist > UNIT_RADIUS * 3:
			var dir: Vector2 = (target.global_position - global_position).normalized()
			global_position += dir * speed * delta
		else:
			attack_timer -= delta
			if attack_timer <= 0:
				attack_timer = attack_cooldown
				_do_attack()
	else:
		target = null
		# Move along waypoints
		if has_move_target:
			var actual_target: Vector2 = move_target + formation_offset
			var dir: Vector2 = (actual_target - global_position)
			if dir.length() > 4.0:
				global_position += dir.normalized() * speed * delta
			else:
				if move_waypoints.size() > 0:
					move_target = move_waypoints.pop_front()
				else:
					has_move_target = false
					# If patrolling, advance to next patrol point
					if is_patrolling and patrol_points.size() > 0:
						patrol_index = (patrol_index + 1) % patrol_points.size()
						move_target = patrol_points[patrol_index]
						has_move_target = true
		elif is_patrolling and patrol_points.size() > 0:
			# Start next patrol leg
			patrol_index = (patrol_index + 1) % patrol_points.size()
			move_target = patrol_points[patrol_index]
			has_move_target = true

	queue_redraw()

func _do_attack() -> void:
	if target and is_instance_valid(target) and not target.is_dead:
		target.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	hp -= amount
	if hp <= 0:
		hp = 0
		is_dead = true
		died.emit(self)
		var tween: Tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.3)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
		tween.tween_callback(queue_free)

func set_move_target(pos: Vector2) -> void:
	move_target = pos
	has_move_target = true
	move_waypoints.clear()

func set_move_path(waypoints: Array) -> void:
	if waypoints.is_empty():
		return
	move_target = waypoints[0]
	has_move_target = true
	move_waypoints = waypoints.slice(1)

func set_patrol(points: Array) -> void:
	if points.is_empty():
		return
	patrol_points = points
	patrol_index = 0
	is_patrolling = true
	move_target = patrol_points[0]
	has_move_target = true

func _draw() -> void:
	var body_color: Color
	if team == Team.PROTECTOR:
		body_color = Color(0.2, 0.6, 0.9)
	else:
		body_color = Color(0.85, 0.2, 0.15)

	draw_circle(Vector2(1.5, 1.5), UNIT_RADIUS, Color(0, 0, 0, 0.25))
	draw_circle(Vector2.ZERO, UNIT_RADIUS, body_color)
	draw_circle(Vector2(-2, -2), UNIT_RADIUS * 0.5, body_color.lightened(0.3))

	# HP bar
	if hp < max_hp:
		var bar_y: float = -UNIT_RADIUS - 6
		draw_rect(Rect2(-HP_BAR_W / 2, bar_y, HP_BAR_W, HP_BAR_H), Color(0.15, 0.15, 0.15))
		var ratio: float = float(hp) / float(max_hp)
		var bar_color: Color = Color(0.2, 0.8, 0.2) if ratio > 0.5 else Color(0.8, 0.2, 0.2)
		draw_rect(Rect2(-HP_BAR_W / 2, bar_y, HP_BAR_W * ratio, HP_BAR_H), bar_color)

	# Drain indicator for enemies (pulsing gold dot)
	if team == Team.ENEMY and drain_timer <= 0 and has_move_target == false and target == null:
		var pulse: float = abs(sin(Time.get_ticks_msec() / 200.0))
		draw_circle(Vector2(0, UNIT_RADIUS + 4), 3.0, Color(1.0, 0.8, 0.1, pulse))
