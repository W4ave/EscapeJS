# 보스방 입구에 두는 트리거용 스크립트. (Area2D에 부착)
# 플레이어가 처음 들어올 때만 조작법 안내 UI를 띄웁니다.
extends Area2D

const BossIntroUI = preload("res://scenes/boss_intro_ui.tscn")

var already_shown := false


func _ready() -> void:
	
	body_entered.connect(_on_body_entered)
	already_shown = false

func _on_body_entered(body: Node2D) -> void:
	if already_shown or not body.is_in_group("player"):
		return
	if global.boss_enable:
		return
	already_shown = true
	var ui = BossIntroUI.instantiate()
	get_tree().root.add_child(ui)
