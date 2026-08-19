extends CanvasLayer

@onready var game = get_tree().current_scene
@onready var color_rect: ColorRect = $ColorRect
@onready var texture_rect: TextureRect = $TextureRect

var INK_TIME = 3.0
var is_inked : bool

var ink_timer = 0.0
const FADE_OUT_TIME = 0.6   # 마지막 몇 초 동안 서서히 사라짐

func _ready() -> void:
	is_inked = false
	ink_timer = 0.0
	visible = false
	color_rect.modulate.a = 0.0
	texture_rect.modulate.a = 0.0
	texture_rect.pivot_offset = texture_rect.size / 2.0
	game.connect("get_inked", Callable(self, "_ui_appear"))


func _ui_appear():
	is_inked = true
	ink_timer = INK_TIME
	visible = true
	color_rect.modulate.a = 0.0
	texture_rect.modulate.a = 0.0
	texture_rect.scale = Vector2(0.6, 0.6)

	var tween = create_tween()
	tween.set_parallel(true)
	# 화면 전체 확 튀는 잉크 스플래시: 빠르게 나타났다가
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.1)
	tween.tween_property(texture_rect, "modulate:a", 1.0, 0.1)
	tween.tween_property(texture_rect, "scale", Vector2(1.05, 1.05), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(texture_rect, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)


func _physics_process(delta: float) -> void:
	if is_inked and ink_timer > 0:
		ink_timer -= delta

		if ink_timer <= FADE_OUT_TIME:
			var a = clamp(ink_timer / FADE_OUT_TIME, 0.0, 1.0)
			color_rect.modulate.a = a
			texture_rect.modulate.a = a

		if ink_timer <= 0:
			is_inked = false
			visible = false
