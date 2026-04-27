extends Control

@onready var title_label: Label = $TitleLabel
@onready var winner_image: TextureRect = $WinnerImage
@onready var loser_image: TextureRect = $LoserImage
@onready var info_label: Label = $InfoLabel
@onready var return_timer: Timer = $ReturnTimer

var blue_victory: Texture2D = preload("res://Assets/victory blue.png")
var red_victory: Texture2D = preload("res://Assets/victory red.png")
var blue_loss: Texture2D = preload("res://Assets/lose blue.png")
var red_loss: Texture2D = preload("res://Assets/lose red.png")

func _ready() -> void:
	var winner: int = SaveData.last_match_winner

	if winner == 1:
		title_label.text = "BLUE WINS THE MATCH!"
		winner_image.texture = blue_victory
		loser_image.texture = red_loss
	elif winner == 2:
		title_label.text = "RED WINS THE MATCH!"
		winner_image.texture = red_victory
		loser_image.texture = blue_loss
	else:
		title_label.text = "MATCH OVER"
		winner_image.texture = blue_victory
		loser_image.texture = red_loss

	info_label.text = "Returning to the main menu..."
	return_timer.timeout.connect(_on_return_timer_timeout)
	return_timer.start()

func _on_return_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
