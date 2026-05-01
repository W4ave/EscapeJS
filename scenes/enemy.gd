extends CharacterBody2D

@export var speed: float = 110.0

var target: Node2D = null

@onready var detection_area: Area2D = $DetectionArea
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray: RayCast2D = $RayCast2D
@onready var hit_area: Area2D = $HitArea


func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	hit_area.body_entered.connect(_on_hit)


func _physics_process(delta: float) -> void:
	if target and _can_see_target():
		_chase()
	else:
		velocity = Vector2.ZERO
		anim.play("idle")

	move_and_slide()


func _can_see_target() -> bool:
	ray.target_position = to_local(target.global_position)
	ray.force_raycast_update()

	if not ray.is_colliding():
		return true
	return ray.get_collider() == target


func _chase() -> void:
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	_update_animation(direction)


func _update_animation(dir: Vector2) -> void:
	if dir.x >= 0:
		anim.flip_h = false
	else:
		anim.flip_h = true

	anim.play("walk_side")


func _on_hit(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body


func _on_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
