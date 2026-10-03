extends Node2D

# Visual related variables.
const COLLISION_MASK_CARD = 1
const DRAG_Z_INDEX = 1000
var max_placed_z_index: int = 1

# Variables
var last_mouse_pos: Vector2
var screen_size
var card_being_dragged
var is_hovering_on_card
var displayed_strength: float = 0
var card_preview
var card_placeholder
var remaining_strength = 0
var energy_bonus = 0


# Stores all cards that can be placed
# and assigns a strength to them.

const cardStrengths = {
	"bomber": {
		"name": "bomber",
		"strength": 15
	},
	"shielder": {
		"name": "shielder",
		"strength": 10
	},
	"thrower": {
		"name": "thrower",
		"strength": 4
	},
	"generator": {
		"name": "generator",
		"strength": 3
	},
	"swordsman": {
		"name": "swordsman",
		"strength": 17
	}
}


# Gets the current screen si

func _ready() -> void:
	# Gets the current viewport size for other functions to use
	screen_size = get_viewport_rect().size

	# Checks if it's loaded as an autoload, if so disables the node to save resources.
	if get_path() == NodePath("/root/CardManager"):
		set_process(false)
		set_process_input(false)

# Every frame, checks if the card is being dragged. If so, smoothly animates the position
# and rotation based on momentum. Also makes sure they do not get too fast or leave the screen
func _process(delta: float) -> void:
	if card_being_dragged:
		
		# Gets mouse position, and calculates the velocity.
		var mouse_pos = get_global_mouse_position()
		var velocity_x = mouse_pos.x - last_mouse_pos.x
		last_mouse_pos = mouse_pos

		# Uses linear interpolation to smoothly move the card.
		card_being_dragged.global_position = card_being_dragged.global_position.lerp(
			Vector2(
				clamp(mouse_pos.x, 0, screen_size.x),
				clamp(mouse_pos.y, 0, screen_size.y)
			),
			25.0 * delta
		)
		# Sets the rotation smoothly based on the velocity of the card
		var target_rotation = clamp(velocity_x * 0.015, -0.25, 0.25)
		card_being_dragged.rotation = lerp(
			card_being_dragged.rotation,
			target_rotation,
			15.0 * delta
		)

		update_card_preview()


func _input(event):
	# If the user clicks, checks if the click is a card. If so, brings it to the top and stores it.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()

			if card:
				card_being_dragged = card
				card.z_index = DRAG_Z_INDEX

				print(str(card) + " Strength: " + str(card.get("strength")))
				# Gets the last mouse position, and tweens the scale so it's larger
				last_mouse_pos = get_global_mouse_position()

				# Tweens the scale of the card smoothly so it's clear the card is selected
				var grab_tween = create_tween()
				grab_tween.tween_property(
					card,
					"scale",
					Vector2(1.15, 1.15),
					0.1
				).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

				remove_card_preview()
				# Gets the card detector node and stores it in a variable
				var loadout = get_tree().get_first_node_in_group("card_detector")

				# If the loadout (card detector) node exists and the card is inside
				# the loadout UI container, reparents it to the current scene and
				# recalculates the total strength
				if loadout and card.get_parent() == loadout.card_loadout_preview:
					card.reparent(get_tree().current_scene, true)
					calculate_total_strength()

		# When the card is released. Basically drops the card
		else:
			if card_being_dragged:
				# Gets the card and loadout node, stores in variables
				var card = card_being_dragged
				var loadout = get_tree().get_first_node_in_group("card_detector")

				# If the loadout and card preview exist, and if the card is dropped into
				# the card detector area, then sends a signal to finish placing the card.
				if loadout and loadout.card_inside == card and card_preview:
					finish_card_placement(card, loadout)

				# If the card isn't dropped into the card detector area, then:
				else:
					# Removes the ghost/preview of the card
					remove_card_preview()

					# Makes a tween and tweens the scale of the card to 1 (from 1.15).
					# Also smoothly tweens the rotation back to 0
					var drop_tween = create_tween().set_parallel()

					drop_tween.tween_property(
						card,
						"scale",
						Vector2(1.0, 1.0),
						0.2
					).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

					drop_tween.tween_property(
						card,
						"rotation",
						0.0,
						0.2
					).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

					# Increases the z-index so the card is more on top
					max_placed_z_index += 1
					card.z_index = max_placed_z_index

					
					if card.get_parent():
						card.get_parent().move_child(card, -1)

					# Recalculates the total strength
					calculate_total_strength()

				# Clears the card being dragged variable
				card_being_dragged = null

# Function to update the card preview. Will remove the
# card preview if needed, or updates the position.
func update_card_preview():
	# If the card is not being dragged, removes the preview
	# and returns so the function doesn't keep running.
	if not card_being_dragged:
		remove_card_preview()
		return

	# Sets the variable to the card loadout node
	var loadout = get_tree().get_first_node_in_group("card_loadout")

	# If the loadout doesn't exist, removes the preview 
	# and returns so the function doesn't keep running.
	if not loadout:
		remove_card_preview()
		return

	# If the card being dragged is inside of the loadout box,
	# if there is not a card preview, creates one.
	# Otherwise, removes the card preview.
	if loadout.card_inside == card_being_dragged:
		if not card_preview:
			create_card_preview(loadout)
	else:
		remove_card_preview()


func create_card_preview(loadout):
	# If there is a card preview or card placeholder, 
	# returns to stop the function from running any more.
	if card_preview:
		return

	if card_placeholder:
		return

	# Stores the loadout preview in a variable
	var preview_container = loadout.card_loadout_preview

	# Makes a new control node and sets it's properties accordingly.
	card_placeholder = Control.new()
	card_placeholder.custom_minimum_size = card_being_dragged.size
	card_placeholder.size = card_being_dragged.size
	card_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Adds the placeholder node to the preview container
	preview_container.add_child(card_placeholder)

	# Duplicates the card being dragged and 
	# adds it to the main scene
	card_preview = card_being_dragged.duplicate()
	get_tree().current_scene.add_child(card_preview)

	# Sets the preview's scale and rotation.
	card_preview.rotation = 0.0
	card_preview.scale = Vector2.ONE

	# Detatches the preview from the card group
	card_preview.remove_from_group("cards")
	# Disables any mouse interaction and stops any
	# script from running in the card preview.
	card_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_preview.process_mode = Node.PROCESS_MODE_DISABLED
	# Decreases the z index so the preview appears under any dragged cards
	card_preview.z_index = -1

	# Makes the preview completely transparent (so it can fade in below)
	card_preview.modulate.a = 0.0

	# Tweens in the transparency smoothly to 50%
	var fade_tween = create_tween()
	fade_tween.tween_property(
		card_preview,
		"modulate:a",
		0.5,
		0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Waits one frame
	await get_tree().process_frame

	# If there is no card preview or card placeholder 
	# available, immediately stops the function.
	if not card_preview or not card_placeholder:
		return

	# Sets the position of the card preview to the 
	# position of the placeholder node, plus an offset.
	card_preview.global_position = card_placeholder.global_position + Vector2(0, 150)

	# Disables all collisions possible
	disable_preview_collisions(card_preview)



func finish_card_placement(card, loadout):
	# Stores the preview node in a variable
	var preview_container = loadout.card_loadout_preview
	# Gets the index of the placeholder node and stores it in a variable.
	var slot_index = card_placeholder.get_index()

	# Stores the target position for the placed card by applying
	# an offset to the card placeholder's position
	var target_position = card_placeholder.global_position + Vector2(0, 150)

	# If the card preview exists, hides it.
	if card_preview:
		card_preview.visible = false

	# If the card placeholder exists, then removes
	# it and sets the variable to null
	if card_placeholder:
		card_placeholder.queue_free()
		card_placeholder = null

	# Then, clears the card preview
	card_preview = null

	# Creates a tween variable and sets parallel so multiple can run
	# at once. Tweens the position of the card to the target position,
	# tweens the scale back to one, and tweens the rotation to zero.
	var tween = create_tween().set_parallel()

	tween.tween_property(
		card,
		"global_position",
		target_position,
		0.4
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		card,
		"scale",
		Vector2(1.0, 1.0),
		0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		card,
		"rotation",
		0.0,
		0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Waits for the tweens to all finish
	await tween.finished

	# Reparents the card so it's a child of preview container.
	card.reparent(preview_container, false)
	# Sets the slot index so it's in the exact order as before
	preview_container.move_child(card, slot_index)

	# Waits exactly one frame 
	await get_tree().process_frame

	# Resets the scale and rotation
	card.scale = Vector2(1, 1)
	card.rotation = 0.0

	# Increases the Z index by one so it's on top.
	max_placed_z_index += 1
	card.z_index = max_placed_z_index

	# Gets the sound effect node, and if valid, plays it.
	var sfx = get_tree().get_first_node_in_group("click_sfx")
	if sfx != null:
		sfx.play()

	# Recalculates the total strength since a card has been added.
	calculate_total_strength()

# Function for multiple kinds of nodes. Disables collisions, and
# does so for every child of the requested node.
func disable_preview_collisions(node):
	if node is Area2D:
		node.monitoring = false
		node.monitorable = false

	if node is CollisionShape2D:
		node.disabled = true

	if node is CollisionPolygon2D:
		node.disabled = true

	for child in node.get_children():
		disable_preview_collisions(child)


# If a card preview or card placeholder exists,
# kills the node and sets the variable to null.
func remove_card_preview():
	if card_preview:
		card_preview.queue_free()
		card_preview = null

	if card_placeholder:
		card_placeholder.queue_free()
		card_placeholder = null


	
func raycast_check_for_card():
	# Get's Godot's physics engine so we don't need a raycast node
	var space_state = get_world_2d().direct_space_state

	# A variable for the parameters to check
	var parameters = PhysicsPointQueryParameters2D.new()
	# Checks the position of the mouse
	parameters.position = get_global_mouse_position()
	# Makes sure it detects Area2D nodes
	parameters.collide_with_areas = true
	# Filters non-physics objects so it only detects cards
	parameters.collision_mask = COLLISION_MASK_CARD

	# Fires at the mouse position and returns an 
	# array which contains all applicable items
	# (ones that weren't filtered out).
	var result = space_state.intersect_point(parameters)

	# If there are any items detected, gets the card with
	# the highest z index (so you grab the card on the top).
	if result.size() > 0:
		return get_card_with_highest_z_index(result)

	return null

# Sets up connections when requested 
# (when hovered and when hovering is stopped)
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("stophovered", on_hovered_off_card)


func on_hovered_over_card(card):
	# Makes sure only one card is highlighted at a time
	if not is_hovering_on_card:
		# Triggers highlight effects
		highlight_card(card, true)
		# Sets the highlight flag to true so
		# other cards won't be highlighted
		is_hovering_on_card = true


func on_hovered_off_card(card):
	# Removes the highlight
	highlight_card(card, false)

	# Checks if the mouse has moved onto another card
	var new_card_hovered = raycast_check_for_card()

	# If there's a new card being hovered, then highlights it.
	# If not, sets hovering to false
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false


# A function which applies visual effects to the hovered card.
# Intakes the card node as a parameter and whether the card is 
# hovered or not. If it is, then applies the effects. If not,
# then resets the effects to 0.
func highlight_card(card: Control, hovered: bool) -> void:
	# Checks if the card is being hovered
	if hovered:
		# Creates a tween, checks
		var tween = create_tween()

		# Makes sure the card is not being dragged.
		# If it isn't, then brings it to the top.
		if card != card_being_dragged:
			card.z_index += 100

		# Tweens the scale of the highlighted card to 1.1
		tween.tween_property(
			card,
			"scale",
			Vector2(1.1, 1.1),
			0.35
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

	# If this is running, that it is not being hovered
	# and needs to return to it's normal condition.
	else:
		var tween = create_tween()

		# Makes sure you aren't dragging the card. If you
		# aren't, reverts the Z index from earlier, and
		# makes sure it doesn't fall below zero with max()
		if card != card_being_dragged:
			card.z_index = max(1, card.z_index - 100)

		# Tweens the scale back to 1.0
		tween.tween_property(
			card,
			"scale",
			Vector2(1.0, 1.0),
			0.35
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)



func get_card_with_highest_z_index(cards):
	# Gets the parent of the card and sets the highest index
	# to the index of the card to compare against
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index

	# For all cards hit by the raycast, compares their depths to
	# the first one. If it finds a card with a higher z index, then
	# sets the highest_z_index to that z index and gets that card.
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()

		if current_card.z_index > highest_z_index:
			highest_z_index = current_card.z_index
			highest_z_card = current_card

	# Returns the card with the highest z index found
	return highest_z_card


func calculate_total_strength() -> int:
	# Creates a variable to track total strength
	var total_strength: int = 0
	# Looks for the container for equipped cards
	var preview_container = get_node_or_null("../cardLoadoutPreview")
	
	# If the container doesn't exist, stops the 
	# function and returns a value of zero.
	if not preview_container:
		return 0

	# Gets all children in the preview container, and for each of them:
	#      - Gets the strength variable
	#      - Checks if strength is valid, and if it's a card. If so,
	#        adds the strength of that card to the total strength
	for child in preview_container.get_children():
		var strength = child.get("strength")
		if strength != null and child.is_in_group("cards"):
			total_strength += strength

	# Calls the label_effects function to
	# animate the strength label with the
	# updated value of the total strength
	label_effects(total_strength)

	# Smoothly tweens the strength display over half a second
	var tween = create_tween()
	tween.tween_method(
		update_strength_number,
		displayed_strength,
		total_strength,
		0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Checks if any cards are equipped
	if total_strength > 0:
		# Calculates how many remaining strength points are avaliable
		var remaining_strength: int = 50 - total_strength
		# Uses max() to make sure remaining points can't fall 
		# into negative values in case total_strength is above 50
		var x: float = float(max(0, remaining_strength))
		# Calculates the energy bonus the user gets. Divides the remaining
		# strength by 10, raisining it to the power of 1.75 so the gain is 
		# exponential, and multiplies that by 100 to get a good number
		energy_bonus = int(pow(x / 10.0, 1.75) * 100.0)
		# Prints a debug message
		print("Energy bonus calculated: " + str(energy_bonus))
	
	# Returns the final calculated total
	return total_strength


# Updates the strength label to the current strength value
func update_strength_number(value: int):
	# Gets the label and stores it in a variable
	var label = get_tree().get_first_node_in_group("strength_label")
	# If the label is not valid, stops the function
	if not label:
		return

	displayed_strength = value

	# If the value is higher than 50, displays a warning that the strength is too high.
	# If not, then rounds the strength value and displays it
	if value > 50:
		label.text = "Strength is above cap! " + "(" + str(value) + ")"
	else:
		label.text = "Loadout strength: " + str(round(value)) + "/50"


# Applies effects to the label that shows the total strength
func label_effects(total_strength):
	# Internal variable for the strength
	var strength = total_strength
	# Gets the strength label, stores it in a variable.
	var label = get_tree().get_first_node_in_group("strength_label")

	# If there is no valid label, stops the function.
	if not label:
		return

	# Sets the pivot offset of the label to
	# half of the size (the exact middle of the label)
	label.pivot_offset = label.size / 2

	# Creates a tween and sets it to parallel
	# so multiple tweens can run at once.
	var tween = create_tween().set_parallel()

	# Scales the node up slightly
	tween.tween_property(
		label,
		"scale",
		Vector2(1.05, 1.05),
		0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	# Sets the chain to true. First, the first scale tween will finish, running by itself,
	# and then the other two will run in parallel after the first one is finished.
	tween.chain()

	# Resets the scale to 1
	tween.tween_property(
		label,
		"scale",
		Vector2.ONE,
		0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	# Resets the rotation
	tween.parallel().tween_property(
		label,
		"rotation",
		0,
		0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


# When the confirm loadout button is pressed, calculates the total
# strength. If the total strength is under the maximum, stores the
# saved loadout, sends the energy bonus to RunState, and prints
# debug messages before switching the scene to Level. If the total
# strength is over the maximum, prints a debug message in the console.
func _on_button_pressed() -> void:
	var total_strength = calculate_total_strength()
	if total_strength > 50:
		print("Strength is greater than 50!")
	else:
		Global.saved_loadout = get_loadout_card_ids()
		RunState.energy_bonus = energy_bonus
		print("Saved Loadout: ", Global.saved_loadout)
		print("Saved Energy Bonus to RunState: ", RunState.energy_bonus)
		
		get_tree().change_scene_to_file("res://scenes/Level.tscn")



# Gets the IDs of the cards currently in the loadout
func get_loadout_card_ids() -> Array[String]:
	# Creates an array to store the IDs in, and looks for the container
	var card_ids: Array[String]
	var preview_container = get_tree().get_first_node_in_group("card_loadout_preview")

	# If there isn't a preview container found, returns the empty array
	if not preview_container:
		return card_ids

	# For each child in the preview container, stores the card IDs of 
	# nodes that are in the "cards" group and contain a card id in the 
	# array that was made earlier.
	for child in preview_container.get_children():
		if child.is_in_group("cards") and "card_id" in child:
			card_ids.append(child.card_id)

	return card_ids
