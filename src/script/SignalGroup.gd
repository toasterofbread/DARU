extends Node

var DAMAGEABLE := SignalGroupInstance.new(
	"DAMAGEABLE",
	"DAMAGE",
	[
		TYPE_INT # type: Enum.DamageType
	]
)

var STOMPABLE := SignalGroupInstance.new(
	"STOMPABLE",
	"STOMP"
)

class SignalGroupInstance:
	var name: String
	var signal_name: String
	var signal_args: Array[int] = []
	
	var _added_nodes: Array[Node] = []
	
	func _init(name: String, signal_name: String, signal_args: Array[int] = []):
		self.name = name
		self.signal_name = signal_name
		self.signal_args = signal_args
	
	func emitSignal(on_node: Node, args: Array):
		if OS.is_debug_build():
			assert(on_node == null or containsNode(on_node), "Node %s not in group %s" % [str(on_node), name])
			assert(args.size() == signal_args.size())
			
			for i in signal_args.size():
				assert(typeof(args[i]) == signal_args[i], str(i))
		
		if _added_nodes.is_empty():
			return
		
		var call_args: Array = [signal_name] + args
		var nodes: Array = [on_node] if on_node != null else _added_nodes
		
		for node in nodes:
			node.emit_signal.callv(call_args)
	
	func containsNode(node: Node) -> bool:
		return _added_nodes.has(node)
	
	func addNode(node: Node):
		if containsNode(node):
			return
		_added_nodes.append(node)
		
		if OS.is_debug_build():
			assert(
				node.has_signal(signal_name),
				"Node %s does not contain required signal '%s' for group %s" % [
					str(node), signal_name, name
				]
			)
			
			for node_signal in node.get_signal_list():
				if node_signal["name"] != signal_name:
					continue
					
				var args = node_signal["args"]
				assert(
					args.size() == signal_args.size(),
					"Signal '%s' on node %s has an incorrect amount of args (%d instead of %d) for group %s" % [
						signal_name, str(node), args.size(), signal_args.size(), name
					]
				)
				
#				for i in signal_args.size():
#					assert(
#						signal_args[i] == args[i]["type"],
#						"Argument %d of method '%s' on node %s is of incorrect type (%d instead of %d) for group %s" % [
#							i, signal_name, str(node), args[i]["type"], signal_args[i], name
#						]
#					)
				
				break
