extends Node2D

signal player_died
signal player_damaged
signal focus_attacked
signal make_unfocus

func damage_player():
	
	player_damaged.emit()
	var life_out = load("res://scenes/life_out.tscn").instantiate()
	get_tree().root.add_child(life_out)
	get_tree().current_scene.queue_free()

	if global.life <= 0:
		player_died.emit()
		
		
func focus_attack_player():
	global.slowdown = 10
	emit_signal("focus_attacked")
	global.focus_state = true
	
func unfocusing():
	global.slowdown = 1
	emit_signal("make_unfocus")
	global.focus_state = false
		
		
