extends CharacterBody2D

@onready var game = get_tree().current_scene
@onready var player = $"../Player"
@onready var Atk_spread_area = $Attack_1_Area
@onready var Atk_leg_area = $Attack_2_Area
@onready var Col_spread = $Attack_1_Area/Spread
@onready var legs: Array = [
	$Attack_2_Area/Leg1, $Attack_2_Area/Leg2, $Attack_2_Area/Leg3,
	$Attack_2_Area/Leg4, $Attack_2_Area/Leg5, $Attack_2_Area/Leg6,
	$Attack_2_Area/Leg7, $Attack_2_Area/Leg8
]

@onready var Damaged_area = $DamagedArea
@onready var anim = $AnimatedSprite2D

var is_waiting = false
var is_blocking = false
var can_damaged = false

var phase = 1

@onready var phase1 = [Callable(self, "execute_attack").bind(Col_spread), Callable(self, "execute_attack").bind(legs[0]), Callable(self, "execute_attack").bind(legs[1])]
		
@onready var phase2 = [two_leg_pattern, squeeze_pattern]

@onready var phase3 = [two_leg_pattern, squeeze_pattern]

@onready var block_legs = [Callable(self, "blocking_pattern").bind(legs[4]), Callable(self, "blocking_pattern").bind(legs[5])]
# const : 값이 절대 안 바뀌는 상수. 예고시간/판정시간을 한 곳에서 관리하면
# 나중에 밸런스 조절할 때 여기 숫자만 고치면 돼서 편해요.
var telegraph_time = 0.7   # 히트박스가 보이고 나서 실제 맞기까지 예고 시간(초)
var active_time = 0.3      # 실제로 데미지 판정이 켜져있는 시간(초)

var patterns = []


func _ready() -> void:
	phase = 1
	can_damaged = false
	global.boss_hp = 100.0
	
	patterns = [Callable(self, "execute_attack").bind(Col_spread),
		Callable(self, "execute_attack").bind(legs[0]),
		Callable(self, "execute_attack").bind(legs[1])]
		
	telegraph_time = 0.7
	active_time = 0.3
	var is_phase3 = false
	is_blocking = false
	is_waiting = false
	
	for leg in legs:
		leg.global_rotation = 0.0
	Col_spread.global_rotation = 0.0
	
	# 처음엔 전부 판정 꺼둡니다.
	for leg in legs:
		leg.disabled = true
	Col_spread.disabled = true
	
	# 시그널 연결은 _ready()에서 딱 한 번만! 반복 호출되는 함수 안에서 연결하면
	# 같은 시그널이 여러 번 연결되어 데미지가 중복으로 들어가는 버그가 생겨요.
	Atk_spread_area.body_entered.connect(_on_inked)
	Atk_leg_area.body_entered.connect(_on_hit)
	Damaged_area.body_entered.connect(_on_damaged_area)
	Damaged_area.body_exited.connect(_off_damaged_area)
	game.connect("player_attack", Callable(self, "_get_damaged"))
	game.connect("boss_dying", Callable(self, "_death"))


func _physics_process(delta: float) -> void:
	if global.boss_enable:
		if global_position.distance_to(player.global_position) <= 80:
			patterns.append(biting_pattern)
		elif patterns.count(biting_pattern) != 0:
			patterns.erase(biting_pattern)
		if is_waiting:
			return
		is_waiting = true
		await get_tree().create_timer(randf_range(0.2, 0.6)).timeout
		if phase >= 2 and !is_blocking:
			run_blocking_pattern(legs[4]) #공간 축소(다리로)
		await choose_pattern()
		is_waiting = false
	
		
		if global.boss_hp >= 80:
			phase = 1
			
			patterns = phase1
			telegraph_time = 0.8
		elif global.boss_hp >= 50:
			phase = 2
			
			patterns = phase2
			telegraph_time = 0.75
		elif global.boss_hp >= 20:
			phase = 3
			
			patterns = phase3
			telegraph_time = 0.6
		else:
			game.boss_dead()


func _on_inked(body: Node2D) -> void:
	if body.is_in_group("player") and global.boss_enable:
		game.ink_screen()

func _on_hit(body: Node2D) -> void:
	if body.is_in_group("player") and global.boss_enable:
		game.damage_player()
		global.boss_enable = false

func _on_damaged_area(_body : Node2D) -> void:
	can_damaged = true
	print("entered - boss pos: ", global_position, " player pos: ", player.global_position)

func _off_damaged_area(_body : Node2D) -> void:
	can_damaged = false

func _get_damaged(damage):
	if can_damaged:
		global.boss_hp -= damage
		print(global.boss_hp)
		anim.play("damaged")
		await anim.animation_finished
		anim.play("idle")
		
		
				

func _death():
	global.boss_enable = false

func choose_pattern() -> void:
	var chosen_func = patterns.pick_random()
	await chosen_func.call()


# 공통 공격 처리 함수. hitbox 노드 하나만 넘겨주면
# "회전 → 예고 대기 → 판정 켜기 → 지속 대기 → 판정 끄기" 를 전부 처리해줍니다.
# 이 함수 덕분에 spread/leg1/leg2 패턴 코드가 각각 한 줄로 줄어들어요.
func execute_attack(hitbox: Node):
	# 1) 플레이어 방향으로 회전
	var rand_offset = Vector2(randf_range(-25, 25), randf_range(-25, 25))
	hitbox.global_rotation = (player.global_position - hitbox.global_position + rand_offset).angle()
	
	var texture = hitbox.get_node_or_null("texture")
	var box = hitbox.get_node_or_null("box")
	
	# 2) 예고 시간만큼 대기 (여기서 스프라이트 반짝임, 색깔 변화 등 연출 넣기 좋음)
	if box:
		box.visible = true
		box.scale = Vector2(0,1)
		var tween = create_tween()
		tween.tween_property(box, "scale", Vector2.ONE, telegraph_time)
		await tween.finished
	await get_tree().create_timer(telegraph_time/2.5).timeout
	
	# 3) 실제 데미지 판정 켜기
	if texture and box:
		texture.visible = true
		box.visible = false
	hitbox.disabled = false
	
	# 4) 판정이 켜져있는 시간만큼 대기
	await get_tree().create_timer(active_time).timeout
	
	# 5) 판정 다시 끄기 (계속 켜두면 스치기만 해도 계속 데미지 들어감)
	hitbox.disabled = true
	if texture:
		texture.visible = false

func execute_squeeze(hitbox: Node):
	# 1) 플레이어 방향으로 
	var rand_offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
	hitbox.global_position = player.global_position + rand_offset
	
	var texture = hitbox.get_node_or_null("texture")
	var box = hitbox.get_node_or_null("box")
	
	# 2) 예고 시간만큼 대기 (여기서 스프라이트 반짝임, 색깔 변화 등 연출 넣기 좋음)
	if box:
		box.visible = true
		box.scale = Vector2(0,1)
		var tween = create_tween()
		tween.tween_property(box, "scale", Vector2.ONE, telegraph_time)
		await tween.finished
	await get_tree().create_timer(0.01).timeout
	
	# 3) 실제 데미지 판정 켜기
	if texture and box:
		texture.visible = true
		box.visible = false
	hitbox.disabled = false
	
	# 4) 판정이 켜져있는 시간만큼 대기
	await get_tree().create_timer(active_time).timeout
	
	# 5) 판정 다시 끄기 (계속 켜두면 스치기만 해도 계속 데미지 들어감)
	hitbox.disabled = true
	if texture:
		texture.visible = false
		
		
func biting_pattern():
	pass
##################################################
func two_leg_pattern() -> void:
	var a = call("execute_attack", legs[0])
	var b = call("execute_attack", legs[1])
	await a
	await b

func squeeze_pattern() -> void:
	var a = call("execute_squeeze", legs[6])
	
	await a
	await get_tree().create_timer(telegraph_time/3).timeout
	var b = call("execute_squeeze", legs[7])
	await b
	
	
func run_blocking_pattern(leg: Node) -> void:
	is_blocking = true
	await blocking_pattern(leg)
	is_blocking = false

func blocking_pattern(hitbox : Node2D):
 	#legs[4], legs[5] using
	var rand_offset = Vector2(randf_range(-25, -20) if randf() < 0.5 else randf_range(20, 25), randf_range(-25, -20) if randf() < 0.5 else randf_range(20, 25))
	hitbox.global_rotation = (player.global_position - hitbox.global_position + rand_offset).angle()
	
	var texture = hitbox.get_node_or_null("texture")
	var box = hitbox.get_node_or_null("box")
	
	if box:
		box.visible = true
		box.color = Color("#8d00954d")
		for i in range(3):
			var tween1 = create_tween()
			tween1.tween_property(box, "color", Color("#ff001600"), telegraph_time/6)
			await tween1.finished
			var tween2 = create_tween()
			tween2.tween_property(box, "color", Color("#8d00954d"), telegraph_time/6)
			await tween2.finished
	await get_tree().create_timer(telegraph_time/2.5).timeout
	
	# 3) 실제 데미지 판정 켜기
	if texture and box:
		texture.visible = true
		box.visible = false
	hitbox.disabled = false
	
	# 4) 판정이 켜져있는 시간만큼 대기
	await get_tree().create_timer(5).timeout
	
	hitbox.disabled = true
	if texture:
		texture.visible = false
