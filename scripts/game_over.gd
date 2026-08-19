extends Node2D

@onready var retry_btn: Button = $CanvasLayer/CenterContainer/VBoxContainer/Button


func _ready() -> void:
	retry_btn.pressed.connect(_on_retry)
	
	


func _on_retry() -> void:
	queue_free()  # game_over 씬 먼저 제거
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")  # 메인 씬 경로로 변경
	
	global.life = 3
	global.checkpoint = Vector2(0, -1)
	global.elapsed_time = 0.0
	
	# 새로 시작하는 판이므로 아이템/보스 관련 상태도 전부 초기화
	global.get_flashlight = false
	global.has_hammer = false
	global.stamina = 100.0
	global.light_charge = 100.0
	global.enemy_enable = false
	global.boss_enable = false
	global.boss_hp = 100.0
	global.hammer_cooldown_left = 0.0
	global.focus_state = false
	global.slowdown = 1
