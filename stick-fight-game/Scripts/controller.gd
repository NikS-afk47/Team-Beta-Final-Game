extends Node2D

@export var player_id: int = 1

@export var torso: RigidBody2D
@export var head: RigidBody2D
@export var arm_l: RigidBody2D
@export var arm_r: RigidBody2D
@export var leg_l: RigidBody2D
@export var leg_r: RigidBody2D

@export var foot_sensor_l: Area2D
@export var foot_sensor_r: Area2D

@export var move_force: float = 2200.0
@export var jump_impulse: float = 420.0
@export var air_control: float = 0.45
@export var upright_force: float = 900.0
@export var max_speed: float = 260.0

var torso_start: Vector2
var head_start: Vector2
var arm_l_start: Vector2
var arm_r_start: Vector2
var leg_l_start: Vector2
var leg_r_start: Vector2

func _ready() -> void:
	if torso != null:
		torso_start = torso.position
	if head != null:
		head_start = head.position
	if arm_l != null:
		arm_l_start = arm_l.position
	if arm_r != null:
		arm_r_start = arm_r.position
	if leg_l != null:
		leg_l_start = leg_l.position
	if leg_r != null:
		leg_r_start = leg_r.position

func _physics_process(_delta: float) -> void:
	if torso == null:
		return

	var left_action := "p1_left" if player_id == 1 else "p2_left"
	var right_action := "p1_right" if player_id == 1 else "p2_right"
	var jump_action := "p1_jump" if player_id == 1 else "p2_jump"

	var dir: float = Input.get_axis(left_action, right_action)
	var grounded := is_grounded()
	var control := 1.0 if grounded else air_control

	if dir != 0.0:
		torso.apply_central_force(Vector2(dir * move_force * control, 0.0))
		torso.apply_torque(dir * 1400.0 * control)

		if leg_l != null:
			leg_l.apply_central_force(Vector2(dir * move_force * 0.25 * control, 0.0))
		if leg_r != null:
			leg_r.apply_central_force(Vector2(dir * move_force * 0.25 * control, 0.0))

	if abs(torso.linear_velocity.x) > max_speed:
		torso.linear_velocity.x = sign(torso.linear_velocity.x) * max_speed

	if Input.is_action_just_pressed(jump_action) and grounded:
		torso.apply_central_impulse(Vector2(0.0, -jump_impulse))

	# helps torso stay upright-ish
	torso.apply_torque(-torso.rotation * upright_force)

func is_grounded() -> bool:
	if foot_sensor_l != null and foot_sensor_l.has_overlapping_bodies():
		return true
	if foot_sensor_r != null and foot_sensor_r.has_overlapping_bodies():
		return true
	return false

func reset_for_round() -> void:
	if torso != null:
		torso.position = torso_start
		torso.linear_velocity = Vector2.ZERO
		torso.angular_velocity = 0.0
		torso.rotation = 0.0

	if head != null:
		head.position = head_start
		head.linear_velocity = Vector2.ZERO
		head.angular_velocity = 0.0
		head.rotation = 0.0

	if arm_l != null:
		arm_l.position = arm_l_start
		arm_l.linear_velocity = Vector2.ZERO
		arm_l.angular_velocity = 0.0
		arm_l.rotation = 0.0

	if arm_r != null:
		arm_r.position = arm_r_start
		arm_r.linear_velocity = Vector2.ZERO
		arm_r.angular_velocity = 0.0
		arm_r.rotation = 0.0

	if leg_l != null:
		leg_l.position = leg_l_start
		leg_l.linear_velocity = Vector2.ZERO
		leg_l.angular_velocity = 0.0
		leg_l.rotation = 0.0

	if leg_r != null:
		leg_r.position = leg_r_start
		leg_r.linear_velocity = Vector2.ZERO
		leg_r.angular_velocity = 0.0
		leg_r.rotation = 0.0

func die() -> void:
	var gm = get_parent().get_node_or_null("GameManager")
	if gm != null:
		gm.on_player_died(self)
