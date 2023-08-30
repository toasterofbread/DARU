extends CanvasLayer

const ANIMATION_DURATION: float = 1.0
const NES_SCREEN_SIZE: Vector2 = Vector2(256, 240)
const FULL_SCREEN_SIZE: Vector2 = Vector2(426, 240)

@onready var _spacer_control: Control = $HBoxContainer/Spacer
var _current_tween: Tween = null

func _ready():
	_spacer_control.custom_minimum_size.x = NES_SCREEN_SIZE.x

func getBarWidth() -> float:
	return (FULL_SCREEN_SIZE.x - 256) * 0.5

func showBars():
	if _current_tween != null:
		_current_tween.stop()

	_current_tween = create_tween()
	_current_tween.tween_property(_spacer_control, "custom_minimum_size:x", NES_SCREEN_SIZE.x, ANIMATION_DURATION)

func hideBars():
	if _current_tween != null:
		_current_tween.stop()
	
	_current_tween = create_tween()
	_current_tween.tween_property(_spacer_control, "custom_minimum_size:x", FULL_SCREEN_SIZE.x, ANIMATION_DURATION)
