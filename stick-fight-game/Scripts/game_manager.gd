extends Node

@onready var left_elevator = $"../LeftElevator"
@onready var right_elevator = $"../RightElevator"
@onready var player1 = $"../Player1"
@onready var player2 = $"../Player2"
@onready var room_holder = $"../RoomHolder"

@export var weapon_pickup_scene: PackedScene
@export var possible_weapons: Array[WeaponData]
@export var pickups_per_round: int = 2
@export var room_scenes: Array[PackedScene]

@export var wins_needed: int = 3
@export var round_start_delay: float = 1.0
@export var round_end_delay: float = 1.0
@export var pickup_fall_height: float = 200.0

var current_room: Node = null

var round_over: bool = false
var match_over: bool = false
var game_over := false

var p1_score: int = 0
var p2_score: int = 0

func _ready() -> void:
	randomize()
	game_over = false
	start_round()

func start_round() -> void:
	if match_over:
		return

	round_over = false

	load_random_room()
	clear_old_weapon_pickups()
	call_deferred("spawn_random_weapons")

	player1.global_position = left_elevator.get_spawn_position()
	player2.global_position = right_elevator.get_spawn_position()

	player1.reset_for_round()
	player2.reset_for_round()

	left_elevator.close_elevator_instant()
	right_elevator.close_elevator_instant()

	await get_tree().create_timer(round_start_delay).timeout

	if match_over:
		return

	left_elevator.open_elevator()
	right_elevator.open_elevator()

	print("Round start")
	print("Score: P1 ", p1_score, " - P2 ", p2_score)

func load_random_room() -> void:
	if current_room != null:
		current_room.queue_free()
		current_room = null

	if room_scenes.is_empty():
		push_error("No room scenes assigned in GameManager")
		return

	var room_index: int = randi() % room_scenes.size()
	current_room = room_scenes[room_index].instantiate()
	room_holder.add_child(current_room)

func on_player_died(dead_player: Node) -> void:
	if round_over or match_over:
		return

	round_over = true

	if dead_player == player1:
		p2_score += 1
		print("Player 2 wins the round")
	elif dead_player == player2:
		p1_score += 1
		print("Player 1 wins the round")

	print("Score: P1 ", p1_score, " - P2 ", p2_score)

	check_match_win()

	if match_over:
		return

	await get_tree().create_timer(round_end_delay).timeout
	start_round()

func check_match_win() -> void:
	if p1_score >= wins_needed:
		match_over = true
		print("PLAYER 1 WINS THE MATCH")
		end_game(1)

	elif p2_score >= wins_needed:
		match_over = true
		print("PLAYER 2 WINS THE MATCH")
		end_game(2)


func spawn_random_weapons() -> void:
	if current_room == null:
		return
	if weapon_pickup_scene == null:
		print("No weapon_pickup_scene assigned")
		return
	if possible_weapons.is_empty():
		print("No possible_weapons assigned")
		return

	var item_spawns: Node = current_room.get_node_or_null("ItemSpawns")
	if item_spawns == null:
		print("Room has no ItemSpawns node")
		return

	var spawn_points: Array[Node] = []
	for child in item_spawns.get_children():
		spawn_points.append(child)

	if spawn_points.is_empty():
		print("No spawn markers in ItemSpawns")
		return

	spawn_points.shuffle()

	var spawn_count: int = mini(pickups_per_round, spawn_points.size())

	for i: int in range(spawn_count):
		var spawn_marker: Node = spawn_points[i]
		var pickup = weapon_pickup_scene.instantiate()

		if pickup == null:
			continue

		var random_weapon: WeaponData = possible_weapons[randi() % possible_weapons.size()]
		pickup.weapon_data = random_weapon

		var spawn_pos: Vector2 = spawn_marker.global_position + Vector2(0, -pickup_fall_height)

		get_parent().call_deferred("add_child", pickup)
		pickup.set_deferred("global_position", spawn_pos)

		if pickup is RigidBody2D:
			pickup.set_deferred("linear_velocity", Vector2(randf_range(-40.0, 40.0), 0.0))
			pickup.set_deferred("angular_velocity", randf_range(-3.0, 3.0))

func clear_old_weapon_pickups() -> void:
	for child in get_parent().get_children():
		if child.name == "WeaponPickup":
			child.queue_free()

func end_game(winner: int) -> void:
	if game_over:
		return  # prevents multiple triggers

	game_over = true

	if winner == 1:
		SaveData.add_player1_win()
	elif winner == 2:
		SaveData.add_player2_win()

	print("Player ", winner, " wins!")

	await get_tree().create_timer(1.5).timeout

	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
