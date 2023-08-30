extends Node
class_name Level

@export var pipe_transition_parents: Array[NodePath] = [NodePath(".")]
@export var song: AudioStream = null
@export var camera_limits: CollisionShape2D = null

func _ready():
	var used_identifiers: Array[String] = []
	for parent in pipe_transition_parents:
		for pipe in get_node(parent).get_children():
			if not pipe is PipeTransition:
				continue
			
			if pipe.identifier != null:
				assert(!used_identifiers.has(pipe.identifier), "Duplicate pipe identifier: " + pipe.identifier)
				used_identifiers.append(pipe.identifier)

func init(mario: Mario):
	setCameraLimits(mario.camera, camera_limits)

func setCameraLimits(camera: Camera2D, shape: CollisionShape2D):
	if shape == null:
		camera.limit_top = -10000000
		camera.limit_bottom = 10000000
		camera.limit_left = -10000000
		camera.limit_right = 10000000
		return
	
	var rect: Rect2 = shape.shape.get_rect()
	rect.position += shape.global_position
	
	var sidebar_width: float = Sidebars.getBarWidth()
	
	camera.limit_top = rect.position.y
	camera.limit_bottom = rect.end.y
	camera.limit_left = rect.position.x - sidebar_width
	camera.limit_right = rect.end.x + sidebar_width

func start(mario: Mario):
	if song != null:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = song
		player.play()
		
		mario.ON_DEATH.connect(player.stop)

func getIdentifier() -> String:
	return scene_file_path.split("/")[-2]

func getPipe(identifier: String) -> PipeTransition:
	for parent in pipe_transition_parents:
		for pipe in get_node(parent).get_children():
			if not pipe is PipeTransition:
				continue
			
			if pipe.identifier == identifier:
				return pipe
	
	assert(false, identifier)
	return null
