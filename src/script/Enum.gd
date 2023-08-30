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

static func vec2dir(vector: Vector2) -> Dir: # or null
	vector = vector.sign()
	
	if (vector.x != 0 and vector.y != 0) or vector == Vector2.ZERO:
		return null
	
	if vector.x == 1:
		return Dir.RIGHT
	elif vector.x == -1:
		return Dir.LEFT
	elif vector.y == 1:
		return Dir.DOWN
	else:
		return Dir.UP

static func oppositeDir(direction: Dir) -> Dir:
	match direction:
		Dir.LEFT:
			return Dir.RIGHT
		Dir.RIGHT:
			return Dir.LEFT
		Dir.UP:
			return Dir.DOWN
		Dir.DOWN:
			return Dir.UP
		null:
			return null
	
	push_error("Unknown direction: " + str(direction))
	return null

static func isHorizontalDir(direction: Dir) -> bool:
	return direction == Dir.LEFT or direction == Dir.RIGHT

enum DamageType {
	ENEMY, OOB
}

enum PhysicsLayer {
	MARIO, ENEMY, WORLD, ITEM, PIPETRANSITION, DEATHAREA, PULLABLE
}
