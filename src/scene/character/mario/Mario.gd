extends CharacterBody2D
class_name Mario

const SKID_MIN_SPEED: float = 100.0
const SIZE: Vector2 = Vector2(16, 16)

var physics = preload("res://src/scene/character/mario/Physics.gd").new()
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var in_cutscene: bool = false :
	set(value):
		in_cutscene = value
		if in_cutscene:
			velocity = Vector2.ZERO
var facing_left: bool :
	set(value):
		sprite.flip_h = value
	get:
		return sprite.flip_h
var last_entered_pipe: PipeTransition = null

var _turn_direction: int = 0
var _overlapping_pipes: Array[PipeTransition] = []

func playAnimation(name: String):
	sprite.play(name)

func isSkidding() -> bool:
	return sprite.animation == "turn"

func onEnteredPipeTransitionArea(pipe: PipeTransition):
	_overlapping_pipes.append(pipe)

func onExitedPipeTransitionArea(pipe: PipeTransition):
	_overlapping_pipes.erase(pipe)

func _ready():
	add_child(physics)

func _process(_delta: float):
	if in_cutscene:
		return
	
	var pad_vector: Vector2 = Input.get_vector("pad_left", "pad_right", "pad_up", "pad_down")
	
	for pipe in _overlapping_pipes:
		if pipe.canBeEntered(self, pad_vector):
			pipe.enterPipe(self)
			return
	
	if !is_on_floor():
		playAnimation("jump")
	else:
		var pad_x = pad_vector.x
		if pad_x != 0:
			sprite.flip_h = pad_x < 0
		
		if velocity.x != 0:
			var pad_sign = sign(Input.get_axis("pad_left", "pad_right"))
			if pad_sign != 0 and pad_sign != sign(velocity.x) and abs(velocity.x) >= SKID_MIN_SPEED:
				_turn_direction = pad_sign
				playAnimation("turn")
			
			elif pad_x == 0 or sign(pad_x) == sign(velocity.x):
				playAnimation("run")
			
			elif sprite.animation == "jump":
				playAnimation("run")
		else:
			_turn_direction = 0
			if sprite.frame == 0:
				playAnimation("stand")
