extends Node2D

const COLLISION_MASK_CARD = 1

var screen_size
var card_being_dragged
var is_hovering_on_card

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

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			
			if card:
				card_being_dragged = card
				
				# Remove the card from the HBox while dragging
				if card.get_parent() is HBoxContainer:
					card.reparent(get_tree().current_scene, true)
				
		else:
			if card_being_dragged:
				var loadout = get_tree().get_first_node_in_group("card_loadout")
				
				if loadout and loadout.card_inside == card_being_dragged:
					card_being_dragged.reparent(
						loadout.card_loadout_preview,
						false
					)
				
				card_being_dragged = null

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	
	var result = space_state.intersect_point(parameters)
	
	for hit in result:
		var card = hit.collider.get_parent()
		
		if card.is_in_group("cards"):
			return card
	
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

func highlight_card(card, hovered):
	if hovered:
		print("card is hoveriong")
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1

func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		
		if current_card.z_index > highest_z_index:
			highest_z_index = current_card.z_index
			highest_z_card = current_card
	
	return highest_z_card
