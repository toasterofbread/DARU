extends Node

const WALK_SPEED: float = 150.0
const RUN_SPEED: float = 250.0
const ACCELERATION: float = 160.0
const SKID_DECELERATION: float = 400.0
const AIR_DECELERATION: float = 300.0

const FALL_SPEED: float = 430.0
const JUMP_SPEED: float = -200.0
const JUMP_POWERED_TIME: float = 0.2

const JUMP_INPUT_BUFFER: float = 0.1
const COYOTE_TIME: float = 0.1

const GRAVITY: float = 700.0
const JUMP_GRAVITY: float = 60.0

@onready var mario: CharacterBody2D = get_parent()

var air_time: float = 0.0
var time_since_jump_input: float = null
var jumped: bool = false

func _physics_process(delta: float):
	if mario.in_cutscene:
		return
	
	if Input.is_action_just_pressed("jump"):
		time_since_jump_input = 0.0
	elif time_since_jump_input != null:
		time_since_jump_input += delta
	
	if mario.is_on_floor():
		air_time = 0.0
		jumped = false
		
		# Begin jump
		if time_since_jump_input != null and time_since_jump_input < JUMP_INPUT_BUFFER:
			jumped = true
			time_since_jump_input = null
			mario.velocity.y = JUMP_SPEED
	else:
		air_time += delta
		
		var jump_pressed = Input.is_action_pressed("jump")
		
		if jump_pressed and (
			# Continue jump if already jumped and within powered time
			(jumped and air_time < JUMP_POWERED_TIME) 
			
			# Begin jump if not already started and within coyote time
			or (!jumped and air_time < COYOTE_TIME)
		):
			mario.velocity.y = JUMP_SPEED
			if !jumped:
				air_time = 0
				jumped = true
		else:
			# Apply gravity
			mario.velocity.y = move_toward(mario.velocity.y, FALL_SPEED, GRAVITY * delta)
	
	var pad_x: float = Input.get_axis("pad_left", "pad_right")
	if pad_x != 0:
		if mario.is_on_floor():
			# Apply speed and acceleration based on run/skid state
			var speed = RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
			var acceleration = SKID_DECELERATION if mario.isSkidding() else ACCELERATION
			
			mario.velocity.x = move_toward(mario.velocity.x, speed * pad_x, acceleration * delta)
		
		else:
			# Air movement
			var acceleration = ACCELERATION if mario.velocity.x == 0 or sign(pad_x) == sign(mario.velocity.x) else AIR_DECELERATION
			mario.velocity.x = move_toward(mario.velocity.x, WALK_SPEED * pad_x, ACCELERATION * delta)
	
	else:
		# Decelerate to zero
		mario.velocity.x = move_toward(mario.velocity.x, 0, ACCELERATION * delta)
	
	mario.move_and_slide()