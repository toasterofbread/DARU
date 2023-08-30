@tool
extends Area2D
class_name PipeTransition

@export var identifier: String = null
@export var direction: Enum.Dir = Enum.Dir.DOWN : 
	set(value):
		direction = value
		_rotateToDirection(direction)

@export var destination_level: String = null
@export var destination_pipe: String = null

@onready var travel_sound_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var collision_shape: RectangleShape2D = $CollisionShape2D.shape

func canBeEntered(mario: Mario, pad_vector: Vector2) -> bool:
	if destination_level == null:
		return false
	if direction != Enum.Dir.DOWN and !mario.is_on_floor():
		return false
	
	var dir_vector: Vector2 = Enum.dir2vec(direction) * -1
	if dir_vector.x != 0:
		return dir_vector.x == sign(pad_vector.x)
	else:
		return dir_vector.y == sign(pad_vector.y)

func enterPipe(mario: Mario):
	assert(destination_level != null)
	
	mario.last_entered_pipe = self
	await _animateMarioTransition(mario, false)
	LevelManager.switchToLevel(destination_level, destination_pipe)

func exitPipe(mario: Mario):
	await _animateMarioTransition(mario, true, mario.last_entered_pipe == self)

func _animateMarioTransition(mario: Mario, exiting: bool, in_place: bool = false):
	mario.in_cutscene = true
	mario.z_index = -1
	
	var dir_vector: Vector2 = Enum.dir2vec(direction)
	if not exiting:
		dir_vector *= -1
	
	if not in_place:
		if exiting:
			mario.global_position = global_position - (Mario.SIZE * dir_vector * 0.5)
		
		if dir_vector.x != 0:
			mario.playAnimation("run")
			if exiting:
				mario.position.y += (collision_shape.size.x - Mario.SIZE.y) * 0.5
		else:
			mario.playAnimation("stand")
	
	if dir_vector.x != 0:
		mario.facing = Enum.Dir.LEFT if dir_vector.x < 0 else Enum.Dir.RIGHT
	
	travel_sound_player.play()
	
	var tween = create_tween()
	await tween.tween_property(
		mario, 
		"global_position", 
		mario.global_position + (Mario.SIZE * dir_vector), 
		travel_sound_player.stream.get_length()
	).finished
	
	if exiting:
		mario.z_index = 0
		mario.in_cutscene = false

func _ready():
	if Engine.is_editor_hint():
		return
	
	# If debugging, check if the destination level exists
	if OS.is_debug_build() and destination_level != null:
		LevelManager.getLevel(destination_level, true)
	
	body_entered.connect(_onBodyEntered)
	body_exited.connect(_onBodyExited)

func _onBodyEntered(body: PhysicsBody2D):
	if body is Mario:
		body.onEnteredPipeTransitionArea(self)

func _onBodyExited(body: PhysicsBody2D):
	if body is Mario:
		body.onExitedPipeTransitionArea(self)

func _rotateToDirection(dir: Enum.Dir):
	var angle = Enum.dir2vec(dir).angle_to(Vector2.UP)
	rotation = angle * -1
