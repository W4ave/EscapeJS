# 계단(Area2D)에 붙이는 스크립트.
# 플레이어가 계단 영역에 들어오면 지정한 위치(다른 층)로 순간이동시킵니다.
extends Area2D

## 인스펙터에서 목적지로 쓸 Marker2D 노드를 지정하세요. (예: 2층 계단 도착 지점에 Marker2D를 놓고 연결)
@export var target_marker: NodePath

## target_marker를 비워두면 이 좌표를 대신 사용합니다. (직접 좌표를 입력하고 싶을 때)
@export var target_position: Vector2 = Vector2.ZERO

## 이 계단을 밟았을 때 global.current_stage 값을 바꾸고 싶으면 설정하세요. (0이면 변경 안 함)
@export var new_stage: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var dest: Vector2 = target_position

	if target_marker != NodePath(""):
		var marker := get_node_or_null(target_marker)
		if marker:
			dest = marker.global_position

	body.global_position = dest

	# CharacterBody2D는 순간이동 직후 기존 속도가 남아있으면 어색하게 튕길 수 있어 초기화
	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO

	if new_stage != 0:
		global.current_stage = new_stage
