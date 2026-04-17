extends Node
class_name RoomData

@export var allowed_weapons: Array[WeaponData]
@export var pickups_per_round: int = 2
@export var pickup_spawn_delay: float = 1.0
@export var room_gravity_scale: float = 1.0
@export var room_name: String = "Default Room"
