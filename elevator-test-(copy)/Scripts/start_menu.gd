extends Control

@onready var play_button = $PlayButton
@onready var exit_button = $ExitButton
@onready var player1_label = $Player1Label
@onready var player2_label = $Player2Label

func _ready() -> void:
	update_win_labels()

	play_button.pressed.connect(_on_play_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func update_win_labels() -> void:
	player1_label.text = "Player 1\nWins: " + str(SaveData.player1_wins)
	player2_label.text = "Player 2\nWins: " + str(SaveData.player2_wins)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
