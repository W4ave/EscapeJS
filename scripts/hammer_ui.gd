extends CanvasLayer

@onready var icon: TextureRect = $Control/Icon

var was_ready := true
var icon_pivot_set := false

func _ready() -> void:
	visible = global.has_hammer

func _process(_delta: float) -> void:
	visible = global.has_hammer
	if not visible:
		return

	if not icon_pivot_set:
		icon.pivot_offset = icon.size / 2.0
		icon_pivot_set = true

	var alpha := 1.0
	var is_ready := true
	if global.HAMMER_COOLDOWN_TIME > 0.0:
		alpha = 1.0 - (global.hammer_cooldown_left / global.HAMMER_COOLDOWN_TIME)
		is_ready = global.hammer_cooldown_left <= 0.0
	icon.modulate.a = clamp(alpha, 0.0, 1.0)

	# 쿨타임이 방금 끝난 순간 살짝 커졌다 돌아오는 팝 연출
	if is_ready and not was_ready:
		_pop()
	was_ready = is_ready


func _pop() -> void:
	var tween = create_tween()
	icon.scale = Vector2(1.35, 1.35)
	tween.tween_property(icon, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
