extends Node

var light_charge = 100.0   #손전등 배터리%

var stamina: float = 100.0    #달리기 스태미나%

var life = 3

func _process(_delta: float) -> void:
	stamina = clamp(stamina, 0.0, 100.0)
	
	light_charge = clamp(light_charge, 0.0, 100.0)
