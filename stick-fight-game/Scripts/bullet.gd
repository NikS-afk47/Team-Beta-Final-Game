extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 900.0
var damage: int = 10
var knockback: float = 250.0
var owner_player: Node = null
var explodes: bool = false
var explosion_radius: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction.normalized() * speed * delta

func _on_body_entered(body: Node) -> void:
	if body == owner_player:
		return

	if body.has_method("take_hit"):
		body.take_hit(direction.normalized(), damage, knockback)

	# explosion placeholder
	if explodes:
		print("explode here radius: ", explosion_radius)

	queue_free()
