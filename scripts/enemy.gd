extends CharacterBody2D

@export var speed: float = 50.0
const SPEED : float = 50.0

var temp_slowdown : int


@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area: Area2D = $HitArea
@onready var navagent : NavigationAgent2D = $NavigationAgent2D
@onready var player = $"../Player"
@onready var game = get_tree().current_scene

var attack_range: float = 20.0
var player_position_offset = -9

func _ready() -> void:
	hit_area.body_entered.connect(_on_hit)
	game.connect("focus_attacked", Callable(self, "focus_avoid"))
	game.connect("make_unfocus", Callable(self, "unfocus_avoid"))
	

func focus_avoid():
	temp_slowdown = global.slowdown
	
	if speed == SPEED:
		speed /= global.slowdown

func unfocus_avoid():
	if speed != SPEED:
		speed *= temp_slowdown

func _physics_process(_delta: float) -> void:
	if global.enemy_enable:
		navagent.target_position = $"../Player".global_position
		_chase()
		
		move_and_slide()


func _chase() -> void:
	
	var direction: Vector2
	var distance_to_target = global_position.distance_to(player.global_position)
	
	if distance_to_target <= attack_range:
		# navmesh 무시하고 플레이어 쪽으로 직접 이동 (충돌은 collider가 처리)
		direction = (player.global_position - global_position).normalized()
	else:
		direction = (navagent.get_next_path_position() - global_position).normalized()
	
	velocity = direction * speed
	_update_animation(direction)

func first_attack():
	pass #


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
