extends Control

signal card_clicked(card_id: String)

@export var card_id: String = "":
	set(value):
		card_id = value
		if is_inside_tree():
			_load_stats()

var card_name: String = ""
var strength: int = 0
var is_selected: bool = false

@onready var visuals = find_child("scalingnstuff", true, false)
@onready var btn = find_child("TextureButton", true, false)

func _ready() -> void:
	if btn != null:
		if not btn.pressed.is_connected(_on_button_pressed):
			btn.pressed.connect(_on_button_pressed)
		if not btn.mouse_entered.is_connected(_on_hover_entered):
			btn.mouse_entered.connect(_on_hover_entered)
		if not btn.mouse_exited.is_connected(_on_hover_exited):
			btn.mouse_exited.connect(_on_hover_exited)
		
	if SignalBus.has_signal("card_selected"):
		if not SignalBus.card_selected.is_connected(_on_global_card_selected):
			SignalBus.card_selected.connect(_on_global_card_selected)
			
	_load_stats()

func _load_stats() -> void:
	if card_id == "" or card_id == "shovel":
		return
		
	var card_data = CardDatabase.get_card(card_id)
	if not card_data.is_empty():
		card_name = card_data.get("name", "Unknown")
		strength = card_data.get("strength", 0)

	var card_manager = get_tree().get_first_node_in_group("card_manager")
	if card_manager and "cardStrengths" in card_manager:
		if card_id in card_manager.cardStrengths:
			var dynamic_strength = card_manager.cardStrengths[card_id]
			if typeof(dynamic_strength) == TYPE_DICTIONARY:
				strength = dynamic_strength.get("strength", strength)
			else:
				strength = dynamic_strength

	var strength_label = find_child("StrengthLabel", true, false)
	if strength_label:
		strength_label.text = str(strength)

func _on_button_pressed() -> void:
	card_clicked.emit(card_id)

func _on_global_card_selected(selected_id: String) -> void:
	is_selected = (selected_id == card_id)
	animate_selection()

func _on_hover_entered() -> void:
	if not is_selected and visuals != null:
		var tween = create_tween().set_parallel()
		#tween.tween_property(visuals, "position:y", 8.0, 0.15).set_trans(Tween.TRANS_SINE)
		tween.tween_property(visuals, "scale", Vector2(0.7, 0.7), 0.15).set_trans(Tween.TRANS_SINE)

func _on_hover_exited() -> void:
	if not is_selected and visuals != null:
		var tween = create_tween().set_parallel()
		#tween.tween_property(visuals, "position:y", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
		tween.tween_property(visuals, "scale", Vector2(0.6, 0.6), 0.15).set_trans(Tween.TRANS_SINE)

func animate_selection() -> void:
	if visuals == null:
		return
	
	var tween = create_tween().set_parallel()
	
	if is_selected:
		#tween.tween_property(visuals, "position:y", 12.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(visuals, "scale", Vector2(0.7, 0.7), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		visuals.modulate = Color(0.3, 1.0, 0, 1.0) 
	else:
		#tween.tween_property(visuals, "position:y", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(visuals, "scale", Vector2(0.6, 0.6), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		visuals.modulate = Color.WHITE
