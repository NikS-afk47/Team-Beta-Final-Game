extends Node2D

@onready var spawn_point = get_node_or_null("SpawnPoint")

@onready var door = get_node_or_null("Door")
@onready var left_frame = get_node_or_null("LeftFrame")
@onready var right_frame = get_node_or_null("RightFrame")

@onready var left_wall_shape = get_node_or_null("LeftWallCollider/CollisionShape2D")
@onready var right_wall_shape = get_node_or_null("RightWallCollider/CollisionShape2D")

var door_closed_pos: Vector2
var door_open_pos: Vector2

var left_closed_pos: Vector2
var left_open_pos: Vector2

var right_closed_pos: Vector2
var right_open_pos: Vector2

@export var open_height: float = 120.0
@export var move_time: float = 0.35

func _ready() -> void:
	if door != null:
		door_closed_pos = door.position
		door_open_pos = door_closed_pos + Vector2(0, -open_height)

	if left_frame != null:
		left_closed_pos = left_frame.position
		left_open_pos = left_closed_pos + Vector2(0, -open_height)

	if right_frame != null:
		right_closed_pos = right_frame.position
		right_open_pos = right_closed_pos + Vector2(0, -open_height)

	close_elevator_instant()

func open_elevator() -> void:
	if left_wall_shape != null:
		left_wall_shape.disabled = true
	if right_wall_shape != null:
		right_wall_shape.disabled = true

	var tween = create_tween()

	if door != null:
		tween.parallel().tween_property(door, "position", door_open_pos, move_time)

	if left_frame != null:
		tween.parallel().tween_property(left_frame, "position", left_open_pos, move_time)

	if right_frame != null:
		tween.parallel().tween_property(right_frame, "position", right_open_pos, move_time)

func close_elevator() -> void:
	if left_wall_shape != null:
		left_wall_shape.disabled = false
	if right_wall_shape != null:
		right_wall_shape.disabled = false

	var tween = create_tween()

	if door != null:
		tween.parallel().tween_property(door, "position", door_closed_pos, move_time)

	if left_frame != null:
		tween.parallel().tween_property(left_frame, "position", left_closed_pos, move_time)

	if right_frame != null:
		tween.parallel().tween_property(right_frame, "position", right_closed_pos, move_time)

func close_elevator_instant() -> void:
	if door != null:
		door.position = door_closed_pos

	if left_frame != null:
		left_frame.position = left_closed_pos

	if right_frame != null:
		right_frame.position = right_closed_pos

	if left_wall_shape != null:
		left_wall_shape.disabled = false
	if right_wall_shape != null:
		right_wall_shape.disabled = false

func open_elevator_instant() -> void:
	if door != null:
		door.position = door_open_pos

	if left_frame != null:
		left_frame.position = left_open_pos

	if right_frame != null:
		right_frame.position = right_open_pos

	if left_wall_shape != null:
		left_wall_shape.disabled = true
	if right_wall_shape != null:
		right_wall_shape.disabled = true

func get_spawn_position() -> Vector2:
	if spawn_point != null:
		return spawn_point.global_position
	return global_position + Vector2(0, 60)
