extends CharacterBody2D

@export var speed: float = 75.0
const SPEED : float = 75.0

var temp_slowdown : int


@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area: Area2D = $HitArea
@onready var navagent : NavigationAgent2D = $NavigationAgent2D
@onready var player = $"../Player"
@onready var game = get_tree().current_scene
@onready var interaction = $interaction

var attack_range: float = 20.0
var player_position_offset = -9

var has_met_player: bool = false  # 이 판(생명)에서 플레이어와 처음 조우했는지 여부. 죽어서 씬이 다시 로드되면 새 enemy 인스턴스가 생성되므로 자동으로 false로 초기화됨.
var player_in_range: bool = false  # 플레이어가 interaction 범위 안에 있는지 여부

func _ready() -> void:
	hit_area.body_entered.connect(_on_hit)
	interaction.body_entered.connect(_on_interact_enter)
	interaction.body_exited.connect(_on_interact_exit)
	game.connect("focus_attacked", Callable(self, "focus_avoid"))
	game.connect("make_unfocus", Callable(self, "unfocus_avoid"))
	

func _on_interact_enter(body : Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_interact_exit(body : Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

# 플레이어가 akdntmzmfflr키를 눌렀을 때 Player.gd에서 호출
func try_focus_attack() -> void:
	if player_in_range and not has_met_player:
		has_met_player = true
		game.focus_attack_player()

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
		game.damage_player()
		
