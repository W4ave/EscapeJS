extends Control

@onready var bar: ProgressBar = $Bar

var displayed_value : float = 100.0
const LOW_THRESHOLD = 20.0

func _process(delta: float) -> void:
	var target = global.stamina

	# 실제 값이 아닌, 부드럽게 따라가는 표시값을 그려서 뚝뚝 끊기지 않게
	displayed_value = lerp(displayed_value, target, clamp(delta * 12.0, 0.0, 1.0))
	bar.value = displayed_value

	if target <= LOW_THRESHOLD:
		var pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 90.0)
		bar.modulate = Color.WHITE.lerp(Color(1.0, 0.3, 0.3), 0.35 + 0.5 * pulse)
	else:
		bar.modulate = bar.modulate.lerp(Color.WHITE, clamp(delta * 8.0, 0.0, 1.0))
