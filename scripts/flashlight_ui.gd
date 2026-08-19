extends CanvasLayer

@onready var icon: TextureRect = $Control/Icon

var was_visible := false
var icon_pivot_set := false

func _ready() -> void:
	visible = global.get_flashlight

func _process(_delta: float) -> void:
	visible = global.get_flashlight
	if not visible:
		was_visible = false
		return

	if not icon_pivot_set:
		icon.pivot_offset = icon.size / 2.0
		icon_pivot_set = true

	# 방금 손전등을 얻은 순간에만 팝 연출
	if not was_visible:
		_pop()
	was_visible = true


func _pop() -> void:
	var tween = create_tween()
	icon.scale = Vector2(1.5, 1.5)
	icon.modulate = Color(1.3, 1.3, 0.9)
	tween.set_parallel(true)
	tween.tween_property(icon, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "modulate", Color.WHITE, 0.4)
