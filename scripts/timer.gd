extends CanvasLayer  # 이 스크립트가 CanvasLayer 노드에 붙어있다고 선언

# --- 변수 선언 ---
var elapsed_time: float = 0.0  # 흐른 시간을 저장하는 변수 (소수점 포함)
var is_running: bool = true     # 타이머가 동작 중인지 여부

@onready var label = $Label  # 씬에서 Label 노드를 찾아서 연결


# _process(delta)는 매 프레임마다 자동으로 호출되는 함수
# delta = 이전 프레임과 현재 프레임 사이의 시간 간격 (초 단위, 보통 0.016초 정도)
func _process(delta: float) -> void:
	if is_running:
		elapsed_time += delta  # 매 프레임마다 흐른 시간을 누적

		# 전체 초를 60으로 나눈 몫 = 분
	var minutes = int(elapsed_time) / 60
	# 전체 초를 60으로 나눈 나머지 = 초
	var seconds = int(elapsed_time) % 60

	# "%02d" 는 두 자리로 표시, 한 자리면 앞에 0을 붙임 (예: 09)
	label.text = "%02d:%02d" % [minutes, seconds]

# 타이머를 멈추고 싶을 때 호출하는 함수
func stop_timer() -> void:
	is_running = false


# 타이머를 다시 시작하고 싶을 때 호출하는 함수
func start_timer() -> void:
	is_running = true


# 타이머를 0으로 초기화하고 싶을 때 호출하는 함수
func reset_timer() -> void:
	elapsed_time = 0.0
	label.text = "00:00"
	
func _ready() -> void:
	var game = get_tree().current_scene
	game.player_died.connect(resulted_timer)
	
func resulted_timer() -> void:
	print("끝")
	stop_timer()
	#시간 저장
	#reset
