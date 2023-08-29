extends Node

const LEVELS_DIRECTORY = "res://src/scene/level/"
const TRANSITION_SCENE = preload("res://src/scene/ui/level_transition/LevelTransition.tscn")

const STARTING_LEVEL: String = "1-1"
const STARTING_PIPE: String = "a"

var current_level: Level = null
var levels: Dictionary = {} # <String, PackedScene>
var mario: Mario = preload("res://src/scene/character/mario/Mario.tscn").instantiate()

func _ready():
	# Load levels from LEVELS_DIRECTORY
	levels = loadLevels()
	
	# Begin starting level
	switchToLevel(STARTING_LEVEL, STARTING_PIPE)

func switchToLevel(level_name: String, pipe_identifier: String):
	var level: PackedScene = getLevel(level_name, true)
	var is_new_level: bool = true
	
	if current_level != null:
		if level_name == current_level.getIdentifier():
			is_new_level = false
		else:
			current_level.remove_child(mario)
			current_level.queue_free()
	
	if is_new_level:
		var transition = TRANSITION_SCENE.instantiate()
		add_child(transition)
		
		if is_new_level:
			await transition.playTransition(level_name, pipe_identifier)
		else:
			await transition.playTransition()
		
		current_level = level.instantiate()
		add_child(current_level)
		
		transition.queue_free()
		
		current_level.add_child(mario)
	
	if pipe_identifier != null:
		var pipe: PipeTransition = current_level.getPipe(pipe_identifier)
		await pipe.exitPipe(mario)
		
		await get_tree().create_timer(0.25).timeout
	
	if is_new_level:
		current_level.start(mario)

func getLevel(level_name: String, assert_exists: bool = false) -> PackedScene:
	var level = levels.get(level_name)
	if assert_exists:
		assert(level != null, "Nonexistent level: " + level_name)
	return level

func loadLevels() -> Dictionary:
	var loaded: Dictionary = {}
	
	var levels_dir = DirAccess.open(LEVELS_DIRECTORY)
	for dir in levels_dir.get_directories():
		var scene_path = LEVELS_DIRECTORY + dir + "/level.tscn"
		
		var scene = load(scene_path)
		assert(scene != null, scene_path)
		
		loaded[dir] = scene
	
	return loaded
