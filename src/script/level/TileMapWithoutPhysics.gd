extends TileMap

@export var disable_physics: bool = true :
	set(value):
		disable_physics = value
		if disable_physics:
			disablePhysics()
		else:
			enablePhysics()

var _layers: Array[PhysicsLayer] = []

func _init():
	for layer in tile_set.get_physics_layers_count():
		_layers.append(PhysicsLayer.new(tile_set, layer))
	tile_set = tile_set.duplicate(true)
	
	if disable_physics:
		disablePhysics()

func disablePhysics():
	for layer in tile_set.get_physics_layers_count():
		tile_set.set_physics_layer_collision_layer(0, layer)
		tile_set.set_physics_layer_collision_mask(0, layer)

func enablePhysics():
	for layer in tile_set.get_physics_layers_count():
		_layers[layer].apply(tile_set, layer)

class PhysicsLayer:
	var layer: int
	var mask: int
	
	func _init(tileset: TileSet, layer_index: int):
		layer = tileset.get_physics_layer_collision_layer(layer_index)
		mask = tileset.get_physics_layer_collision_mask(layer_index)
	
	func apply(tileset: TileSet, layer_index: int):
		tileset.set_physics_layer_collision_layer(layer_index, layer)
		tileset.set_physics_layer_collision_mask(layer_index, mask)
