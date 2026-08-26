# 특정 위치(Area2D)에 플레이어가 들어오면 대사를 띄우는 트리거.
# 사용법:
#   1. 대사를 띄우고 싶은 위치에 Area2D 노드를 만들고 CollisionShape2D를 자식으로 추가
#   2. 이 스크립트를 그 Area2D에 붙임
#   3. 인스펙터에서 lines 배열에 대사를 순서대로 입력
extends Area2D

@export var lines: Array[String] = []
@export var one_shot: bool = true   # true면 한 번 트리거된 후 다시 발동하지 않음

@onready var game = get_tree().current_scene

var triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if one_shot and triggered:
		return

	triggered = true
	game.show_dialogue1(lines)

	if one_shot:
		# 콜리전만 꺼서 다시 겹쳐도 재발동하지 않게 함 (노드 자체는 유지)
		set_deferred("monitoring", false)
