extends Control

signal hovered
signal stophovered


#Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_first_node_in_group("card_manager").connect_card_signals(self)


#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("stophovered", self)
