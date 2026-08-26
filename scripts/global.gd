extends Node

var light_charge = 100.0   #손전등 배터리%
var stamina: float = 100.0    #달리기 스태미나%
var life = 3
var current_stage = 0

var get_flashlight = false   #플래시라이트 아이템을 먹기 전까지는 손전등 사용 불가
var enemy_enable = false
var boss_enable = false

var has_hammer = false                  #망치 습득 여부
const HAMMER_DAMAGE : int = 5           #망치 공격 데미지
const HAMMER_COOLDOWN_TIME : float = 1.0   #망치 쿨타임(초)
var hammer_cooldown_left : float = 0.0     #현재 남은 쿨타임(초)

var obtainable_item : String

var boss_hp : float = 100.0

var checkpoint : Vector2 = Vector2(10,-1500) #(-800, -4000)         #(-30, -1500)    #= Vector2(0,-1)
var elapsed_time: float = 0.0
var focus_state = false

var slowdown = 1

func _process(_delta: float) -> void:
	stamina = clamp(stamina, 0.0, 100.0)
	
	light_charge = clamp(light_charge, 0.0, 100.0)
