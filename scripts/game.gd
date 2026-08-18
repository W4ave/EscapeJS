extends Node2D

signal player_died
signal player_damaged
signal player_attack(damage)
signal focus_attacked
signal make_unfocus
signal get_inked

signal boss_dying

signal item_picked_up(item: Node2D)

func damage_player():
	
	player_damaged.emit()
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
	emit_signal("boss_dying")
