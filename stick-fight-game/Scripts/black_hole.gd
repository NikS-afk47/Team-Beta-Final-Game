extends Node2D

@export var pull_force: float = 2200.0
@export var max_pull_force: float = 5000.0

@export var start_visual_scale: float = 0.4
@export var max_visual_scale: float = 2.4
@export var visual_grow_speed: float = 0.8

@export var start_pull_radius: float = 180.0
@export var max_pull_radius: float = 900.0
@export var pull_grow_speed: float = 220.0

@export var start_kill_radius: float = 40.0
@export var max_kill_radius: float = 220.0
@export var kill_grow_speed: float = 60.0

@onready var pull_area = $PullArea
@onready var pull_shape = $PullArea/CollisionShape2D
@onready var kill_zone = $KillZone
@onready var kill_shape = $KillZone/CollisionShape2D

@onready var core = $Core


var players_in_range: Array[Node] = []

var current_visual_scale: float = 1.0
var current_pull_radius: float = 0.0
var current_kill_radius: float = 0.0
var current_pull_force: float = 0.0

var t: float = 0.0

func _ready() -> void:
	add_to_group("black_holes")

	current_visual_scale = start_visual_scale
	current_pull_radius = start_pull_radius
	current_kill_radius = start_kill_radius
	current_pull_force = pull_force

	_update_pull_radius()
	_update_kill_radius()
	_update_visuals()

	if not pull_area.body_entered.is_connected(_on_pull_area_body_entered):
		pull_area.body_entered.connect(_on_pull_area_body_entered)

	if not pull_area.body_exited.is_connected(_on_pull_area_body_exited):
		pull_area.body_exited.connect(_on_pull_area_body_exited)

	if not kill_zone.body_entered.is_connected(_on_kill_zone_body_entered):
		kill_zone.body_entered.connect(_on_kill_zone_body_entered)

func _process(delta: float) -> void:
	t += delta

	current_visual_scale = minf(current_visual_scale + visual_grow_speed * delta, max_visual_scale)
	current_pull_radius = minf(current_pull_radius + pull_grow_speed * delta, max_pull_radius)
	current_kill_radius = minf(current_kill_radius + kill_grow_speed * delta, max_kill_radius)

	var force_ratio: float = inverse_lerp(start_pull_radius, max_pull_radius, current_pull_radius)
	current_pull_force = lerpf(pull_force, max_pull_force, force_ratio)

	_update_pull_radius()
	_update_kill_radius()
	_update_visuals()

func _physics_process(delta: float) -> void:
	for player in players_in_range:
		if player == null:
			continue

		var to_center: Vector2 = global_position - player.global_position
		var dist: float = to_center.length()

		if dist <= 0.001:
			continue

		if dist > current_pull_radius:
			continue

		var dir: Vector2 = to_center.normalized()
		var strength_scale: float = 1.0 - (dist / current_pull_radius)

		# makes outer edge still pull a bit
		var final_force: float = current_pull_force * (0.35 + strength_scale)

		if "velocity" in player:
			player.velocity += dir * final_force * delta

func _update_pull_radius() -> void:
	var circle := pull_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = current_pull_radius

func _update_kill_radius() -> void:
	var circle := kill_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = current_kill_radius

func _update_visuals() -> void:
	if core != null:
		core.scale = Vector2(current_visual_scale, current_visual_scale)
		core.rotation += 0.02

		var pulse: float = 1.0 + sin(t * 5.0) * 0.08

func _on_pull_area_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		if not players_in_range.has(body):
			players_in_range.append(body)

func _on_pull_area_body_exited(body: Node) -> void:
	if players_in_range.has(body):
		players_in_range.erase(body)

func _on_kill_zone_body_entered(body: Node) -> void:
	if body.has_method("die"):
		body.die()
