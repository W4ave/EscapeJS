# Area2D 에 붙이는 스크립트
extends Area2D

func _ready() -> void:
	# 플레이어 같은 물리 오브젝트가 들어왔을 때 감지
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# 보스가 아직 활성화된 상태(전투 중)라면 클리어 판정이 나지 않게 막기
	if global.boss_enable:
		return

	# 타이머 노드 가져와서 클리어 처리
	get_tree().current_scene.get_node("Timer").on_game_clear()
