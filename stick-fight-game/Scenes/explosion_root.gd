extends Node2D

@export var damage: int = 100
@export var knockback: float = 700.0
@export var explosion_radius: float = 200.0
@export var life_time: float = 0.3

@onready var particles = $CPUParticles2D
@onready var hit_area = $Area2D
@onready var hit_shape = $Area2D/CollisionShape2D

var hit_bodies: Array[Node] = []

func _ready() -> void:
	var circle := hit_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = explosion_radius

	if particles != null:
		particles.emitting = false
		particles.restart()
		particles.emitting = true

	if not hit_area.body_entered.is_connected(_on_body_entered):
		hit_area.body_entered.connect(_on_body_entered)

	call_deferred("_hit_existing_bodies")

	await get_tree().create_timer(life_time).timeout
	queue_free()

func _hit_existing_bodies() -> void:
	await get_tree().physics_frame

	for body in hit_area.get_overlapping_bodies():
		_try_hit(body)

func _on_body_entered(body: Node) -> void:
	_try_hit(body)

func _try_hit(body: Node) -> void:
	if body == null:
		return
	if hit_bodies.has(body):
		return

	hit_bodies.append(body)

	if body.has_method("take_hit"):
		var dir: Vector2 = body.global_position - global_position
		if dir.length() <= 0.001:
			dir = Vector2.UP
		else:
			dir = dir.normalized()

		print("Explosion hit:", body.name)
		body.take_hit(dir, damage, knockback)
