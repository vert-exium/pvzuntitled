extends Node2D




func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/loadout_select.tscn")




func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")


func _on_index_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/index.tscn")


func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
