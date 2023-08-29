extends Node
class_name Level

@export var pipe_transition_parents: Array[NodePath] = [NodePath(".")]
@export var song: AudioStream = null

func _ready():
	var used_identifiers: Array[String] = []
	for parent in pipe_transition_parents:
		for pipe in get_node(parent).get_children():
			if not pipe is PipeTransition:
				continue
			
			if pipe.identifier != null:
				assert(!used_identifiers.has(pipe.identifier), "Duplicate pipe identifier: " + pipe.identifier)
				used_identifiers.append(pipe.identifier)

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
