extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:

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
