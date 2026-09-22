extends Area2D

var card_inside = null
var card_loadout_preview


func _ready():
	card_loadout_preview = $"../cardLoadoutPreview"


func _on_area_entered(area: Area2D) -> void:
	print("Card inside")

	var card = area.get_parent()

	if card.is_in_group("cards"):
		card_inside = card


func _on_area_exited(area: Area2D) -> void:
	print("Card not inside")

	var card = area.get_parent()

	if card == card_inside:
		card_inside = null
