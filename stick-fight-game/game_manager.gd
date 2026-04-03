extends Node

@onready var left_elevator = $"../LeftElevator"
@onready var right_elevator = $"../RightElevator"
@onready var player1 = $"../Player1"
@onready var player2 = $"../Player2"

var round_over: bool = false
var match_over: bool = false

var p1_score: int = 0
var p2_score: int = 0

@export var wins_needed: int = 3
@export var round_start_delay: float = 1.0
@export var round_end_delay: float = 1.0

func _ready() -> void:
	start_round()

func start_round() -> void:
	if match_over:
		return

	round_over = false

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
	elif p2_score >= wins_needed:
		match_over = true
		print("PLAYER 2 WINS THE MATCH")
