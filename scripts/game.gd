extends Node2D

signal player_died
signal player_damaged

func damage_player():
	global.life -= 1
	damaged_effect()
	player_damaged.emit()

	if global.life <= 0:
		player_died.emit()
		
		var game_over = load("res://scenes/game_over.tscn").instantiate()
		get_tree().root.add_child(game_over)
		get_tree().current_scene.queue_free()
		
func damaged_effect():
	global.damaged_state = 1
