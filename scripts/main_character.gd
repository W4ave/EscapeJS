extends CharacterBody2D

# =====================
# 기본 이동 변수
# =====================
const SPEED = 200.0  # 이동 속도 (픽셀/초)

# =====================
# 손전등 관련 변수
# =====================
var flashlight_on: bool = true  # 시작할 때 손전등이 켜진 상태

# @onready: 씬이 완전히 로드된 후에 노드를 가져옴
# $Flashlight: 자식 노드 중 이름이 "Flashlight"인 노드
@onready var flashlight = $Flashlight  # PointLight2D (Flashlight2D)

func _ready():
	flashlight.enabled = flashlight_on  # 시작 시 손전등 상태 적용
	# SpotLight2D는 visible을 썼지만,
	# PointLight2D 계열은 enabled 속성으로 켜고 끔

func _process(delta):
	# 매 프레임마다 실행
	_rotate_flashlight_to_mouse()   # 손전등 방향 업데이트
	_handle_flashlight_toggle()     # F키 입력 감지

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		# 대각선 이동 시 속도가 빨라지지 않게 이미 get_vector가 정규화를 해주지만, 
		# 한 번 더 명확하게 속도를 곱해줍니다.
		velocity = direction * SPEED
	else:
		# 입력이 없으면 서서히 멈춤
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)


	move_and_slide()

# =====================
# 손전등을 마우스 방향으로 회전
# =====================
func _rotate_flashlight_to_mouse():
	var mouse_pos = get_global_mouse_position()  # 마우스의 월드 좌표
	var direction = mouse_pos - global_position  # 캐릭터 → 마우스 방향 벡터
	
	# atan2(y, x): 방향 벡터를 각도(라디안)로 변환
	flashlight.rotation = atan2(direction.y, direction.x)

# =====================
# F키로 손전등 켜기/끄기 (토글)
# =====================
func _handle_flashlight_toggle():
	# is_action_just_pressed: 이번 프레임에 막 눌렸을 때만 true
	# (꾹 누르고 있어도 처음 한 번만 감지)
	if Input.is_action_just_pressed("flashlight_toggle"):
		flashlight_on = !flashlight_on          # true ↔ false 뒤집기
		flashlight.enabled = flashlight_on      # 손전등 적용
