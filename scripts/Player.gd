extends CharacterBody2D

const SPEED = 100.0
const RUN_SPEED = 150.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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
