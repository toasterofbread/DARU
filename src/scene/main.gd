extends Control

func _ready():
	var window = get_window()
	window.size = Vector2(1280, 720)
	window.position = Vector2i(1920, 0) + (Vector2i(1920, 1080) - window.size) / 2

func _process(delta: float):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		var window = get_window()
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN
