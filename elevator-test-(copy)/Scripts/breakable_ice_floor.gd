extends StaticBody2D

@export var friction_mult: float = 0.15
@export var respawn_time: float = 2.0

@onready var sprite = get_node_or_null("Sprite2D")
@onready var collision = $CollisionShape2D

var broken: bool = false

func break_ice() -> void:
	if broken:
		return

	broken = true

	if collision != null:
		collision.set_deferred("disabled", true)

	if sprite != null:
		sprite.visible = false

	await get_tree().create_timer(respawn_time).timeout

	broken = false

	if collision != null:
		collision.set_deferred("disabled", false)

	if sprite != null:
		sprite.visible = true
