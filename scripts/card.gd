extends Control

signal hovered
signal stophovered

@onready var area_2d: Area2D = $Area2D 

func _ready() -> void:
	area_2d.mouse_entered.connect(_on_area_2d_mouse_entered)
	area_2d.mouse_exited.connect(_on_area_2d_mouse_exited)
	
	var card_manager = get_tree().get_first_node_in_group("card_manager")
	if card_manager:
		card_manager.connect_card_signals(self)


func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	stophovered.emit(self)
