extends Control

func _ready():
	var window = get_window()
	window.size = Vector2(1280, 720)
	window.position = Vector2i(1920, 0) + (Vector2i(1920, 1080) - window.size) / 2
