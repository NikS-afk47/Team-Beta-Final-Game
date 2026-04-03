extends CharacterBody2D

@export var player_id: int = 1

@export var move_speed: float = 250.0
@export var jump_force: float = -450.0
@export var gravity: float = 1000.0
@export var max_fall_speed: float = 900.0

@onready var body = get_node_or_null("Body")

func _ready() -> void:
	setup_player_color()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement()
	handle_jump()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed

func handle_movement() -> void:
	var left_action := "p1_left" if player_id == 1 else "p2_left"
	var right_action := "p1_right" if player_id == 1 else "p2_right"

	var dir = Input.get_axis(left_action, right_action)
	velocity.x = dir * move_speed

func handle_jump() -> void:
	var jump_action := "p1_jump" if player_id == 1 else "p2_jump"

	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = jump_force

func setup_player_color() -> void:
	if body == null:
		push_error("Body missing on " + name)
		return

	if player_id == 1:
		body.color = Color(0.2, 0.5, 1.0, 1.0)
	else:
		body.color = Color(1.0, 0.25, 0.25, 1.0)

func reset_for_round() -> void:
	velocity = Vector2.ZERO

func die() -> void:
	var gm = get_parent().get_node_or_null("GameManager")
	if gm != null:
		gm.on_player_died(self)
