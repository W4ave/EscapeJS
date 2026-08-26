# 보스전 시작 전 조작법 안내 UI.
# 트리거(Area2D)에서 이 씬을 instantiate해서 띄우고,
# "시작하기"를 눌러야 게임이 다시 진행되고 보스가 활성화됩니다.
extends CanvasLayer

@onready var start_button: Button = $Control/Panel/VBoxContainer/StartButton


func _ready() -> void:
	get_tree().paused = true                      # 안내 보는 동안 게임 정지
	process_mode = Node.PROCESS_MODE_ALWAYS        # 일시정지 중에도 이 UI는 동작해야 함
	start_button.pressed.connect(_on_start_pressed)
	start_button.grab_focus()


func _on_start_pressed() -> void:
	get_tree().paused = false
	global.boss_enable = true
	queue_free()
