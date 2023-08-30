extends PullableCharacterBody2D

signal DAMAGE(type: Enum.DamageType)
signal STOMP(by: Node2D)

const GRAVITY: float = 700.0
const WALK_SPEED: float = 30.0

@export var stomp_sprite: AnimatedSprite2D
@export var stomp_animation: String = "stomp"
@export var moving: bool = true

var is_dead: bool = false
var direction: Enum.Dir = Enum.Dir.LEFT
var direction_changed_on_frame: bool = false
var damage_area: Area2D = Area2D.new()

func canBePulled(from: Enum.Dir, puller: Node2D) -> bool:
	if not super(from, puller):
		return false
	
	return from == Enum.Dir.LEFT or from == Enum.Dir.RIGHT

func stopPull() -> bool:
	var pull_direction: Enum.Dir = current_pull_direction
	if not super():
		return false
	
	direction = Enum.oppositeDir(pull_direction)
	return true

func _ready():
	super()
	
	assert(stomp_sprite.sprite_frames.has_animation(stomp_animation))
	
	add_child(VisibleOnScreenEnabler2D.new())
	_addDamageArea()
	
	SignalGroup.DAMAGEABLE.addNode(self)
	DAMAGE.connect(_onDamaged)
	
	SignalGroup.STOMPABLE.addNode(self)
	STOMP.connect(_onStomped)
	
	set_collision_mask_value(2, moving)

func _addDamageArea():
	for node in get_children():
		if node is CollisionShape2D:
			damage_area.add_child(node.duplicate())
	
	add_child(damage_area)
	damage_area.collision_layer = 0
	damage_area.collision_mask = 0
	damage_area.set_collision_mask_value(0, true)
	damage_area.body_entered.connect(_onDamageAreaBodyEntered)

func _onDamageAreaBodyEntered(body: PhysicsBody2D):
	if is_dead or body == current_puller:
		return
	
	if SignalGroup.DAMAGEABLE.containsNode(body):
		SignalGroup.DAMAGEABLE.emitSignal(body, [Enum.DamageType.ENEMY])

func _onDamaged(type: Enum.DamageType):
	queue_free()

func _onStomped(by: Node2D):
	if by == current_puller:
		return
	
	is_dead = true
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	
	stomp_sprite.play(stomp_animation)
	await stomp_sprite.animation_finished
	queue_free()

func _physics_process(delta: float):
	super(delta)
	
	if not moving:
		return
	
	if isBeingPulled():
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		return
	
	if is_on_wall():
		if not direction_changed_on_frame:
			direction_changed_on_frame = true
			direction = Enum.Dir.LEFT if direction == Enum.Dir.RIGHT else Enum.Dir.RIGHT
	else:
		direction_changed_on_frame = false
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.x = (Enum.dir2vec(direction) * WALK_SPEED).x
	
	move_and_slide()
