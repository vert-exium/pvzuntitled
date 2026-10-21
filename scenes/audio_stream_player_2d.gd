extends AudioStreamPlayer2D

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
#when a scene is any scene that isnt level, plays music
#if it IS level.tscn then stop the music and start playing the level music
func _on_node_added(node: Node) -> void:
	if node == get_tree().current_scene:
		var scene_file = node.scene_file_path.to_lower()
		if "level" in scene_file:
			if playing:
				stop()
		else:
			if not playing:
				play()
