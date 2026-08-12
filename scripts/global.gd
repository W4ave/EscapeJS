extends Node

var light_charge = 100.0   #손전등 배터리%
var stamina: float = 100.0    #달리기 스태미나%
var life = 3
var current_stage = 0

var get_flashlight = true
var enemy_enable = false
var boss_enable = false

var boss_hp : float = 100.0

var checkpoint : Vector2 =Vector2(-250, 400)    #= Vector2(0,-1)
var elapsed_time: float = 0.0
var focus_state = false

var slowdown = 1

func _process(_delta: float) -> void:
	stamina = clamp(stamina, 0.0, 100.0)
	
	light_charge = clamp(light_charge, 0.0, 100.0)
