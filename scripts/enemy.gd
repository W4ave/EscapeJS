extends CharacterBody2D

@export var speed: float = 50.0

var target: Node2D = null
var state : String = "patrol"           # "chase" , "patrol" 두 상태로 나뉨

@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray: RayCast2D = $RayCast2D
@onready var hit_area: Area2D = $HitArea
@onready var navagent : NavigationAgent2D = $NavigationAgent2D

var patrol_dir: Vector2 = Vector2.RIGHT
var patrol_timer: float = 0.0
var chase_timer : float = 0.0
@export var attack_range: float = 20.0
var player_position_offset = -9

#변수 확인용
@onready var debug_label: Label = $Label


func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	hit_area.body_entered.connect(_on_hit)
	

func _physics_process(_delta: float) -> void:
	if global.enemy_enable:
		if target and _can_see_target():
			state = "chase"
			chase_timer = 5.0
		else:
			chase_timer -= _delta
			if chase_timer <= 0.0:
				state = "patrol"

		if state == "chase":
			navagent.target_position = $"../Player".global_position
			_chase()
			
		elif state == "patrol":
			patrol_timer -= _delta
			if patrol_timer <= 0.0:
				patrol_dir = Vector2.from_angle(randf_range(0, TAU))
				patrol_timer = randf_range(1.0, 2.5)   # 1~2.5초마다 방향 갱신
			velocity = patrol_dir * 25
			
			
		move_and_slide()
		_update_debug_label()
	
func _update_debug_label() -> void:
	debug_label.text = state


func _can_see_target() -> bool:
	ray.target_position = to_local(target.global_position + Vector2(0,player_position_offset))
	ray.force_raycast_update()

	if not ray.is_colliding():
		state = "chase"
		return true
	return ray.get_collider() == target


func _chase() -> void:
	
	var direction: Vector2
	var distance_to_target = global_position.distance_to($"../Player".global_position)
	
	if distance_to_target <= attack_range:
		# navmesh 무시하고 플레이어 쪽으로 직접 이동 (충돌은 collider가 처리)
		direction = (target.global_position - global_position).normalized()
	else:
		direction = (navagent.get_next_path_position() - global_position).normalized()
	
	velocity = direction * speed
	_update_animation(direction)


func _update_animation(dir: Vector2) -> void:
	if dir.x >= 0:
		anim.flip_h = false
	else:
		anim.flip_h = true

	anim.play("walk_side")


func _on_hit(body: Node2D) -> void:	
	if body.is_in_group("player") and global.enemy_enable:
		var game = get_tree().current_scene
		game.damage_player()
		#
		#var Spawnpoint = $"../Spawnpoint"
		#
		#visible = false
		#collision.set_deferred("disable", true)
		#hit_area.set_deferred("monitoring", false)
		#
		#target = null
		#chase_timer = 0.0
		#state = "patrol"
		#
		#await get_tree().create_timer(1.5).timeout
		#global_position = Spawnpoint.global_position
		#
		#visible = true
		#collision.set_deferred("disable", false)
		#hit_area.set_deferred("monitoring", true)         
		#260726 - 기획 상으로 봤을 때 리스폰은 필요 없을 듯.


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body


func _on_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
