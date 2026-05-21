extends Control

@onready var bar: ProgressBar = $Bar

func _process(_delta: float) -> void:
	bar.value = global.stamina
