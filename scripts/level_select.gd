extends Node2D



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")




func _on_level_two_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level.tscn")


func _on_level_one_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level.tscn")



func _on_level_three_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level.tscn")
