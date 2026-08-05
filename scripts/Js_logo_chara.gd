extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	
	var x1 = randi_range(50, 1000)
	var y1 = randi_range(0, 500)
	
	var x2 = randi_range(50, 1000)
	var y2 = randi_range(0, 500)
	
	velocity = Vector2(x2, y2) - Vector2(x1, y1)
	
	await get_tree().create_timer(2.5).timeout
	move_and_slide()
