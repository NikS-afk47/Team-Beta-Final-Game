extends CharacterBody2D

@export var player_id: int = 1

@export var move_speed: float = 320.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_force: float = -500.0
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 950.0

@export var max_health: int = 100
@export var attack_damage: int = 10
@export var attack_knockback_x: float = 260.0
@export var attack_knockback_y: float = -140.0
@export var attack_duration: float = 0.15

@onready var visuals: Node2D = $Visuals
@onready var body: Line2D = $Visuals/Body
@onready var left_arm: Line2D = $Visuals/LeftArm
@onready var right_arm: Line2D = $Visuals/RightArm
@onready var left_leg: Line2D = $Visuals/LegLeft
@onready var right_leg: Line2D = $Visuals/LegRight
@onready var head: Node2D = $Visuals/Head

@onready var hurtbox: Area2D = $Hurtbox
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_timer: Timer = $AttackTimer

var facing: int = 1
var health: int = 100
var is_attacking: bool = false
var attack_has_hit: bool = false

func _ready() -> void:
	health = max_health
	setup_colors()

	attack_hitbox.monitoring = false
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement(delta)
	handle_jump()
	handle_attack_input()
	update_facing()
	move_and_slide()
	update_stickman_animation()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed

func handle_movement(delta: float) -> void:
	var dir = get_move_input()

	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func handle_jump() -> void:
	if get_jump_pressed() and is_on_floor():
		velocity.y = jump_force

func handle_attack_input() -> void:
	if get_attack_pressed() and not is_attacking:
		start_attack()

func start_attack() -> void:
	is_attacking = true
	attack_has_hit = false
	attack_hitbox.monitoring = true
	attack_timer.start(attack_duration)

	if facing == 1:
		attack_hitbox.position.x = 18
	else:
		attack_hitbox.position.x = -18

	if right_arm != null:
		right_arm.rotation_degrees = -55

func _on_attack_timer_timeout() -> void:
	is_attacking = false
	attack_hitbox.monitoring = false

func update_facing() -> void:
	if velocity.x > 5.0:
		facing = 1
	elif velocity.x < -5.0:
		facing = -1

	visuals.scale.x = facing

func update_stickman_animation() -> void:
	var run_amount = clamp(abs(velocity.x) / move_speed, 0.0, 1.0)
	var walk_cycle = Time.get_ticks_msec() / 120.0

	if not is_attacking:
		if left_leg != null:
			left_leg.rotation_degrees = sin(walk_cycle) * 25.0 * run_amount

		if right_leg != null:
			right_leg.rotation_degrees = -sin(walk_cycle) * 25.0 * run_amount

		if left_arm != null:
			left_arm.rotation_degrees = -sin(walk_cycle) * 18.0 * run_amount

		if right_arm != null:
			right_arm.rotation_degrees = sin(walk_cycle) * 18.0 * run_amount

	if body != null:
		body.rotation_degrees = (velocity.x / move_speed) * 4.0

func setup_colors() -> void:
	var main_color: Color
	var limb_color: Color

	if player_id == 1:
		main_color = Color(0.2, 0.5, 1.0, 1.0)
		limb_color = Color(0.15, 0.38, 0.82, 1.0)
	else:
		main_color = Color(1.0, 0.25, 0.25, 1.0)
		limb_color = Color(0.82, 0.18, 0.18, 1.0)

	if body != null:
		body.default_color = main_color

	if left_arm != null:
		left_arm.default_color = limb_color
	if right_arm != null:
		right_arm.default_color = limb_color
	if left_leg != null:
		left_leg.default_color = limb_color
	if right_leg != null:
		right_leg.default_color = limb_color

func take_damage(amount: int, source_position: Vector2) -> void:
	health -= amount

	var knock_dir = sign(global_position.x - source_position.x)
	if knock_dir == 0:
		knock_dir = 1

	velocity.x = knock_dir * attack_knockback_x
	velocity.y = attack_knockback_y

	print("Player ", player_id, " health: ", health)

	if health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if not is_attacking:
		return

	if attack_has_hit:
		return

	if area == hurtbox:
		return

	var target = area.get_parent()

	if target == self:
		return

	if target != null and target.has_method("take_damage"):
		target.take_damage(attack_damage, global_position)
		attack_has_hit = true

func get_move_input() -> float:
	var left_action = "p1_left" if player_id == 1 else "p2_left"
	var right_action = "p1_right" if player_id == 1 else "p2_right"
	return Input.get_axis(left_action, right_action)

func get_jump_pressed() -> bool:
	var jump_action = "p1_jump" if player_id == 1 else "p2_jump"
	return Input.is_action_just_pressed(jump_action)

func get_attack_pressed() -> bool:
	var attack_action = "p1_attack" if player_id == 1 else "p2_attack"
	return Input.is_action_just_pressed(attack_action)
