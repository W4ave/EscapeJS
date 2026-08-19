extends Node2D

signal player_died
signal player_damaged
signal player_attack(damage)
signal focus_attacked
signal make_unfocus
signal get_inked

signal boss_dying

signal item_picked_up(item: Node2D)

# ----------- [ camera shake ] -------------
# strength: 흔들리는 최대 픽셀 세기, duration: 지속 시간(초)
signal screen_shake(strength: float, duration: float)

func shake_camera(strength: float = 8.0, duration: float = 0.3) -> void:
	emit_signal("screen_shake", strength, duration)

func _ready() -> void:
	item_picked_up.connect(_on_item_picked_up)

func _on_item_picked_up(item: Node2D) -> void:
	match item.item_id:
		"hammer":
			global.has_hammer = true
		"flashlight":
			global.get_flashlight = true

func damage_player():
	
	player_damaged.emit()
	shake_camera(14.0, 0.4)
	var life_out = load("res://scenes/life_out.tscn").instantiate()
	get_tree().root.add_child(life_out)
	get_tree().current_scene.queue_free()

	if global.life <= 0:
		player_died.emit()
		
		
func ink_screen():
	emit_signal("get_inked")

func focus_attack_player():
	global.slowdown = 10
	emit_signal("focus_attacked")
	global.focus_state = true
	
func unfocusing():
	global.slowdown = 1
	emit_signal("make_unfocus")
	global.focus_state = false
		
func attack(damage):
	emit_signal("player_attack", damage)
		
func boss_dead():
	shake_camera(22.0, 0.6)
	emit_signal("boss_dying")
