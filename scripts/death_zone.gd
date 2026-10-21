extends Area2D

@export_file("*tscn") var next_scene: String = "res://scenes/youlose.tscn"

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		get_tree().change_scene_to_file(next_scene)
