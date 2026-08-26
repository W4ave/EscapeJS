# 망치가 있어야 부술 수 있는 구조물(장애물)에 붙이는 스크립트.
# Area2D + CollisionShape2D + AnimatedSprite2D 구성으로 사용하세요.
# AnimatedSprite2D의 sprite_frames에는 최소 두 애니메이션이 필요합니다:
#   "idle" : 평소 모습 (첨부 이미지 1번)
#   "near" : 플레이어가 가까이 왔을 때 흰 테두리가 생긴 모습 (첨부 이미지 2번)
extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game = get_tree().current_scene
@onready var col = $StaticBody2D/CollisionShape2D

var is_near := false
var is_broken := false


func _ready() -> void:
	body_entered.connect(_on_entered)
	body_exited.connect(_on_exited)
	input_event.connect(_on_input_event)
	input_pickable = true
	col.disabled = false
	sprite.play("idle")


func _on_entered(body: Node2D) -> void:
	if is_broken or not body.is_in_group("player"):
		return
	is_near = true
	sprite.play("near")


func _on_exited(body: Node2D) -> void:
	if is_broken or not body.is_in_group("player"):
		return
	is_near = false
	sprite.play("idle")


func _on_input_event(_viewport, event, _shape_idx) -> void:
	if is_broken or not is_near:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if global.has_hammer:
			_break()
		else:
			game.show_message1("부술 수 있는 물건을 찾아보자.")


func _break() -> void:
	is_broken = true
	game.shake_camera(6.0, 0.2)
	col.disabled = true
	sprite.play("broken")
