extends CharacterBody2D

@onready var game = get_tree().current_scene
@onready var player = $"../Player"
@onready var Atk_spread_area = $Attack_1_Area
@onready var Atk_leg_area = $Attack_2_Area
@onready var Col_spread = $Attack_1_Area/Spread
@onready var Col_leg1 = $Attack_2_Area/Leg1
@onready var Col_leg2 = $Attack_2_Area/Leg2
@onready var Damaged_area = $DamagedArea

var is_waiting = false
var can_damaged = false

# const : 값이 절대 안 바뀌는 상수. 예고시간/판정시간을 한 곳에서 관리하면
# 나중에 밸런스 조절할 때 여기 숫자만 고치면 돼서 편해요.
const TELEGRAPH_TIME = 0.7   # 히트박스가 보이고 나서 실제 맞기까지 예고 시간(초)
const ACTIVE_TIME = 0.1      # 실제로 데미지 판정이 켜져있는 시간(초)


func _ready() -> void:
	global.boss_hp = 100.0
	
	Col_leg1.global_rotation = 0.0
	Col_leg2.global_rotation = 0.0
	Col_spread.global_rotation = 0.0
	
	# 처음엔 전부 판정 꺼둡니다.
	Col_leg1.disabled = true
	Col_leg2.disabled = true
	Col_spread.disabled = true
	
	# 시그널 연결은 _ready()에서 딱 한 번만! 반복 호출되는 함수 안에서 연결하면
	# 같은 시그널이 여러 번 연결되어 데미지가 중복으로 들어가는 버그가 생겨요.
	Atk_spread_area.body_entered.connect(_on_inked)
	Atk_leg_area.body_entered.connect(_on_hit)
	Damaged_area.body_entered.connect(_on_damaged_area)
	Damaged_area.body_exited.connect(_off_damaged_area)
	game.connect("player_attack", Callable(self, "_get_damaged"))


func _physics_process(delta: float) -> void:
	if global.boss_enable:
		if is_waiting:
			return
		is_waiting = true
		await get_tree().create_timer(randf_range(0.2, 1.0)).timeout
		await choose_pattern()
		is_waiting = false


func _on_inked(body: Node2D) -> void:
	if body.is_in_group("player") and global.boss_enable:
		game.ink_screen()

func _on_hit(body: Node2D) -> void:
	if body.is_in_group("player") and global.boss_enable:
		game.damage_player()
		global.boss_enable = false

func _on_damaged_area(_body : Node2D) -> void:
	can_damaged = true

func _off_damaged_area(_body : Node2D) -> void:
	can_damaged = false

func _get_damaged(damage):
	if can_damaged:
		global.boss_hp -= damage
		print(global.boss_hp)
		if global.boss_hp <= 0:
			game.boss_dead()

func choose_pattern() -> void:
	var patterns = [spread_pattern, leg1_pattern, leg2_pattern]
	var chosen_func = patterns.pick_random()
	await chosen_func.call()


# 공통 공격 처리 함수. hitbox 노드 하나만 넘겨주면
# "회전 → 예고 대기 → 판정 켜기 → 지속 대기 → 판정 끄기" 를 전부 처리해줍니다.
# 이 함수 덕분에 spread/leg1/leg2 패턴 코드가 각각 한 줄로 줄어들어요.
func execute_attack(hitbox: Node) -> void:
	# 1) 플레이어 방향으로 회전
	hitbox.global_rotation = (player.global_position - hitbox.global_position).angle()
	
	var texture = hitbox.get_node_or_null("texture")
	var box = hitbox.get_node_or_null("box")
	
	# 2) 예고 시간만큼 대기 (여기서 스프라이트 반짝임, 색깔 변화 등 연출 넣기 좋음)
	if box:
		box.visible = true
		box.scale = Vector2(0,1)
		var tween = create_tween()
		tween.tween_property(box, "scale", Vector2.ONE, TELEGRAPH_TIME)
		await tween.finished
	await get_tree().create_timer(TELEGRAPH_TIME).timeout
	
	# 3) 실제 데미지 판정 켜기
	if texture and box:
		texture.visible = true
		box.visible = false
	hitbox.disabled = false
	
	# 4) 판정이 켜져있는 시간만큼 대기
	await get_tree().create_timer(ACTIVE_TIME).timeout
	
	# 5) 판정 다시 끄기 (계속 켜두면 스치기만 해도 계속 데미지 들어감)
	hitbox.disabled = true
	if texture:
		texture.visible = false


func spread_pattern() -> void:
	# await : execute_attack 안의 대기 작업이 끝날 때까지 여기서도 기다림
	await execute_attack(Col_spread)

func leg1_pattern() -> void:
	await execute_attack(Col_leg1)

func leg2_pattern() -> void:
	await execute_attack(Col_leg2)
	
func spr_leg1_combo() -> void:
	pass
