extends CanvasLayer

@onready var game = get_tree().current_scene

var INK_TIME = 3.0
var is_inked : bool

var ink_timer = 0.0

func _ready() -> void:
	is_inked = false
	ink_timer = 0.0
	game.connect("get_inked", Callable(self, "_ui_appear"))


func _ui_appear():
	is_inked = true
	self.visible = true
	ink_timer = INK_TIME
	
	


func _physics_process(delta: float) -> void:
	if is_inked and ink_timer > 0:
		ink_timer -= delta
		
		if ink_timer <= 0:
			is_inked = false
			self.visible = false
