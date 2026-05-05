extends CharacterBody2D

# ── 상태 ──────────────────────────────────────────
enum State { PATROL, CHASE, RETURN }
var state: State = State.PATROL

# ── 순찰 설정 ─────────────────────────────────────
@export var patrol_points: Array[Vector2] = []   # 전역 좌표 웨이포인트
@export var patrol_speed: float = 90.0
@export var chase_speed: float = 105.0
@export var return_speed: float = 100.0

var patrol_index: int = 0          # 현재 목표 웨이포인트 인덱스
var patrol_forward: bool = true    # 핑퐁 방향 (true=앞, false=뒤)
var last_patrol_index: int = 0     # 복귀할 때 돌아갈 웨이포인트

# ── 시야 설정 ─────────────────────────────────────
@export var vision_range: float = 200.0
@export var vision_angle: float = 90.0            # 총 시야각 (도)
@export var lose_sight_time: float = 2.0          # 놓친 후 포기까지 시간

var player: Node2D = null
var time_since_seen: float = 0.0

# ── 내비게이션 ────────────────────────────────────
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

# ══════════════════════════════════════════════════
func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

	# patrol_points가 비어있으면 현재 위치를 첫 포인트로 추가
	if patrol_points.is_empty():
		patrol_points.append(global_position)

	_set_patrol_target()
# ══════════════════════════════════════════════════
func _physics_process(delta: float) -> void:
	match state:
		State.PATROL: _patrol(delta)
		State.CHASE:  _chase(delta)
		State.RETURN: _return_to_patrol(delta)

# ── PATROL ────────────────────────────────────────
func _patrol(delta: float) -> void:
	_move_toward_target(patrol_speed)

	if nav_agent.is_navigation_finished():
		_next_patrol_point()

	if _can_see_player():
		last_patrol_index = patrol_index
		_change_state(State.CHASE)

# ── CHASE ─────────────────────────────────────────
func _chase(delta: float) -> void:
	if _can_see_player():
		time_since_seen = 0.0
		nav_agent.target_position = player.global_position
	else:
		time_since_seen += delta
		if time_since_seen >= lose_sight_time:
			_change_state(State.RETURN)

	_move_toward_target(chase_speed)

# ── RETURN ────────────────────────────────────────
func _return_to_patrol(delta: float) -> void:
	_move_toward_target(return_speed)

	if nav_agent.is_navigation_finished():
		patrol_index = last_patrol_index
		_set_patrol_target()
		_change_state(State.PATROL)

	# 복귀 중에 다시 발견하면 즉시 추적
	if _can_see_player():
		time_since_seen = 0.0
		_change_state(State.CHASE)

# ── 공통 이동 ─────────────────────────────────────
func _move_toward_target(speed: float) -> void:
	if nav_agent.is_navigation_finished():
		return

	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = (next_pos - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

# ── 순찰 포인트 이동 ──────────────────────────────
func _set_patrol_target() -> void:
	if patrol_points.is_empty():
		return
	nav_agent.target_position = patrol_points[patrol_index]

func _next_patrol_point() -> void:
	if patrol_points.size() <= 1:
		return

	# 핑퐁 순환
	if patrol_forward:
		patrol_index += 1
		if patrol_index >= patrol_points.size():
			patrol_index = patrol_points.size() - 2
			patrol_forward = false
	else:
		patrol_index -= 1
		if patrol_index < 0:
			patrol_index = 1
			patrol_forward = true

	_set_patrol_target()

# ── 시야 판정 ─────────────────────────────────────
func _can_see_player() -> bool:
	if player == null:
		return false

	var to_player: Vector2 = player.global_position - global_position

	# 거리 체크
	if to_player.length() > vision_range:
		return false

	# 각도 체크 (현재 이동 방향 기준)
	var facing: Vector2 = velocity.normalized() if velocity.length() > 1.0 else Vector2.RIGHT
	var angle: float = rad_to_deg(facing.angle_to(to_player))
	if abs(angle) > vision_angle / 2.0:
		return false

	# 레이캐스트로 벽 차단 여부 체크
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position,
		0b11,          # 충돌 마스크 (환경 레이어에 맞게 수정)
		[self]
	)
	var result = space.intersect_ray(query)

	# 레이가 아무것도 안 맞거나 플레이어에 맞으면 시야 확보
	return result.is_empty() or result.collider == player

# ── 상태 전환 ─────────────────────────────────────
func _change_state(new_state: State) -> void:
	state = new_state
	time_since_seen = 0.0

	match new_state:
		State.PATROL:
			pass
		State.CHASE:
			nav_agent.target_position = player.global_position
		State.RETURN:
			# 가장 가까운 웨이포인트로 복귀
			patrol_index = _closest_patrol_point()
			nav_agent.target_position = patrol_points[patrol_index]

# ── 가장 가까운 웨이포인트 찾기 ───────────────────
func _closest_patrol_point() -> int:
	var closest_idx: int = 0
	var closest_dist: float = INF
	for i in patrol_points.size():
		var d: float = global_position.distance_to(patrol_points[i])
		if d < closest_dist:
			closest_dist = d
			closest_idx = i
	return closest_idx
