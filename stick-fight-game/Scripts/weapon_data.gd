extends Resource
class_name WeaponData

@export var weapon_name: String = "Pistol"
@export var ammo: int = 8
@export var damage: int = 10
@export var bullet_speed: float = 900.0
@export var fire_rate: float = 0.2
@export var recoil: float = 120.0
@export var knockback: float = 250.0

@export var explodes: bool = false
@export var explosion_radius: float = 0.0
@export var explosion_scene: PackedScene

@export var weapon_texture: Texture2D
@export var weapon_scale: Vector2 = Vector2(0.2, 0.2)

@export var is_grenade: bool = false
@export var grenade_scene: PackedScene
@export var throw_force: float = 700.0
@export var fuse_time: float = 2.0
