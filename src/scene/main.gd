extends Control

func _process(delta: float):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		var window = get_window()
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN
