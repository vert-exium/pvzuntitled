extends Node2D


# A stripped down card manger script. Only for use in the interactive tutorial

const COLLISION_MASK_CARD = 1
const DRAG_Z_INDEX = 1000
const max_placed_z_index: int = 1

var last_mouse_pos: Vector2
var screen_size
var card_being_dragged
var is_hovering_on_card
var displayed_strength: float = 0
var card_preview
var card_placeholder
var remaining_strength = 0
var energy_bonus = 0

const cardStrengths = {
	"thrower": {
		"name": "thrower",
		"strength": 4
	},
	"generator": {
		"name": "generator",
		"strength": 3
	}
}

func _ready() -> void:
	# Gets the current viewport size for other function to use
	screen_size = get_viewport_rect().size

# Every frame, checks if the card is being dragged. If so, smoothly animates the position
# and rotation based on momentum. Also makes sure they do not get too fast or leave the screen
func _process(delta: float) -> void:
	# Gets mouse position, and calculates the velocity
	var mouse_pos = get_global_mouse_position()
	var velocity_x = mouse_pos.x - last_mouse_pos.x
	last_mouse_pos = mouse_pos
	
	# Uses linear interpolation to smoothly move the card
	card_being_dragged.global_position = card_being_dragged.global_position.lerp(Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y)), 25.0 * delta)
	# Sets the rotation smoothly
	var target_rotation = clamp(velocity_x * 0.015, -0.25, 0.25)
	card_being_dragged.rotation = lerp(card_being_dragged.rotation, target_rotation, 15.0 * delta)
	
	update_card_preview()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			
			if card:
				card_being_dragged = card
				card.z_index = DRAG_Z_INDEX
				
				last_mouse_pos = get_global_mouse_position()
				
				var grab_tween = create_tween()
				grab_tween.tween_property(card, "scale", Vector2(1.15, 1.15), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				
				remove_card_preview()
				
				var loadout = get_tree().get_first_node_in_group("card_detector")
				if loadout and card.get_parent() == loadout.card_loadout_preview:
					card.reparent(get_tree().current_scene, true)
					calculate_total_strength()
		
		else:
			if card_being_dragged:
				var card = card_being_dragged
				var loadout = get_tree().get_first_node_in_group("card_detector")
				
				if loadout and loadout.card_inside == card and card_preview:
					finish_card_placement(card, loadout)
				
				else:
					remove_card_preview()
					
					var drop_tween = create_tween().set_parallel()
					
					drop_tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
					drop_tween.tween_property(card, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					
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
	if card_preview or card_placeholder:
		return
	
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
	fade_tween.tween_property(card_preview, "modulate:a", 0.5, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await get_tree().process_frame
	
	if not card_preview or not card_placeholder:
		return
	
	card_preview.global_position = card_placeholder.global_position + Vector2(0, 150)
	disable_preview_collisions(card_preview)
