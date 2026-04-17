extends Node

var player1_wins: int = 0
var player2_wins: int = 0

const SAVE_PATH := "user://wins.save"

func _ready() -> void:
	load_data()

func add_player1_win() -> void:
	player1_wins += 1
	save_data()

func add_player2_win() -> void:
	player2_wins += 1
	save_data()

func save_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to save data.")
		return

	var data = {
		"player1_wins": player1_wins,
		"player2_wins": player2_wins
	}

	file.store_var(data)
	file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting fresh.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("Failed to load data.")
		return

	var data = file.get_var()
	file.close()

	if data.has("player1_wins"):
		player1_wins = data["player1_wins"]

	if data.has("player2_wins"):
		player2_wins = data["player2_wins"]

func reset_data() -> void:
	player1_wins = 0
	player2_wins = 0
	save_data()
