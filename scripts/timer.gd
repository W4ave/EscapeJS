extends CanvasLayer

#var elapsed_time: float = 0.0 #global로 옮김 
var is_running: bool = true

var time_slowdown = 1

@onready var label = $Label
@onready var game = get_tree().current_scene

const SAVE_PATH = "user://ranking.cfg"  # res:// 아니고 user://
const MAX_RANK = 3


func _ready() -> void:
	game.connect("focus_attacked", Callable(self, "slowdown_timer"))
	game.connect("make_unfocus", Callable(self, "return_timer"))
	
func slowdown_timer(): #속도 느리
	time_slowdown = global.slowdown
	
func return_timer():       #속도 정상
	time_slowdown = 1

func _process(delta: float) -> void:
	if is_running:
		global.elapsed_time += delta / time_slowdown
		label.text = format_time(global.elapsed_time)  # 00:00.00 형식


# 시간을 00:00.00 형식으로 변환
func format_time(time: float) -> String:
	@warning_ignore("integer_division")
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int(time * 100) % 100
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]


func stop_timer() -> void:
	is_running = false


func start_timer() -> void:
	is_running = true


func reset_timer() -> void:
	global.elapsed_time = 0.0
	label.text = "00:00.00"


func on_game_clear() -> void:
	stop_timer()
	
	# 그 다음 씬 전환
	var game_clear = load("res://scenes/game_clear.tscn").instantiate()
	game_clear.final_time = global.elapsed_time
	get_tree().root.add_child(game_clear)
	get_tree().current_scene.queue_free()
