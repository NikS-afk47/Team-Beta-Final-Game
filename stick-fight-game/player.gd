extends CharacterBody2D

@export var player_id: int = 1

@export var move_speed: float = 320.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_force: float = -500.0
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 950.0

@onready var visuals = get_node_or_null("Visuals")
@onready var body = get_node_or_null("Visuals/Body")
@onready var left_arm_pivot = get_node_or_null("Visuals/LeftArmPivot")
@onready var right_arm_pivot = get_node_or_null("Visuals/RightArmPivot")
@onready var left_arm = get_node_or_null("Visuals/LeftArmPivot/LeftArm")
@onready var right_arm = get_node_or_null("Visuals/RightArmPivot/RightArm")

var facing: int = 1

func _ready() -> void:
	setup_player_color()
	set_arm_pose()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement(delta)
	handle_jump()
	update_facing()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed

func handle_movement(delta: float) -> void:
	var left_action := "p1_left" if player_id == 1 else "p2_left"
	var right_action := "p1_right" if player_id == 1 else "p2_right"

	var dir := Input.get_axis(left_action, right_action)

	if dir != 0:
		velocity.x = move_toward(velocity.x, dir * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func handle_jump() -> void:
	var jump_action := "p1_jump" if player_id == 1 else "p2_jump"

	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = jump_force

func update_facing() -> void:
	if velocity.x > 5.0:
		facing = 1
	elif velocity.x < -5.0:
		facing = -1

	if visuals != null:
		visuals.scale.x = facing

func setup_player_color() -> void:
	if body == null:
		push_error("Body missing on " + name)
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

func set_arm_pose() -> void:
	if left_arm_pivot != null:
		left_arm_pivot.rotation = deg_to_rad(-35.0)

	if right_arm_pivot != null:
		right_arm_pivot.rotation = deg_to_rad(35.0)

func reset_for_round() -> void:
	velocity = Vector2.ZERO
	set_arm_pose()

func die() -> void:
	var gm = get_parent().get_node_or_null("GameManager")
	if gm != null:
		gm.on_player_died(self)
