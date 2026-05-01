extends Node

var stamina: float = 100.0

func _process(_delta: float) -> void:
	stamina = clamp(stamina, 0.0, 100.0)
