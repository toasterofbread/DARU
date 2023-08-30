extends CharacterBody2D
class_name Mario

const SKID_MIN_SPEED: float = 100.0
const SIZE: Vector2 = Vector2(16, 16)

signal DAMAGE(type: Enum.DamageType)
signal ON_DEATH
signal ON_STOMP
signal ON_PULLING_CHANGED

var physics = preload("res://src/scene/character/mario/Physics.gd").new()

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var pull_area: Area2D = $PullArea

@onready var sound_jump: AudioStreamPlayer = $Sounds/Jump
@onready var sound_die: AudioStreamPlayer = $Sounds/Die
@onready var sound_stomp: AudioStreamPlayer = $Sounds/Stomp

var is_dead: bool = false
var in_cutscene: bool = false :
	set(value):
		in_cutscene = value
		if in_cutscene:
			velocity = Vector2.ZERO
var facing: Enum.Dir :
	set = _setFacing,
	get = _getFacing
var last_entered_pipe: PipeTransition = null
var pulling_object: PullableCharacterBody2D = null

var _turn_direction: int = 0
var _overlapping_pipes: Array[PipeTransition] = []
var _stomp_on_next_frame: Array[PhysicsBody2D] = []

func playAnimation(name: String):
	if pulling_object != null and pulling_object.isHeavy():
		sprite.play("pull_heavy")
	else:
		sprite.play(name)

func isSkidding() -> bool:
	return sprite.animation == "turn"

func onJumpStarted():
	sound_jump.play()

func onEnteredPipeTransitionArea(pipe: PipeTransition):
	_overlapping_pipes.append(pipe)

func onExitedPipeTransitionArea(pipe: PipeTransition):
	_overlapping_pipes.erase(pipe)

func _onDamaged(type: Enum.DamageType):
	_onKilled()

func _onKilled():
	is_dead = true
	set_process(false)
	playAnimation("die")
	
	ON_DEATH.emit()
	
	sound_die.play()
	await sound_die.finished

func _onStompAreaBodyEntered(body: PhysicsBody2D):
	if is_dead or velocity.y <= 0:
		return
	
	if SignalGroup.STOMPABLE.containsNode(body) and !_stomp_on_next_frame.has(body):
		# Applies stomp on next frame (if still alive)
		# Prevents both parties dying on a simultaneous collision
		_stomp_on_next_frame.append(body)

func _setFacing(value: Enum.Dir):
	sprite.flip_h = value == Enum.Dir.LEFT
	
	if pulling_object != null:
		pulling_object.changePullDirection(
			value if pulling_object.isHeavy() else Enum.oppositeDir(value)
		)

func _getFacing():
	return Enum.Dir.LEFT if sprite.flip_h else Enum.Dir.RIGHT

func _ready():
	add_child(physics)
	
	SignalGroup.DAMAGEABLE.addNode(self)
	DAMAGE.connect(_onDamaged)

func _process(_delta: float):
	if in_cutscene:
		return
	
	var pad_vector: Vector2 = Input.get_vector(
		"pad_left", "pad_right", "pad_up", "pad_down"
	)
	
	if pulling_object == null:
		for pipe in _overlapping_pipes:
			if pipe.canBeEntered(self, pad_vector):
				pipe.enterPipe(self)
				return
	
	var pulling_heavy: bool = pulling_object != null and pulling_object.isHeavy()
	
	if !is_on_floor():
		playAnimation("jump")
	else:
		var pad_x = pad_vector.x
		if pad_x != 0 and not pulling_heavy:
			facing = Enum.Dir.LEFT if pad_x < 0 else Enum.Dir.RIGHT
		
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
	
	if Input.is_action_pressed("pull"):
		if pulling_object == null:
			var direction: Enum.Dir
			if pad_vector == Vector2.ZERO:
				direction = Enum.vec2dir(velocity * -1)
			else:
				direction = Enum.vec2dir(pad_vector * -1)
			
			for pullable in pull_area.get_overlapping_bodies():
				if pullable.canBePulled(direction, self):
					pullable.beginPull(direction, self)
					pulling_object = pullable
					ON_PULLING_CHANGED.emit()
					
					if pullable.type == PullableCharacterBody2D.PullType.AXIS:
						facing = Enum.Dir.LEFT if facing == Enum.Dir.RIGHT else Enum.Dir.RIGHT
					
					break
	
	elif pulling_object != null:
		pulling_object.stopPull()
		pulling_object = null
		ON_PULLING_CHANGED.emit()

func _physics_process(delta: float):
	if is_dead or _stomp_on_next_frame.is_empty():
		return
	
	for body in _stomp_on_next_frame:
		SignalGroup.STOMPABLE.emitSignal(body, [self])
		ON_STOMP.emit()
	
	_stomp_on_next_frame.clear()
	sound_stomp.play()

func _onPullAreaBodyExited(body: PhysicsBody2D):
	if body == pulling_object:
		pulling_object.stopPull()
		pulling_object = null
		ON_PULLING_CHANGED.emit()
