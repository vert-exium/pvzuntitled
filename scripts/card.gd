extends Control

signal card_clicked(card_id)

@export var card_id: String = ""
var card_name: String = ""
var strength: int = 0
var is_selected: bool = false

@onready var visuals = find_child("scalingnstuff", true, false)
@onready var btn = find_child("TextureButton", true, false)

func _ready() -> void:
	if btn != null:
		btn.pressed.connect(_on_button_pressed)
		btn.mouse_entered.connect(_on_hover_entered)
		btn.mouse_exited.connect(_on_hover_exited)
	
	if SignalBus.has_signal("card_selected"):
		SignalBus.card_selected.connect(_on_global_card_selected)
	
	var card_manager = get_tree().get_first_node_in_group("card_manager")
	if card_manager and card_id in card_manager.cardStrengths:
		setup_card_data(card_manager.cardStrengths[card_id])

func setup_card_data(data: Dictionary) -> void:
	card_name = data.get("name", "Unknown")
	strength = data.get("strength", 0)

func _on_button_pressed() -> void:
	card_clicked.emit(card_id)

func _on_global_card_selected(selected_id: String) -> void:
	is_selected = (selected_id == card_id)
	animate_selection()

func _on_hover_entered() -> void:
	if not is_selected and visuals != null:
		var tween = create_tween()
		tween.tween_property(visuals, "scale", Vector2(1.08, 1.08), 0.15).set_trans(Tween.TRANS_SINE)

func _on_hover_exited() -> void:
	if not is_selected and visuals != null:
		var tween = create_tween()
		tween.tween_property(visuals, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_SINE)
	


func animate_selection() -> void:
	if visuals == null:
		return
	
	var tween = create_tween().set_parallel()
	
	if is_selected:
		tween.tween_property(visuals, "position:y", 20.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(visuals, "scale", Vector2(1.15, 1.15), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		visuals.modulate = Color(1.2, 1.2, 1.2)
	else:
		tween.tween_property(visuals, "position:y", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(visuals, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		visuals.modulate = Color.WHITE
	
