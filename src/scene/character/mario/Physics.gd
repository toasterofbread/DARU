extends Node

const DEATH_GRAVITY: float = 500.0

@onready var mario: Mario = get_parent()

var air_time: float = 0.0
var time_since_jump_input: float = null
var jumped: bool = false
var values: Dictionary = MarioPhysicsValues.NORMAL

func _ready():
	mario.ON_DEATH.connect(_onMarioDeath)
	mario.ON_STOMP.connect(_onMarioStomp)
	mario.ON_PULLING_CHANGED.connect(_onMarioPullingChanged)

func _onMarioDeath():
	mario.collision_layer = 0
	mario.collision_mask = 0
	
	mario.in_cutscene = true
	mario.velocity = Vector2(0, 0)
	
	get_tree().create_timer(0.6).timeout.connect(
		func(): 
			mario.velocity = Vector2(0, -200)
			mario.in_cutscene = false
	)

func _onMarioStomp():
	jumped = false
	_startJump(true)

func _onMarioPullingChanged():
	var pulling: PullableCharacterBody2D = mario.pulling_object
	if pulling == null:
		values = MarioPhysicsValues.NORMAL
		return
	
	match pulling.type:
		PullableCharacterBody2D.PullType.LIGHT:
			values = MarioPhysicsValues.PULL_LIGHT
		PullableCharacterBody2D.PullType.HEAVY:
			values = MarioPhysicsValues.PULL_HEAVY
		PullableCharacterBody2D.PullType.AXIS:
			values = MarioPhysicsValues.PULL_AXIS

func _startJump(stomp: bool = false):
	if values["JUMP_SPEED"] >= 0 or values["JUMP_POWERED_TIME"] <= 0:
		jumped = false
		return
	
	mario.velocity.y = values["JUMP_SPEED"]
	if not jumped:
		jumped = true
		time_since_jump_input = 0.0
		
		if not stomp:
			mario.onJumpStarted()
		elif Input.is_action_pressed("jump"):
			air_time = 0.0

func _physics_process(delta: float):
	if mario.in_cutscene:
		return
	
	if mario.is_dead and mario.velocity.y != 0:
		mario.velocity.y = move_toward(mario.velocity.y, values["FALL_SPEED"], DEATH_GRAVITY * delta)
		mario.move_and_slide()
		return
	
	if Input.is_action_just_pressed("jump"):
		time_since_jump_input = 0.0
	elif time_since_jump_input != null:
		time_since_jump_input += delta
	
	if mario.is_on_floor():
		air_time = 0.0
		jumped = false
		
		# Begin jump
		if time_since_jump_input != null and time_since_jump_input < values["JUMP_INPUT_BUFFER"]:
			_startJump()
	else:
		air_time += delta
		
		var jump_pressed = Input.is_action_pressed("jump")
		
		if jump_pressed and (
			# Continue jump if already jumped and within powered time
			(jumped and air_time < values["JUMP_POWERED_TIME"]) 
			
			# Begin jump if not already started and within coyote time
			or (!jumped and air_time < values["COYOTE_TIME"])
		):
			_startJump()
		else:
			# Apply gravity
			mario.velocity.y = move_toward(mario.velocity.y, values["FALL_SPEED"], values["GRAVITY"] * delta)
	
	var pad_x: float = Input.get_axis("pad_left", "pad_right")
	if pad_x != 0:
		var max_speed = values["RUN_SPEED"] if Input.is_action_pressed("run") else values["WALK_SPEED"]
		
		if mario.is_on_floor():
			# Apply speed and acceleration based on run/skid state
			var acceleration = values["SKID_DECELERATION"] if mario.isSkidding() else values["ACCELERATION"]
			
			mario.velocity.x = move_toward(mario.velocity.x, max_speed * pad_x, acceleration * delta)
		
		else:
			# Air movement
			if abs(max_speed) > abs(mario.velocity.x) or sign(pad_x) != sign(mario.velocity.x):
				var acceleration = values["ACCELERATION"] if mario.velocity.x == 0 or sign(pad_x) == sign(mario.velocity.x) else values["AIR_DECELERATION"]
				mario.velocity.x = move_toward(mario.velocity.x, max_speed * pad_x, acceleration * delta)
	
	else:
		# Decelerate to zero
		mario.velocity.x = move_toward(mario.velocity.x, 0, values["ACCELERATION"] * delta)
	
	mario.move_and_slide()
