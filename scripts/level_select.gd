extends Node2D

func _on_level_two_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/loadout_select.tscn")
	pass # Replace with function body.



func _on_level_one_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level.tscn")
	pass # Replace with function body.
