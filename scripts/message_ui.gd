# 화면에 잠깐 떴다 사라지는 안내 메시지 토스트.
# game.gd의 show_message(text) 신호를 받아서 동작합니다.
extends CanvasLayer

@onready var label: Label = $Control/Label
@onready var game = get_tree().current_scene

const DISPLAY_TIME := 2.0   # 메시지가 선명하게 보이는 시간(초)
const FADE_TIME := 0.25     # 나타나고 사라지는 페이드 시간(초)

var hide_timer: float = 0.0
var fade_tween: Tween


func _ready() -> void:
	label.modulate.a = 0.0
	game.connect("show_message", Callable(self, "_on_show_message"))


func _on_show_message(text: String) -> void:
	label.text = text
	hide_timer = DISPLAY_TIME

	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(label, "modulate:a", 1.0, FADE_TIME)


func _process(delta: float) -> void:
	if hide_timer > 0.0:
		hide_timer -= delta
		if hide_timer <= 0.0:
			if fade_tween:
				fade_tween.kill()
			fade_tween = create_tween()
			fade_tween.tween_property(label, "modulate:a", 0.0, FADE_TIME)
