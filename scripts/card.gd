extends Control

signal card_clicked(card_id)

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

func _on_button_pressed() -> void:
	card_clicked.emit(card_id)

func _on_global_card_selected(selected_id: String) -> void:
	is_selected = (selected_id == card_id)
