extends Area2D


func _ready() -> void:
	# 플레이어 같은 물리 오브젝트가 들어왔을 때 감지
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		global.checkpoint = global_position
