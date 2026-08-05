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
		if avoid_time <= 0.0:
			game.damage_player()
		
		
	if !is_running:
		avoid_time = 100
		delta = 0

	
	

func ui_start():
	is_running = true
	anim_player.play("UI_appear")
	spacebar.visible = true
	
func ui_stop():
	is_running = false
	spacebar.visible = false
	anim_player.play("Black_bar_only")
	await get_tree().create_timer(0.1).timeout
	anim_player.play("RESET")
	
