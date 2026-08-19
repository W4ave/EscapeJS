extends CanvasLayer

@onready var label = $Label

var last_life : int = -1

func _ready() -> void:
	last_life = global.life
	label.pivot_offset = label.size / 2.0


func _process(_delta: float) -> void:
	label.text = "Life : %d" % global.life

	if global.life != last_life:
		last_life = global.life
		_pop()


func _pop() -> void:
	var tween = create_tween()
	label.scale = Vector2(1.7, 1.7)
	label.modulate = Color(1.0, 0.3, 0.3)
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate", Color.WHITE, 0.45)
