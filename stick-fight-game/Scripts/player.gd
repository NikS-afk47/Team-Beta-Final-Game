extends CharacterBody2D

@export var player_id: int = 1
@export var device_id: int = -1

@export var bullet_scene: PackedScene
@export var thrown_weapon_scene: PackedScene

@export var move_speed: float = 320.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_force: float = -500.0
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 950.0

@export var aim_length: float = 40.0
@export var stick_deadzone: float = 0.2

@export var block_duration: float = 0.15
@export var block_cooldown: float = 1.0
@export var max_health: int = 100

@export var max_jumps: int = 2

@onready var visuals = get_node_or_null("Visuals")
@onready var body = get_node_or_null("Visuals/Body")
@onready var left_arm = get_node_or_null("Visuals/LeftArm")
@onready var right_arm = get_node_or_null("Visuals/RightArm")

@onready var weapon_hold = get_node_or_null("WeaponHold")
@onready var aim_line = get_node_or_null("AimLine")

var health: int = 100

var is_blocking: bool = false
var can_block: bool = true
var block_pressed_last_frame: bool = false

var facing: int = 1
var aim_dir: Vector2 = Vector2.RIGHT

var current_weapon: WeaponData = null
var held_weapon_sprite: Sprite2D = null

var can_shoot: bool = true
var is_dead: bool = false

var jump_was_down: bool = false
var attack_was_down: bool = false
var throw_was_down: bool = false

var jumps_left: int = 2

func _ready() -> void:
	health = max_health
	is_dead = false
	jumps_left = max_jumps
	setup_colors()
	update_aim_line()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement(delta)
	handle_jump()
	handle_aim()
	handle_block()
	handle_weapon_actions()
	handle_attack()
	update_facing()
	update_held_weapon_transform()
	move_and_slide()

	if is_on_floor():
		jumps_left = max_jumps

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed

func handle_movement(delta: float) -> void:
	var dir: float = get_move_input()

	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func handle_jump() -> void:
	if get_jump_pressed() and jumps_left > 0:
		velocity.y = jump_force
		jumps_left -= 1

func handle_aim() -> void:
	if has_controller():
		var aim_x: float = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X)
		var aim_y: float = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)

		var stick_vec: Vector2 = Vector2(aim_x, aim_y)

		if stick_vec.length() > stick_deadzone:
			aim_dir = stick_vec.normalized()
		else:
			aim_dir = Vector2.RIGHT * facing
	else:
		var mouse_pos: Vector2 = get_global_mouse_position()
		aim_dir = (mouse_pos - global_position).normalized()

		if aim_dir == Vector2.ZERO:
			aim_dir = Vector2.RIGHT * facing

	update_aim_line()

func handle_block() -> void:
	if get_block_pressed() and can_block:
		can_block = false
		is_blocking = true

		flash_block()

		if aim_line != null:
			aim_line.default_color = Color(0.4, 0.8, 1.0, 1.0)

		await get_tree().create_timer(block_duration).timeout

		is_blocking = false

		if aim_line != null:
			aim_line.default_color = Color(1, 1, 1, 1)

		await get_tree().create_timer(block_cooldown).timeout
		can_block = true

func handle_weapon_actions() -> void:
	if get_throw_pressed():
		throw_weapon()

func handle_attack() -> void:
	if get_attack_pressed() and current_weapon != null:
		shoot_weapon()

func update_facing() -> void:
	if velocity.x > 5.0:
		facing = 1
	elif velocity.x < -5.0:
		facing = -1

	if visuals != null:
		visuals.scale.x = facing

func update_aim_line() -> void:
	if aim_line == null:
		return

	var start_point: Vector2 = Vector2(10 * facing, 0)
	var end_point: Vector2 = start_point + aim_dir * aim_length

	aim_line.clear_points()
	aim_line.add_point(start_point)
	aim_line.add_point(end_point)

func update_held_weapon_transform() -> void:
	if weapon_hold == null:
		return

	var target_pos: Vector2 = Vector2(10 * facing, 0) + aim_dir * 8.0
	weapon_hold.position = weapon_hold.position.lerp(target_pos, 0.25)

	if held_weapon_sprite == null:
		return

	var target_angle: float = aim_dir.angle()
	held_weapon_sprite.rotation = lerp_angle(held_weapon_sprite.rotation, target_angle, 0.25)

	if aim_dir.x < 0.0:
		held_weapon_sprite.flip_v = true
	else:
		held_weapon_sprite.flip_v = false

func shoot_weapon() -> void:
	if not can_shoot:
		return
	if current_weapon == null:
		return
	if bullet_scene == null:
		return

	if current_weapon.ammo <= 0:
		print(current_weapon.weapon_name, " click! empty")
		return

	can_shoot = false

	var fire_rate: float = current_weapon.fire_rate
	var bullet_speed: float = current_weapon.bullet_speed
	var damage: int = current_weapon.damage
	var knockback: float = current_weapon.knockback
	var recoil: float = current_weapon.recoil
	var explodes: bool = current_weapon.explodes
	var explosion_radius: float = current_weapon.explosion_radius

	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + aim_dir * 18.0
	bullet.direction = aim_dir
	bullet.speed = bullet_speed
	bullet.damage = damage
	bullet.knockback = knockback
	bullet.owner_player = self
	bullet.explodes = explodes
	bullet.explosion_radius = explosion_radius
	get_parent().add_child(bullet)

	current_weapon.ammo -= 1
	velocity -= aim_dir * recoil

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func can_pickup_weapon() -> bool:
	return current_weapon == null

func pickup_weapon(weapon_data: WeaponData) -> void:
	if current_weapon != null:
		return

	current_weapon = weapon_data.duplicate()
	update_held_weapon_visual()
	print(name, " picked up ", current_weapon.weapon_name)

func throw_weapon() -> void:
	if current_weapon == null:
		return

	if thrown_weapon_scene == null:
		print("No thrown_weapon_scene assigned")
		return

	var thrown_weapon = thrown_weapon_scene.instantiate()
	thrown_weapon.global_position = global_position + aim_dir * 16.0
	thrown_weapon.direction = aim_dir
	thrown_weapon.speed = 1500.0
	thrown_weapon.damage = 8
	thrown_weapon.owner_player = self
	thrown_weapon.weapon_texture = current_weapon.weapon_texture
	thrown_weapon.weapon_scale = current_weapon.weapon_scale

	get_parent().add_child(thrown_weapon)

	print(name, " threw ", current_weapon.weapon_name)

	current_weapon = null
	clear_held_weapon_visual()

func update_held_weapon_visual() -> void:
	if weapon_hold == null:
		return

	clear_held_weapon_visual()

	if current_weapon == null:
		return
	if current_weapon.weapon_texture == null:
		return

	held_weapon_sprite = Sprite2D.new()
	held_weapon_sprite.texture = current_weapon.weapon_texture
	held_weapon_sprite.position = Vector2.ZERO
	held_weapon_sprite.scale = current_weapon.weapon_scale
	weapon_hold.add_child(held_weapon_sprite)

func clear_held_weapon_visual() -> void:
	if held_weapon_sprite != null:
		held_weapon_sprite.queue_free()
		held_weapon_sprite = null

func take_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	if is_dead:
		return

	if is_blocking:
		force *= 0.15
		damage = 0
		return

	health -= damage
	velocity += hit_dir * force

	print(name, " health: ", health)

	if health <= 0:
		is_dead = true
		die()

func reset_for_round() -> void:
	velocity = Vector2.ZERO
	health = max_health
	is_dead = false
	current_weapon = null
	can_shoot = true
	is_blocking = false
	clear_held_weapon_visual()
	aim_dir = Vector2.RIGHT * facing
	update_aim_line()
	setup_colors()
	jumps_left = max_jumps

func die() -> void:
	var gm = get_parent().get_node_or_null("GameManager")
	if gm != null:
		gm.on_player_died(self)

func setup_colors() -> void:
	if body == null:
		return

	var main_color: Color
	var arm_color: Color

	if player_id == 1:
		main_color = Color(0.2, 0.5, 1.0, 1.0)
		arm_color = Color(0.15, 0.38, 0.82, 1.0)
	else:
		main_color = Color(1.0, 0.25, 0.25, 1.0)
		arm_color = Color(0.82, 0.18, 0.18, 1.0)

	body.color = main_color

	if left_arm != null:
		left_arm.color = arm_color
	if right_arm != null:
		right_arm.color = arm_color

func has_controller() -> bool:
	return device_id >= 0 and Input.get_connected_joypads().has(device_id)

func get_move_input() -> float:
	var left_action := "p1_left" if player_id == 1 else "p2_left"
	var right_action := "p1_right" if player_id == 1 else "p2_right"

	var dir: float = Input.get_axis(left_action, right_action)

	if has_controller():
		var joy_dir: float = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
		if abs(joy_dir) > 0.2:
			dir = joy_dir

	return dir

func get_jump_pressed() -> bool:
	var jump_action := "p1_jump" if player_id == 1 else "p2_jump"
	var pressed: bool = Input.is_action_just_pressed(jump_action)

	if has_controller():
		var joy_down: bool = Input.is_joy_button_pressed(device_id, JOY_BUTTON_A)
		var just_pressed: bool = joy_down and not jump_was_down
		jump_was_down = joy_down
		if just_pressed:
			pressed = true
	else:
		jump_was_down = false

	return pressed

func get_block_pressed() -> bool:
	var pressed: bool = false

	if has_controller():
		var lt: float = Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_LEFT)
		var down: bool = lt > 0.35
		var just_pressed: bool = down and not block_pressed_last_frame
		block_pressed_last_frame = down
		if just_pressed:
			pressed = true
	else:
		block_pressed_last_frame = false

	return pressed

func flash_block() -> void:
	var flash_color: Color = Color(0.7, 0.9, 1.0, 1.0)

	if body != null:
		body.color = flash_color
	if left_arm != null:
		left_arm.color = flash_color
	if right_arm != null:
		right_arm.color = flash_color

	block_flash_reset()

func block_flash_reset() -> void:
	await get_tree().create_timer(0.06).timeout
	setup_colors()

func get_attack_pressed() -> bool:
	var attack_action := "p1_attack" if player_id == 1 else "p2_attack"
	var pressed: bool = Input.is_action_just_pressed(attack_action)

	if has_controller():
		var rt: float = Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_RIGHT)
		var down: bool = rt > 0.35
		var just_pressed: bool = down and not attack_was_down
		attack_was_down = down
		if just_pressed:
			pressed = true
	else:
		attack_was_down = false

	return pressed

func get_throw_pressed() -> bool:
	var throw_action := "p1_throw" if player_id == 1 else "p2_throw"
	var pressed: bool = Input.is_action_just_pressed(throw_action)

	if has_controller():
		var down: bool = Input.is_joy_button_pressed(device_id, JOY_BUTTON_RIGHT_SHOULDER)
		var just_pressed: bool = down and not throw_was_down
		throw_was_down = down
		if just_pressed:
			pressed = true
	else:
		throw_was_down = false

	return pressed
