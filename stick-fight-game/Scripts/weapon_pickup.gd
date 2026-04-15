extends Area2D

@export var weapon_data: WeaponData

@onready var sprite = $Visuals/Sprite2D

var bob_time: float = 0.0
var start_y: float = 0.0

func _ready() -> void:
	if weapon_data != null and weapon_data.weapon_texture != null:
		sprite.texture = weapon_data.weapon_texture

	start_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	bob_time += delta

	position.y = start_y + sin(bob_time * 3.0) * 4.0

	var flip = abs(sin(bob_time * 4.0))
	$Visuals.scale.x = max(flip, 0.2)

func _on_body_entered(body: Node) -> void:
	if weapon_data == null:
		return

	if body.has_method("pickup_weapon"):
		body.pickup_weapon(weapon_data)
		queue_free()
