extends Node2D

@onready var retry_btn: Button = $CanvasLayer/CenterContainer/VBoxContainer/Button


func _ready() -> void:
	retry_btn.pressed.connect(_on_retry)
	
	


func _on_retry() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")  # 메인 씬 경로로 변경
	
	global.life = 3
