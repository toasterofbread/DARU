extends CharacterBody2D
class_name PullableCharacterBody2D

signal PULLER_CHANGED

enum PullType {
	LIGHT, HEAVY, AXIS
}

@export var type: PullType = PullType.LIGHT
@export var sprite: AnimatedSprite2D

var current_puller: Node2D = null
var current_pull_direction: Enum.Dir = null

func isHeavy() -> bool:
	return type == PullType.HEAVY or type == PullType.AXIS

func _ready():
	assert(sprite != null)
	set_collision_layer_value(Enum.PhysicsLayer.PULLABLE, true)

func isBeingPulled() -> bool:
	return current_puller != null

func canBePulled(from: Enum.Dir, puller: Node2D) -> bool:
	return true

func beginPull(from: Enum.Dir, puller: Node2D) -> bool:
	if puller == current_puller:
		return false
	
	current_puller = puller
	current_pull_direction = from
	
	z_index = 1
	
	PULLER_CHANGED.emit()
	return true

func stopPull() -> bool:
	if current_puller == null:
		return false
	
	current_puller = null
	current_pull_direction = null
	return true

func changePullDirection(from: Enum.Dir):
	assert(current_puller != null)
	current_pull_direction = from

func _getSpriteRect() -> Rect2:
	var texture: Texture2D = sprite.sprite_frames.get_frame_texture(
		sprite.animation,
		sprite.frame
	)
	
	return Rect2(
		sprite.global_position - global_position,
		texture.get_size().rotated(sprite.global_rotation).abs()
	)

func getMoveTarget() -> Vector2:
	assert(isBeingPulled())
	
	var sprite_rect: Rect2 = _getSpriteRect()
	var target: Vector2 = current_puller.global_position
	
	var pull_vector: Vector2 = Enum.dir2vec(current_pull_direction)
	var separation: float = _getSeparationFromPuller()
	
	if Enum.isHorizontalDir(current_pull_direction):
		target.x += ((sprite_rect.size.x * 0.5) + separation - sprite_rect.position.x) * -pull_vector.x
	else:
		target.y += ((sprite_rect.size.y * 0.5) + separation - sprite_rect.position.y) * -pull_vector.y
	
	return target

func _getSeparationFromPuller() -> float:
	if isHeavy():
		return 4
	else:
		return 0

func _physics_process(delta: float):
	if not isBeingPulled():
		return
	
	match type:
		PullType.LIGHT:
			_lightPhysicsProcess(delta)
		PullType.HEAVY:
			_heavyPhysicsProcess(delta)
		PullType.AXIS:
			_axisPhysicsProcess(delta)

func _lightPhysicsProcess(delta: float):
	var target: Vector2 = getMoveTarget()
	global_position = target

func _heavyPhysicsProcess(delta: float):
	var target: Vector2 = getMoveTarget()
	
#	var speed: float
#	if sign(target.x - center) != sign(current_puller.global_position.x - center):
#		speed = 10
#	else:
#		speed = 50
	
	velocity = (target - global_position) * 50
	
	move_and_slide()

func _axisPhysicsProcess(delta: float):
	var target: Vector2 = getMoveTarget()
	
	if Enum.isHorizontalDir(current_pull_direction):
		global_position.x = target.x
	else:
		global_position.y = target.y
