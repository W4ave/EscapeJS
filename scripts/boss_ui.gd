extends CanvasLayer

@onready var bar = $ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.boss_enable:
		visible = true
	bar.value = global.boss_hp
