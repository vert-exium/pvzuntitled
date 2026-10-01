extends Node2D

var open: bool = false
var initialPosX: float = 0.0
var noCooldowns: bool = false
func _ready() -> void:
	initialPosX = position.x
	add_to_group("debug_menu")

func _on_toggle_button_pressed() -> void:
	var pos_tween = create_tween()
	
	if open:
		open = false
		$Control/toggleButton.text = "<"
		pos_tween.tween_property(self, "position:x", initialPosX, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	else:
		open = true
		$Control/toggleButton.text = ">"
		pos_tween.tween_property(self, "position:x", initialPosX - 850.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_energy_button_pressed() -> void:
	RunState.current_energy = $Control/energySpinBox.value

func _on_path_check_toggled(toggled_on: bool) -> void:
	get_tree().debug_paths_hint = toggled_on
	_force_redraw_of_type(get_tree().root, "Path2D")

func _on_collision_check_toggled(toggled_on: bool) -> void:
	get_tree().debug_collisions_hint = toggled_on
	_force_redraw_of_type(get_tree().root, "CollisionShape2D")
	_force_redraw_of_type(get_tree().root, "CollisionPolygon2D")
	_force_redraw_of_type(get_tree().root, "RayCast2D") 

func _force_redraw_of_type(node: Node, target_class: String) -> void:
	if node.is_class(target_class) and node.has_method("queue_redraw"):
		node.queue_redraw()
	
	for child in node.get_children():
		_force_redraw_of_type(child, target_class)

func _on_cooldown_check_toggled(toggled_on: bool) -> void:
	DebugMenu.noCooldowns = toggled_on
	print("DebugMenu.noCooldowns: " + str(DebugMenu.noCooldowns))
