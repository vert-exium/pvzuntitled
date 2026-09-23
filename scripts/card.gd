extends Control

signal hovered
signal stophovered

@onready var area_2d: Area2D = $Area2D 
@export var card_id: String = ""


var card_name: String = ""
var strength: int = 0


func _ready() -> void:
	area_2d.mouse_entered.connect(_on_area_2d_mouse_entered)
	area_2d.mouse_exited.connect(_on_area_2d_mouse_exited)
	#set card manager to the proper node
	var card_manager = get_tree().get_first_node_in_group("card_manager")
	if card_manager:
		card_manager.connect_card_signals(self)

		#check if card is in card manager
		if card_id in card_manager.cardStrengths:
			#set cardStrength to the value in the dict
			var cardStrength = card_manager.cardStrengths[card_id]
			setup_card_data(cardStrength)
		else:
			push_warning("Card ID '%s' not found in cardStrengths dictionary!" % card_id)


func setup_card_data(data: Dictionary) -> void:
	card_name = data.get("name", "Unknown")
	strength = data.get("strength", 0)


func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	stophovered.emit(self)
