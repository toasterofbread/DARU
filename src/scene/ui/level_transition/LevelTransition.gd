extends Control

@onready var level_label: Label = $CanvasLayer/CenterContainer/Label

func playTransition(level_name: String = null, pipe_identifier: String = null):
	if level_name != null:
		level_label.text = level_name
	else:
		level_name = null
	
	await get_tree().create_timer(0.75).timeout
