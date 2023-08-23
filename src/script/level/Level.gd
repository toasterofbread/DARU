extends Node
class_name Level

@export var pipe_transitions: Array[NodePath] = []

func _ready():
	var used_identifiers: Array[String] = []
	for path in pipe_transitions:
		var pipe = get_node(path)
		assert(is_instance_of(pipe, PipeTransition))
		
		if pipe.identifier != null:
			assert(!used_identifiers.has(pipe.identifier), "Duplicate pipe identifier: " + pipe.identifier)
			used_identifiers.append(pipe.identifier)

func getIdentifier() -> String:
	return scene_file_path.split("/")[-2]

func getPipe(identifier: String) -> PipeTransition:
	for path in pipe_transitions:
		var pipe: PipeTransition = get_node(path)
		if pipe.identifier == identifier:
			return pipe
	
	assert(false, identifier)
	return null
