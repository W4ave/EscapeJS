# 특정 위치(Area2D)에 플레이어가 들어오면 대사를 띄우는 트리거.
# enemy_enable이 false인 동안은 체크포인트로 되돌려보내면서 힌트 대사(hint_lines)를 띄움.
# enemy_enable이 true가 된 이후에는 대사 없이 그냥 통과시킴.
extends Area2D

@export var hint_lines: Array[String] = []   # 체크포인트로 돌아갈 때 보여줄 대사 (예: "말을 걸어보자")

@onready var game = get_tree().current_scene
@onready var player = $"../Player"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if not global.enemy_enable:
		# 아직 조건이 안 됐으면 체크포인트로 되돌려보내면서 힌트 대사를 띄움
		player.global_position = global.checkpoint
		if not hint_lines.is_empty():
			game.show_dialogue1(hint_lines)
		return

	# enable된 이후에는 대사 없이 그냥 통과
