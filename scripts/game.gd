extends Node2D

signal player_died
signal player_damaged

func damage_player():
	global.life -= 1
	player_damaged.emit()         #관련 이벤트 관리용(animation, ui, ...)
	
	if global.life <= 0:
		player_died.emit()
		get_tree().call_deferred("change_scene_to_file", "res://scenes/game_over.tscn")
