extends CharacterBody2D

const SPEED = 50.0
const RUN_SPEED = 75.0

var light_level = 1  #flashligth bright level ( state )
var light_loss = 5    #flash light battery loss 

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_a", "move_d", "move_w", "move_s")
	var is_sprinting = Input.is_action_pressed("sprint") and global.stamina > 0

#----------- [ stamina ] -------------#
	if Input.is_action_pressed("sprint") and direction.length() > 0:
		global.stamina -= 20 * delta
	else:
		global.stamina += 10 * delta

	#global.stamina = clamp(global.stamina, 0.0, 100.0)
#----------------------- -------------#

#----------- [ anime ] -------------#
	if direction != Vector2.ZERO:
		if is_sprinting:
			velocity = direction * RUN_SPEED
			anim.speed_scale = 2.0  # if run, anim speed = x2
		else:
			velocity = direction * SPEED
			anim.speed_scale = 1.0  # if walk, normal speed anim

		if direction.x > 0:
			anim.flip_h = false
		elif direction.x < 0:
			anim.flip_h = true

		anim.play("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		anim.speed_scale = 1.0
		anim.play("idle")
#-----------------------------------#
	move_and_slide()
		

	
func _process(delta: float) -> void:
	if global.light_charge <= 0:     #if battery 0, off
		light_level = 0
		
	if light_level > 2:
		light_level = 0	
	
	if light_level != 0:
		global.light_charge -= light_loss * delta
	else:
		global.light_charge += 5 * delta
	
	#----------- [ flashlight state & function ] -------------#
	match light_level:
		0:
			$Flashlight.enabled = false
		1:
			$Flashlight.enabled = true	
			$Flashlight.texture_scale = 3.0
			light_loss = 5
		2:
			$Flashlight.texture_scale = 4.5
			light_loss = 15
	#--------------------------------------------------#

func _input(event):   #work only when called
	if event.is_action_pressed("turn_flashlight"):
		light_level += 1
	
		
	
