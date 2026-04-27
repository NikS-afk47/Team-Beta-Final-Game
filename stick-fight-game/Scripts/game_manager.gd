extends Node

@export var left_elevator_path: NodePath
@export var right_elevator_path: NodePath
@export var player1_path: NodePath
@export var player2_path: NodePath
@export var room_holder_path: NodePath

@onready var left_elevator = get_node(left_elevator_path)
@onready var right_elevator = get_node(right_elevator_path)
@onready var player1 = get_node(player1_path)
@onready var player2 = get_node(player2_path)
@onready var room_holder = get_node(room_holder_path)

@export var weapon_pickup_scene: PackedScene
@export var possible_weapons: Array[WeaponData]
@export var pickups_per_round: int = 2
@export var room_scenes: Array[PackedScene]

@export var wins_needed: int = 5
@export var round_start_delay: float = 1.0
@export var round_end_delay: float = 1.0
@export var pickup_fall_height: float = 200.0
@export var pickup_spawn_delay: float = 1.0

var current_room: Node = null
var current_room_data: Node = null

var round_over: bool = false
var match_over: bool = false
var game_over: bool = false

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
	clear_black_holes()
	clear_old_thrown_weapons()

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

	call_deferred("spawn_weapons_with_delay")

	print("Round start")
	print("Score: P1 ", p1_score, " - P2 ", p2_score)

	if current_room_data != null and "room_name" in current_room_data:
		print("Room: ", current_room_data.room_name)

func load_random_room() -> void:
	if current_room != null:
		current_room.queue_free()
		current_room = null
		current_room_data = null

	if room_scenes.is_empty():
		push_error("No room scenes assigned in GameManager")
		return

	var room_index: int = randi() % room_scenes.size()
	var room_scene: PackedScene = room_scenes[room_index]
	current_room = room_scene.instantiate()
	room_holder.add_child(current_room)

	current_room_data = current_room.get_node_or_null("RoomData")

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

func spawn_weapons_with_delay() -> void:
	var delay: float = pickup_spawn_delay

	if current_room_data != null and "pickup_spawn_delay" in current_room_data:
		delay = current_room_data.pickup_spawn_delay

	await get_tree().create_timer(delay).timeout

	if match_over:
		return

	spawn_random_weapons()

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
	for child: Node in item_spawns.get_children():
		spawn_points.append(child)

	if spawn_points.is_empty():
		print("No spawn markers in ItemSpawns")
		return

	spawn_points.shuffle()

	var local_pickups_per_round: int = pickups_per_round
	var weapon_pool: Array[WeaponData] = possible_weapons

	if current_room_data != null:
		if "pickups_per_round" in current_room_data:
			local_pickups_per_round = current_room_data.pickups_per_round

		if "allowed_weapons" in current_room_data:
			if not current_room_data.allowed_weapons.is_empty():
				weapon_pool = current_room_data.allowed_weapons

	if weapon_pool.is_empty():
		print("Weapon pool is empty")
		return

	var spawn_count: int = mini(local_pickups_per_round, spawn_points.size())

	for i: int in range(spawn_count):
		var spawn_marker: Node = spawn_points[i]
		var pickup: Node = weapon_pickup_scene.instantiate()

		if pickup == null:
			continue

		var random_weapon: WeaponData = weapon_pool[randi() % weapon_pool.size()]
		pickup.weapon_data = random_weapon

		var spawn_pos: Vector2 = spawn_marker.global_position + Vector2(0, -pickup_fall_height)

		get_parent().call_deferred("add_child", pickup)
		pickup.set_deferred("global_position", spawn_pos)

		if pickup is RigidBody2D:
			(pickup as RigidBody2D).set_deferred("linear_velocity", Vector2(randf_range(-40.0, 40.0), 0.0))
			(pickup as RigidBody2D).set_deferred("angular_velocity", randf_range(-3.0, 3.0))


func clear_old_weapon_pickups() -> void:
	for pickup in get_tree().get_nodes_in_group("weapon_pickups"):
		pickup.queue_free()
		
func clear_old_thrown_weapons() -> void:
	for thrown in get_tree().get_nodes_in_group("thrown_weapons"):
		thrown.queue_free()
func end_game(winner: int) -> void:
	if game_over:
		return

	game_over = true
	SaveData.last_match_winner = winner

	if winner == 1:
		SaveData.add_player1_win()
	elif winner == 2:
		SaveData.add_player2_win()

	print("Player ", winner, " wins the match!")

	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/final_victory_scene.tscn")
func clear_black_holes() -> void:
	for hole in get_tree().get_nodes_in_group("black_holes"):
		hole.queue_free()
