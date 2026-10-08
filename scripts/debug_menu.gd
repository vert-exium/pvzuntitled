extends Node2D

# Script for the debug menu

# A variable which tracks whether the
# menu is currently open or not.
var open: bool = false
# Tracks the initial (closed) X position.
var initialPosX: float = 0.0
# A bool which tracks whether to apply
# unit cooldowns or not
var noCooldowns: bool = false

# When the script starts, sets the initial 
# position to it's current position. Also 
# adds the node to the debug menu group.
func _ready() -> void:
	initialPosX = position.x
	add_to_group("debug_menu")

# When the toggle button is pressed, checks if the menu is open.
# If so, tweens the position to the initial position, changes the text, and sets open to false.
# Otherwise, tweens it open, changes the text, and sets open to true.
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

# When the energy button is pressed, updated
# the energy number to the requested value.
func _on_energy_button_pressed() -> void:
	RunState.current_energy = $Control/energySpinBox.value

# When the path view button is pressed,
# turns the debug value on or off. Also
# forces the engine to redraw all paths so 
# they're visible or they disappear. 

func _on_path_check_toggled(toggled_on: bool) -> void:
	get_tree().debug_paths_hint = toggled_on
	_force_redraw_of_type(get_tree().root, "Path2D")

# When the collision check is toggled, turns the debug
# value on or off. Also forces the engine to redraw collisions,
# raycasts, etc. so they appear/dissapear when button is pressed.
func _on_collision_check_toggled(toggled_on: bool) -> void:
	get_tree().debug_collisions_hint = toggled_on
	_force_redraw_of_type(get_tree().root, "CollisionShape2D")
	_force_redraw_of_type(get_tree().root, "CollisionPolygon2D")
	_force_redraw_of_type(get_tree().root, "RayCast2D") 

# Checks if the node requested is of the requested class, and checks
# if it can be redrawn. If so, redraws it for the node and all of
# it's children as well.
func _force_redraw_of_type(node: Node, target_class: String) -> void:
	if node.is_class(target_class) and node.has_method("queue_redraw"):
		node.queue_redraw()
	
	for child in node.get_children():
		_force_redraw_of_type(child, target_class)

# When cooldown check button is toggled, sets the variable to toggled on,
# and prints a debug message.
func _on_cooldown_check_toggled(toggled_on: bool) -> void:
	DebugMenu.noCooldowns = toggled_on
	print("DebugMenu.noCooldowns: " + str(DebugMenu.noCooldowns))

# When the add energy button is pressed, 
# gets the spinbox value and sets the current 
# energy value to the requested value
func _on_add_energy_button_pressed() -> void:
	RunState.current_energy += $Control/energyAddSpinBox.value
	print("Amount of energy to be added:" + str($Control/energyAddSpinBox.value))
