extends CharacterBody2D


const SPEED = 100.0
const RUN_SPEED = 150.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:


	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if Input.is_action_pressed("sprint") and direction.length() > 0:
		global.stamina -= 50 * delta
	else:
		global.stamina += 20 * delta
	

	if direction != Vector2.ZERO:
		# 대각선 이동 시 속도가 빨라지지 않게 이미 get_vector가 정규화를 해주지만, 
		# 한 번 더 명확하게 속도를 곱해줍니다.
		if Input.is_action_pressed("sprint") and global.stamina > 0:
			velocity = direction * RUN_SPEED
		else:
			velocity = direction * SPEED
	else:
		# 입력이 없으면 서서히 멈춤
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)


	move_and_slide()
