extends Node2D

const COLLISION_MASK_CARD = 1
const DRAG_Z_INDEX = 1000

var last_mouse_pos: Vector2
var screen_size
var card_being_dragged
var is_hovering_on_card
var displayed_strength: float = 0
var card_preview
var card_placeholder

var max_placed_z_index: int = 1
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
	"generator":
	{
		"name": "generator",
		"strength": 3
	}
}

func _ready() -> void:
	screen_size = get_viewport_rect().size
	calculate_total_strength()


func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		
		var velocity_x = mouse_pos.x - last_mouse_pos.x
		last_mouse_pos = mouse_pos
		
		card_being_dragged.global_position = card_being_dragged.global_position.lerp(
			Vector2(
				clamp(mouse_pos.x, 0, screen_size.x),
				clamp(mouse_pos.y, 0, screen_size.y)
			),
			25.0 * delta
		)
		
		var target_rotation = clamp(velocity_x * 0.015, -0.25, 0.25)
		card_being_dragged.rotation = lerp(
			card_being_dragged.rotation,
			target_rotation,
			15.0 * delta
		)
		
		update_card_preview()


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			
			if card:
				card_being_dragged = card
				card.z_index = DRAG_Z_INDEX
				
				print(str(card) + " Strength: " + str(card.strength))
				
				last_mouse_pos = get_global_mouse_position()
				
				var grab_tween = create_tween()
				grab_tween.tween_property(
					card,
					"scale",
					Vector2(1.15, 1.15),
					0.1
				).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				
				remove_card_preview()
				
				var loadout = $"../cardDetector"
				
				if loadout and card.get_parent() == loadout.card_loadout_preview:
					card.reparent(get_tree().current_scene, true)
					calculate_total_strength()
		
		else:
			if card_being_dragged:
				var card = card_being_dragged
				var loadout = $"../cardDetector"
				
				if loadout and loadout.card_inside == card and card_preview:
					finish_card_placement(card, loadout)
				
				else:
					remove_card_preview()
					
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
					
					max_placed_z_index += 1
					card.z_index = max_placed_z_index
					
					if card.get_parent():
						card.get_parent().move_child(card, -1)
					
					calculate_total_strength()
				
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
	
	card_preview.rotation = 0.0
	card_preview.scale = Vector2.ONE
	
	card_preview.remove_from_group("cards")
	card_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_preview.process_mode = Node.PROCESS_MODE_DISABLED
	card_preview.z_index = -1
	
	card_preview.modulate.a = 0.0
	
	var fade_tween = create_tween()
	fade_tween.tween_property(
		card_preview,
		"modulate:a",
		0.5,
		0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await get_tree().process_frame
	
	card_preview.global_position = card_placeholder.global_position + Vector2(0, 150)
	
	disable_preview_collisions(card_preview)


func finish_card_placement(card, loadout):
	var preview_container = loadout.card_loadout_preview
	var target_position = card_preview.global_position
	var slot_index = card_placeholder.get_index()
	
	var tween = create_tween().set_parallel()
	
	tween.tween_property(
		card,
		"global_position",
		target_position,
		0.25
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
	
	await tween.finished
	
	card.reparent(preview_container, false)
	preview_container.move_child(card, slot_index)
	
	card.scale = Vector2(1, 1)
	
	max_placed_z_index += 1
	card.z_index = max_placed_z_index
	
	$"../clickSFX".play()
	
	remove_card_preview()
	calculate_total_strength()


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
			card.z_index = card.z_index + 100
		
		tween.tween_property(
			card,
			"scale",
			Vector2(1.1, 1.1),
			0.35
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
	else:
		var tween = create_tween()
		
		if card != card_being_dragged:
			card.z_index = max(1, card.z_index - 100)
			
		tween.tween_property(
			card,
			"scale",
			Vector2(1.0, 1.0),
			0.35
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)


func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index

	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()

		if current_card.z_index > highest_z_index:
			highest_z_index = current_card.z_index
			highest_z_card = current_card

	return highest_z_card



func calculate_total_strength():
	var total_strength = 0
	var preview_container = $"../cardLoadoutPreview"
	if not preview_container:
		return 0

	for child in preview_container.get_children():
		var strength = child.get("strength")
		if strength != null and child.is_in_group("cards"):
			total_strength += strength

	label_effects(total_strength)

	var tween = create_tween()
	tween.tween_method(
		update_strength_number,
		displayed_strength,
		total_strength,
		0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	return total_strength


func update_strength_number(value: int):
	var label = $"../strengthLabel"
	displayed_strength = value
	label.text = "Loadout strength: " + str(round(value)) + "/50"


func label_effects(total_strength):
	var strength = total_strength
	var label = $"../strengthLabel"
	label.pivot_offset = label.size / 2

	var tween = create_tween().set_parallel()

	tween.tween_property(
		label,
		"scale",
		Vector2(1.05, 1.05),
		0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		label,
		"rotation",
		deg_to_rad(0.4),
		0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		label,
		"modulate",
		Color.RED if strength > 50 else Color.WHITE,
		0.1
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	tween.chain()

	tween.tween_property(
		label,
		"scale",
		Vector2.ONE,
		0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(
		label,
		"rotation",
		0,
		0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
