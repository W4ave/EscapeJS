# CheckPoint2 전용 스크립트.
# 기본 체크포인트 기능(리스폰 위치 저장)에 더해,
# story_legblock(스토리 다리 오브젝트)의 콜리전/visible을 켜고
# 플레이어의 CircleFlashlight(서클 라이트)를 꺼줍니다.
extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# 기본 체크포인트 동작: 리스폰 위치 갱신
	global.checkpoint = global_position

	_enable_story_leg()
	_turn_off_circle_light(body)


func _enable_story_leg() -> void:
	var boss = get_tree().current_scene.get_node_or_null("BossSquid")
	if not boss:
		return

	var leg_sprite = boss.get_node_or_null("story_legblock")
	if leg_sprite:
		leg_sprite.visible = true

	var leg_collision = boss.get_node_or_null("CollisionShape2D")
	if leg_collision:
		leg_collision.set_deferred("disabled", false)   # 수정


func _turn_off_circle_light(body: Node2D) -> void:
	var circle_light = body.get_node_or_null("CircleFlashlight")
	if circle_light:
		circle_light.visible = false
