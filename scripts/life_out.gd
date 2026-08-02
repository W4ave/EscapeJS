extends Node2D



func _ready() -> void:
	
	match global.life:
		3:
			$AnimationPlayer.play("life3_fall")
		2:
			$AnimationPlayer.play("life2_fall")
		1:
			$AnimationPlayer.play("life1_fall")
	
	global.life -= 1
	await get_tree().create_timer(1.5).timeout
	
	if global.life > 0:
		queue_free()  # game_over 씬 먼저 제거
		reset()
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		queue_free()  # game_over 씬 먼저 제거
		reset()
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
		
func reset():
	global.light_charge = 100.0
	global.stamina = 100.0
	global.enemy_enable = false
	
	
