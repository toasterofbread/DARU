extends Area2D
class_name DeathArea

func _onBodyEntered(body: PhysicsBody2D):
	if SignalGroup.DAMAGEABLE.containsNode(body):
		SignalGroup.DAMAGEABLE.emitSignal(body, [Enum.DamageType.OOB])
