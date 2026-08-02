extends Node2D

signal player_died
signal player_damaged

func damage_player():
	
	player_damaged.emit()
	var life_out = load("res://scenes/life_out.tscn").instantiate()
	get_tree().root.add_child(life_out)
	get_tree().current_scene.queue_free()

	if global.life <= 0:
		player_died.emit()
		
		
		
