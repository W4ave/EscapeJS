extends CharacterBody2D

const SPEED = 100.0
const RUN_SPEED = 150.0

var light_level = 1  #손전등 밝기

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_a", "move_d", "move_w", "move_s")
	var is_sprinting = Input.is_action_pressed("sprint") and global.stamina > 0

	if Input.is_action_pressed("sprint") and direction.length() > 0:
		global.stamina -= 50 * delta
	else:
		global.stamina += 20 * delta

	global.stamina = clamp(global.stamina, 0.0, 100.0)

	if direction != Vector2.ZERO:
		if is_sprinting:
			velocity = direction * RUN_SPEED
			anim.speed_scale = 2.0  # 뛸 때 2배 빠르게
		else:
			velocity = direction * SPEED
			anim.speed_scale = 1.0  # 걸을 때 기본 속도

		if direction.x > 0:
			anim.flip_h = false
		elif direction.x < 0:
			anim.flip_h = true

		anim.play("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		anim.speed_scale = 1.0
		anim.play("idle")

	move_and_slide()
	
func _input(event):   #입력 받았을 때만 호출되는 함수
	if event.is_action_pressed("turn_flashlight"):
		match light_level:       #키를 눌렀을 때의 light_level이 기준임.
			0:
				light_level += 1
				$Flashlight.enabled = true
				$Flashlight.texture_scale = 3.0
			1:
				light_level += 1
				$Flashlight.texture_scale = 4.5
			2:
				light_level = 0
				$Flashlight.enabled = false
		
	
