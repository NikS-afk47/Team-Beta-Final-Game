extends Control

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")	

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
