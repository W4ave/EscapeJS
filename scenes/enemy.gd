extends CharacterBody2D

@onready var ray = $RayCast2D 
@onready var view_area: Area2D = $Flip_h_Pivot/Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready():
	ray.add_exception(self)

func _physics_process(_delta: float) -> void:
	var targets = view_area.get_overlapping_bodies()
	
	for target in targets:
		if target.is_in_group("Player"):
			if is_player_visible(target):
				print("플레이어 발견!")
			else:
				# 플레이어가 Area2D 안에는 있지만 레이저가 벽에 막힌 상태
				print("벽 뒤에 숨음")

func is_player_visible(target: Node2D) -> bool:
	var target_node = target.get_node("LookAtPoint")
	ray.target_position = ray.to_local(target_node.global_position)
	ray.force_raycast_update()

	if ray.is_colliding():
		var collider = ray.get_collider()
		# 레이저가 부딪힌 게 플레이어(target) 본체인지 확인
		if collider == target:
			return true
	return false
	
