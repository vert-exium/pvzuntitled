extends AudioStreamPlayer

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node == get_tree().current_scene:
		var scene_file = node.scene_file_path.to_lower()
		if "level" in scene_file:
			if playing:
				stop()
		else:
			if not playing:
				play()
