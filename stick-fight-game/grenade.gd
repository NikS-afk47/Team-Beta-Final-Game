extends RigidBody2D

var damage: int = 100
var knockback: float = 700.0
var explosion_radius: float = 200.0
var explosion_scene: PackedScene = null
var fuse_time: float = 2.0

@onready var fuse_timer = $FuseTimer

func _ready() -> void:
	fuse_timer.wait_time = fuse_time
	fuse_timer.start()

	if not fuse_timer.timeout.is_connected(_on_fuse_timeout):
		fuse_timer.timeout.connect(_on_fuse_timeout)

func _on_fuse_timeout() -> void:
	explode()

func explode() -> void:
	print("GRENADE EXPLODE")

	if explosion_scene != null:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		explosion.damage = damage
		explosion.knockback = knockback
		explosion.explosion_radius = explosion_radius
		get_parent().add_child(explosion)
	else:
		print("NO explosion_scene assigned")

	queue_free()
