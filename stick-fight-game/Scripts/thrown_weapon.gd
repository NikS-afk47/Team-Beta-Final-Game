extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 550.0
var damage: int = 8
var owner_player: Node = null
var weapon_texture: Texture2D = null
var weapon_scale: Vector2 = Vector2(0.2, 0.2)

@export var fall_gravity: float = 900.0
var velocity: Vector2 = Vector2.ZERO

@onready var sprite = $Sprite2D

func _ready() -> void:
	if weapon_texture != null:
		sprite.texture = weapon_texture
		sprite.scale = weapon_scale

	velocity = direction.normalized() * speed

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	velocity.y += fall_gravity * delta
	global_position += velocity * delta
	rotation += delta * 12.0

func _on_body_entered(body: Node) -> void:
	if body == owner_player:
		return

	if body.has_method("take_hit"):
		body.take_hit(direction.normalized(), damage, 180.0)

	queue_free()
