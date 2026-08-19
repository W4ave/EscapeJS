extends CanvasLayer

@onready var bar_left = $Progress_Left
@onready var bar_right = $Progress_Right
@onready var anim_player = $AnimationPlayer
@onready var game = get_tree().current_scene
@onready var spacebar = $Spacebar

var is_running = false
var avoid_time : float = 100.0

func _ready() -> void:
	game.connect("focus_attacked", Callable(self, "ui_start"))
	game.connect("make_unfocus", Callable(self, "ui_stop"))
	spacebar.play()
	spacebar.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	bar_left.value = avoid_time
	bar_right.value = avoid_time

	if is_running:
		avoid_time -= delta * 100

		# 남은 시간이 줄어들수록 더 붉고 빠르게 경고 깜빡임 + 스페이스바가 더 급하게 흔들림
		var danger : float = 1.0 - clamp(avoid_time / 100.0, 0.0, 1.0)
		var pulse : float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / max(140.0 - danger * 100.0, 40.0))
		var warn_color : Color = Color.WHITE.lerp(Color(1.0, 0.25, 0.25), danger * pulse)
		bar_left.modulate = warn_color
		bar_right.modulate = warn_color
		spacebar.speed_scale = 1.7 + danger * 3.5

		if avoid_time <= 0.0:
			game.shake_camera(16.0, 0.5)
			game.damage_player()

	if !is_running:
		avoid_time = 100
		bar_left.modulate = Color.WHITE
		bar_right.modulate = Color.WHITE
		spacebar.speed_scale = 1.7
		delta = 0


func ui_start():
	is_running = true
	anim_player.play("UI_appear")
	spacebar.visible = true
	game.shake_camera(10.0, 0.35)

func ui_stop():
	is_running = false
	spacebar.visible = false
	anim_player.play("Black_bar_only")
	await get_tree().create_timer(0.1).timeout
	anim_player.play("RESET")
