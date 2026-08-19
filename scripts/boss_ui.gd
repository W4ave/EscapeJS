extends CanvasLayer

@onready var bar = $ProgressBar
@onready var label = $Label

var displayed_hp : float = 100.0
var flash_timer : float = 0.0
const FLASH_DURATION = 0.15

func _ready() -> void:
	visible = false
	displayed_hp = global.boss_hp
	label.pivot_offset = label.size / 2.0


func _process(delta: float) -> void:
	if global.boss_enable:
		visible = true

	var target = global.boss_hp

	# 목표치가 줄어드는 순간을 감지해서 짧은 하얀 플래시 + 흔들림 연출
	if target < displayed_hp - 0.01:
		flash_timer = FLASH_DURATION
		_pop_label()

	displayed_hp = lerp(displayed_hp, target, clamp(delta * 8.0, 0.0, 1.0))
	bar.value = displayed_hp

	if flash_timer > 0.0:
		flash_timer -= delta
		var t = clamp(flash_timer / FLASH_DURATION, 0.0, 1.0)
		bar.modulate = Color.WHITE.lerp(Color(2.2, 2.2, 2.2), t)
	else:
		bar.modulate = Color.WHITE


func _pop_label() -> void:
	var tween = create_tween()
	label.scale = Vector2(1.15, 1.15)
	tween.tween_property(label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
