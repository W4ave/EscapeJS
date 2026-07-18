extends CharacterBody2D

const SPEED = 100.0
const RUN_SPEED = 150.0
var direction := Vector2.ZERO
var light_level = 1
var light_loss = 5

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var flashlight: PointLight2D = $Flashlight

const CONE_ANGLE_DEG = 30.0
const CONE_RADIUS = 120
const CONE_SOFTNESS = 0.2

func _ready() -> void:
	flashlight.texture = _create_cone_texture(CONE_RADIUS, CONE_ANGLE_DEG, CONE_SOFTNESS)
	flashlight.offset = Vector2.ZERO

func _create_cone_texture(radius: int, half_angle_deg: float, softness: float) -> ImageTexture:
	var size = radius * 2
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = Vector2(size / 2.0, size / 2.0)
	var half_angle_rad = deg_to_rad(half_angle_deg)

	for x in range(size):
		for y in range(size):
			var pixel = Vector2(x, y)
			var diff = pixel - center
			var dist = diff.length()

			if dist > radius or dist < 1.0:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue

			if diff.x < 0:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue

			var angle = abs(atan2(diff.y, diff.x))

			var angle_alpha: float
			var inner = half_angle_rad - softness
			var outer = half_angle_rad + softness
			if angle < inner:
				angle_alpha = 1.0
			elif angle < outer:
				angle_alpha = 1.0 - (angle - inner) / (softness * 2.0)
			else:
				angle_alpha = 0.0

			var dist_ratio = dist / float(radius)
			var dist_alpha = 1.0 - smoothstep(0.3, 1.0, dist_ratio)

			var final_alpha = angle_alpha * dist_alpha
			img.set_pixel(x, y, Color(1, 1, 1, final_alpha))

	return ImageTexture.create_from_image(img)

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("move_a", "move_d", "move_w", "move_s")
	var is_sprinting = Input.is_action_pressed("sprint") and global.stamina > 0

	# ----------- [ stamina ] -------------
	if Input.is_action_pressed("sprint") and direction.length() > 0:
		global.stamina -= 50 * delta
	else:
		global.stamina += 20 * delta

	# ----------- [ anime ] -------------
	if direction != Vector2.ZERO:
		if is_sprinting:
			velocity = direction * RUN_SPEED
			anim.speed_scale = 2.0
		else:
			velocity = direction * SPEED
			anim.speed_scale = 1.0

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

func _process(delta: float) -> void:
	if global.light_charge <= 0:
		light_level = 0

	if light_level > 2:
		light_level = 0

	if light_level != 0:
		global.light_charge -= light_loss * delta
	else:
		global.light_charge += 5 * delta

	# ----------- [ flashlight state ] -------------
	match light_level:
		0:
			flashlight.enabled = false
		1:
			flashlight.enabled = true
			flashlight.texture_scale = 1.0
			flashlight.energy = 1.0
			light_loss = 5
		2:
			flashlight.texture_scale = 1.4
			flashlight.energy = 1.5
			light_loss = 15

	if direction != Vector2.ZERO:
		flashlight.rotation = direction.angle()

func _input(event):
	if event.is_action_pressed("turn_flashlight"):
		light_level += 1
