@tool
extends PullableCharacterBody2D

const SEGMENT_HORIZ: Texture2D = preload("res://src/resource/sprite/object/pipe/segment_horiz.png")
const SEGMENT_VERT: Texture2D = preload("res://src/resource/sprite/object/pipe/segment_vert.png")

@export var direction: Enum.Dir = Enum.Dir.UP :
	set = _setDirection
@export var flip: bool = false :
	set = _setFlip

@onready var original_position: Vector2 = position
@onready var segment_rect: TextureRect = $SegementContainer/SegementRect
@onready var segement_collision_shape: CollisionShape2D = $SegementContainer/SegmentCollisionShape
@onready var mouth_sprite: AnimatedSprite2D = $MouthSprite

func canBePulled(from: Enum.Dir, puller: Node2D) -> bool:
	if not super(from, puller):
		return false
	
	return from == direction

func _ready():
	type = PullType.AXIS
	
	if Engine.is_editor_hint():
		return
	
	_setDirection(direction)
	_setFlip(flip)

func _process(delta: float):
	if Engine.is_editor_hint():
		return
	
	var base_length: float = segment_rect.texture.get_size().y
	var movement: float
	
	var direction_vector: Vector2 = Enum.dir2vec(direction)
	
	if direction_vector.x != 0:
		movement = (position.x - original_position.x) * direction_vector.x
	else:
		movement = (position.y - original_position.y) * direction_vector.y
	
	segment_rect.size.y = base_length + movement
	segement_collision_shape.position.y = movement * 0.5
	
	var shape: RectangleShape2D = segement_collision_shape.shape
	shape.size.y = max(0, base_length + movement)

func _setDirection(value: Enum.Dir):
	direction = value
	rotation = Enum.dir2vec(direction).angle_to(Vector2.UP) * -1
	
	if not is_inside_tree():
		return
	
	if Enum.isHorizontalDir(direction):
		mouth_sprite.play("horizontal")
		segment_rect.texture = SEGMENT_HORIZ
	else:
		mouth_sprite.play("vertical")
		segment_rect.texture = SEGMENT_VERT

func _setFlip(value: bool):
	flip = value
	if not is_inside_tree():
		return
	
	mouth_sprite.flip_h = flip
	segment_rect.flip_h = flip

func beginPull(from: Enum.Dir, puller: Node2D) -> bool:
	if not super(from, puller):
		return false
	
	set_collision_layer_value(Enum.PhysicsLayer.WORLD, false)
	
	return true

func stopPull() -> bool:
	if not super():
		return false
	
	set_collision_layer_value(Enum.PhysicsLayer.WORLD, true)
	return true
