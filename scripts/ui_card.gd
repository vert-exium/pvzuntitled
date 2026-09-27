extends Control

signal card_clicked(card_id: String)

@export var card_id: String = "shovel"

func _on_texture_button_pressed() -> void:
	card_clicked.emit(card_id)
	SignalBus.card_selected.emit(card_id)
