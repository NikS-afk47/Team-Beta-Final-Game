extends RigidBody2D

@export var weapon_data: WeaponData
@export var idle_bob_amount: float = 4.0
@export var idle_bob_speed: float = 3.0
@export var fake_spin_speed: float = 4.0

@onready var sprite = $Visuals/Sprite2D
@onready var pickup_area = $PickupArea

var bob_time: float = 0.0
var idle_start_y: float = 0.0
var landed: bool = false

func _ready() -> void:
	if weapon_data != null and weapon_data.weapon_texture != null:
		sprite.texture = weapon_data.weapon_texture
		sprite.scale = weapon_data.weapon_scale

	if not pickup_area.body_entered.is_connected(_on_pickup_area_body_entered):
		pickup_area.body_entered.connect(_on_pickup_area_body_entered)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if landed:
		bob_time += delta
		position.y = idle_start_y + sin(bob_time * idle_bob_speed) * idle_bob_amount

		var flip: float = abs(sin(bob_time * fake_spin_speed))
		$Visuals.scale.x = maxf(flip, 0.2)

func _on_body_entered(body: Node) -> void:
	if landed:
		return

	if body != null:
		landed = true
		freeze = true
		idle_start_y = position.y

func _on_pickup_area_body_entered(body: Node) -> void:
	if weapon_data == null:
		return

	if body.has_method("pickup_weapon") and body.has_method("can_pickup_weapon"):
		if body.can_pickup_weapon():
			body.pickup_weapon(weapon_data)
			queue_free()
