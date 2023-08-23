class_name Enum

enum Dir {
	UP, DOWN, LEFT, RIGHT
}

static func dir2vec(direction: Dir) -> Vector2:
	match direction:
		Dir.UP:
			return Vector2.UP
		Dir.DOWN:
			return Vector2.DOWN
		Dir.LEFT:
			return Vector2.LEFT
		Dir.RIGHT:
			return Vector2.RIGHT
	
	push_error("Unknown direction: " + str(direction))
	return Vector2.ZERO
