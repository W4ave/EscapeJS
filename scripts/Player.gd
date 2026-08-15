extends CharacterBody2D

const SPEED = 100.0
const RUN_SPEED = 150.0

var speed = 100.0
var run_speed = 150.0
var direction := Vector2.ZERO
var light_level = 0
var light_loss = 5

var temp_slowdown : int

var is_dashing : bool
var dash_direction = Vector2.ZERO
const DASH_TIME = 0.05
var dash_timer = 0.0

var is_attacking : bool
var attack_timer = 0.0
const ATTACK_TIME = 0.7            #쿨타임
const ATTACK_DAMAGE : int = 10

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var flashlight: PointLight2D = $Flashlight
@onready var game = get_tree().current_scene
@onready var camera : Camera2D = $Camera2D
@onready var anim_player = $"../AnimationPlayer"
@onready var Enemy = $"../Enemy"

const CONE_ANGLE_DEG = 30.0
const CONE_RADIUS = 120
const CONE_SOFTNESS = 0.2



func _ready() -> void:
	is_dashing = false
	global.focus_state = false
	position = global.checkpoint
	flashlight.texture = _create_cone_texture(CONE_RADIUS, CONE_ANGLE_DEG, CONE_SOFTNESS)
	flashlight.offset = Vector2.ZERO
	game.connect("focus_attacked", Callable(self, "focus_avoid"))
	game.connect("make_unfocus", Callable(self, "unfocus_avoid"))
	

func focus_avoid():
	temp_slowdown = global.slowdown
	if speed == SPEED and run_speed == RUN_SPEED:
		speed /= global.slowdown
		run_speed /= global.slowdown
		
	#camera.zoom = focused_zoom
	anim_player.play("focused_camera")

func unfocus_avoid():
	if speed != SPEED and run_speed != RUN_SPEED:
		await get_tree().create_timer(0.1).timeout
		speed *= temp_slowdown
		run_speed *= temp_slowdown
	
	#camera.zoom = unfocused_zoom
	anim_player.play("RESET")

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
	if is_dashing:
		velocity = dash_direction * 150
		move_and_slide()
		
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			velocity = Vector2.ZERO
	
	elif !global.focus_state:
		direction = Input.get_vector("move_a", "move_d", "move_w", "move_s")

	if is_attacking:
		attack_timer -= delta
		
		if attack_timer <= 0:
			is_attacking = false
		

	var is_sprinting = Input.is_action_pressed("sprint") and global.stamina > 0

	# ----------- [ stamina ] -------------
	if Input.is_action_pressed("sprint") and direction.length() > 0:
		global.stamina -= 50 * (delta / global.slowdown)
	else:
		global.stamina += 20 * (delta / global.slowdown)

	# ----------- [ anime ] -------------
	if direction != Vector2.ZERO:
		if is_sprinting:
			velocity = direction * run_speed
			anim.speed_scale = 2.0 / global.slowdown
		else:
			velocity = direction * speed
			anim.speed_scale = 1.0 / global.slowdown

		if direction.x > 0:
			anim.flip_h = false
		elif direction.x < 0:
			anim.flip_h = true

		anim.play("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		anim.speed_scale = 1.0 / global.slowdown
		anim.play("idle")

	move_and_slide()

func _process(delta: float) -> void:
	if global.get_flashlight:
		if global.light_charge <= 0:
			light_level = 0

		if light_level > 2:
			light_level = 0

		if light_level != 0:
			global.light_charge -= light_loss * (delta/ global.slowdown)
		else:
			global.light_charge += 5 * (delta/ global.slowdown)

		# ----------- [ flashlight state ] -------------
		match light_level:
			0:
				flashlight.visible = false
			1:
				flashlight.visible = true
				flashlight.texture_scale = 1.0
				flashlight.energy = 1.0
				light_loss = 0
			2:
				flashlight.texture_scale = 1.4
				flashlight.energy = 1.5
				light_loss = 15

		flashlight.rotation = (get_global_mouse_position() - global_position).angle()

func _input(event):
	if global.get_flashlight and event.is_action_pressed("turn_flashlight"):
		light_level += 1
		
		
	if event.is_action_pressed("mouse_left"):        #_physics_process에서 쿨타임 처리
		if !is_attacking:
			game.attack(ATTACK_DAMAGE)
			attack_timer = ATTACK_TIME
			is_attacking = true
		
	if event.is_action_pressed("ui_up"):       #적 활성화 기능 테스트
		global.enemy_enable = true
		
	if event.is_action_pressed("ui_down"):
		global.boss_enable = true
		
	if event.is_action_pressed("ui_right"):     
		game.focus_attack_player()
		
	if event.is_action_pressed("ui_select"):
		if global.focus_state:
			dash_direction = (global_position - Enemy.global_position).normalized()
			is_dashing = true
			dash_timer = DASH_TIME
			game.unfocusing()
			
