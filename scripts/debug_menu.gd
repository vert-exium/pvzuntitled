extends Node2D

# Script which handles everything related to the debug menu.

# Variables:
var open: bool = false        # Tracks whether the menu is open or not
var initialPosX: float = 0.0  # Stores the initial position (stored on _ready) of the node
var noCooldowns: bool = false # Bool to track whether the no cooldowns toggle is on/off
var showFPS: bool = false     # Bool to track whether to show FPS or not

# When the script starts, store the x position
# and add the node to the debug menu group.
func _ready() -> void:
	initialPosX = position.x
	add_to_group("debug_menu")
	Global.showFPS = showFPS
	
	# Initial visibility setup
	visible = Global.is_cheating
	set_process(true)
	set_physics_process(false)

# Constantly check if Global.is_cheating changes during gameplay
func _process(_delta: float) -> void:
	if Global.is_cheating and not visible:
		visible = true
	elif not Global.is_cheating and visible:
		visible = false
		if open:
			open = false
			$Control/toggleButton.text = "<"
			position.x = initialPosX

# When the open/close button is pressed, creates a tween, and checks
# if the menu is open or not. Tweens the position, sets the button text,
# and resets the variable as needed.
func _on_toggle_button_pressed() -> void:
	if not Global.is_cheating:
		return
		
	var pos_tween = create_tween()
	
	if open:
		open = false
		$Control/toggleButton.text = "<"
		pos_tween.tween_property(self, "position:x", initialPosX, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	else:
		open = true
		$Control/toggleButton.text = ">"
		pos_tween.tween_property(self, "position:x", initialPosX - 850.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

# When the energy button is pressed, sets the current energy to the spinbox's value
func _on_energy_button_pressed() -> void:
	if not Global.is_cheating: return
	RunState.current_energy = $Control/energySpinBox.value

# When the path check box is toggled, sets the debug value (show paths) to the
# set value. Also runs the force redraw function
func _on_path_check_toggled(toggled_on: bool) -> void:
	if not Global.is_cheating: return
	get_tree().debug_paths_hint = toggled_on
	_force_redraw_of_type(get_tree().root, "Path2D")

# When the collision check box is toggled, sets the debug value in the engine, and
# runs the function to redraw collision nodes and raycasts
func _on_collision_check_toggled(toggled_on: bool) -> void:
	if not Global.is_cheating: return
	get_tree().debug_collisions_hint = toggled_on
	_force_redraw_of_type(get_tree().root, "CollisionShape2D")
	_force_redraw_of_type(get_tree().root, "CollisionPolygon2D")
	_force_redraw_of_type(get_tree().root, "RayCast2D") 

# When this function is run, checks if the requested node is in the requested node
# class, and if it can run queue_redraw(). If so, runs queue_redraw for the requested
# node. Also reruns the same function for all of it's children as well.
func _force_redraw_of_type(node: Node, target_class: String) -> void:
	if node.is_class(target_class) and node.has_method("queue_redraw"):
		node.queue_redraw()
	
	for child in node.get_children():
		_force_redraw_of_type(child, target_class)

# Sets the noCooldowns boolean in DebugMenu accordingly, and prints a debug message.
func _on_cooldown_check_toggled(toggled_on: bool) -> void:
	if not Global.is_cheating: return
	DebugMenu.noCooldowns = toggled_on
	print("DebugMenu.noCooldowns: " + str(DebugMenu.noCooldowns))

# Adds the requested amount of energy and prints a debug message as well.
func _on_add_energy_button_pressed() -> void:
	if not Global.is_cheating: return
	RunState.current_energy += $Control/energyAddSpinBox.value
	print("Amount of energy to be added:" + str($Control/energyAddSpinBox.value))

# When the FPS toggle is flipped, show the fps
func _on_fps_check_toggled(toggled_on: bool) -> void:
	if not Global.is_cheating: return
	showFPS = toggled_on
	Global.showFPS = showFPS

# When the wave set button is pressed, set the wave to whatever the current spinbox value is
func _on_set_wave_button_pressed() -> void:
	if not Global.is_cheating: return
	var wave_to_set_to = $Control/setWaveSpinBox.value
	print("Wave set to" + str(wave_to_set_to))
	LevelManager.current_wave = wave_to_set_to

func _on_add_coins_button_pressed() -> void:
	if not Global.is_cheating: return
	Global.coins += $Control/addCoinsSpinbox.value
