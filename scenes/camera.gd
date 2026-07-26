# Camera2D 스크립트 (플레이어의 자식)
extends Camera2D

var trauma := 0.0
var trauma_power := 2.0
const MAX_OFFSET := 20.0
const MAX_ROTATION := 0.08  # 라디안, 너무 크면 어지러움
const DECAY := 2.0

var shake_noise := FastNoiseLite.new()
var noise_t := 0.0

func _ready() -> void:
	ignore_rotation = false
	shake_noise.seed = randi()
	shake_noise.frequency = 0.5

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - delta * DECAY, 0.0)
		var shake = pow(trauma, trauma_power)
		noise_t += delta * 25.0

		offset = Vector2(
			MAX_OFFSET * shake * shake_noise.get_noise_1d(noise_t),
			MAX_OFFSET * shake * shake_noise.get_noise_1d(noise_t + 100.0)
		)
		rotation = MAX_ROTATION * shake * shake_noise.get_noise_1d(noise_t + 200.0)
	else:
		offset = Vector2(0, -11)
		rotation = 0.0
		
func _physics_process(delta: float) -> void:
	pass
	if global.damaged_state == 1:
		add_trauma(0.1)
		await get_tree().create_timer(delta * 5).timeout
		global.damaged_state = 0
