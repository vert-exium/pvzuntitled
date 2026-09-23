extends Node2D

const COLLISION_MASK_CARD = 1
const DRAG_Z_INDEX = 1000

var screen_size
var card_being_dragged
var is_hovering_on_card

var card_preview
var card_placeholder

# Keeps track of global highest z_index for stack ordering
var max_placed_z_index: int = 1


func _ready() -> void:
	screen_size = get_viewport_rect().size


func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()

		card_being_dragged.global_position = lerp(
			card_being_dragged.global_position,
			Vector2(
				clamp(mouse_pos.x, 0, screen_size.x),
				clamp(mouse_pos.y, 0, screen_size.y)
			),
			0.1
		)

		update_card_preview()


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			var card = raycast_check_for_card()

			if card:
				card_being_dragged = card
				card.scale = Vector2(1, 1)
				card.z_index = DRAG_Z_INDEX

				remove_card_preview()

				var loadout = get_tree().get_first_node_in_group("card_loadout")

				if loadout and card.get_parent() == loadout.card_loadout_preview:
					card.reparent(get_tree().current_scene, true)

		else:
			if card_being_dragged:
				var card = card_being_dragged
				var loadout = get_tree().get_first_node_in_group("card_loadout")

				if loadout and loadout.card_inside == card and card_preview:
					finish_card_placement(card, loadout)
				else:
					remove_card_preview()
					card.scale = Vector2(1.05, 1.05)
					
					# Increment global z_index to guarantee top stacking
					max_placed_z_index += 1
					card.z_index = max_placed_z_index
					
					# Move node to end of parent children list so tree order renders it on top
					if card.get_parent():
						card.get_parent().move_child(card, -1)

				card_being_dragged = null


func update_card_preview():
	if not card_being_dragged:
		remove_card_preview()
		return

	var loadout = get_tree().get_first_node_in_group("card_loadout")

	if not loadout:
		remove_card_preview()
		return

	if loadout.card_inside == card_being_dragged:
		if not card_preview:
			create_card_preview(loadout)
	else:
		remove_card_preview()


func create_card_preview(loadout):
	var preview_container = loadout.card_loadout_preview

	card_placeholder = Control.new()
	card_placeholder.custom_minimum_size = card_being_dragged.size
	card_placeholder.size = card_being_dragged.size
	card_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE

	preview_container.add_child(card_placeholder)

	card_preview = card_being_dragged.duplicate()
	get_tree().current_scene.add_child(card_preview)

	card_preview.remove_from_group("cards")
	card_preview.modulate.a = 0.5
	card_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_preview.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Lower z_index so preview renders BELOW standard cards
	card_preview.z_index = -1

	await get_tree().process_frame

	card_preview.global_position = card_placeholder.global_position + Vector2(0, 150)

	disable_preview_collisions(card_preview)


func finish_card_placement(card, loadout):
	var preview_container = loadout.card_loadout_preview

	var target_position = card_preview.global_position
	var slot_index = card_placeholder.get_index()

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		card,
		"global_position",
		target_position,
		0.8
	)

	tween.parallel().tween_property(
		card,
		"scale",
		Vector2(1.05, 1.05),
		0.8
	)

	await tween.finished

	card.reparent(preview_container, false)
	preview_container.move_child(card, slot_index)

	# Reset scale and set z_index above standard preview elements
	card.scale = Vector2(1, 1)
	max_placed_z_index += 1
	card.z_index = max_placed_z_index

	$"../clickSFX".play()

	remove_card_preview()


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


func remove_card_preview():
	if card_preview:
		card_preview.queue_free()
		card_preview = null

	if card_placeholder:
		card_placeholder.queue_free()
		card_placeholder = null


func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state

	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD

	var result = space_state.intersect_point(parameters)

	if result.size() > 0:
		return get_card_with_highest_z_index(result)

	return null


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("stophovered", on_hovered_off_card)


func on_hovered_over_card(card):
	if not is_hovering_on_card:
		highlight_card(card, true)
		is_hovering_on_card = true


func on_hovered_off_card(card):
	highlight_card(card, false)

	var new_card_hovered = raycast_check_for_card()

	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false


func highlight_card(card: Control, hovered: bool) -> void:
	if hovered:
		var tween = create_tween()
		if card != card_being_dragged:
			# Shift temporary hover z_index well above normal stack
			card.z_index = card.z_index + 100
		tween.tween_property(card, "scale", Vector2(1.1, 1.1), 0.35)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_IN_OUT)
	else:
		var tween = create_tween()
		if card != card_being_dragged:
			card.z_index = max(1, card.z_index - 100)
			
		tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.35)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_IN_OUT)


func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index

	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()

		if current_card.z_index > highest_z_index:
			highest_z_index = current_card.z_index
			highest_z_card = current_card

	return highest_z_card
