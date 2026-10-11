extends Node2D

@onready var background: TextureRect = $back

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
var last_spawn_pos: Vector2 = Vector2.ZERO
var drag_spawn_distance: float = 35.0


func _ready() -> void:
		background.mouse_filter = Control.MOUSE_FILTER_STOP
		background.gui_input.connect(_on_background_gui_input)


func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		spawn_ripple(event.global_position)
	
	elif event is InputEventMouseMotion:
		if event.global_position.distance_to(last_spawn_pos) >= drag_spawn_distance:
			spawn_ripple(event.global_position)
			last_spawn_pos = event.global_position

func spawn_ripple(global_pos: Vector2) -> void:
	var ripple = Control.new()
	ripple.set_script(load("res://scripts/mouse_effect.gd"))
	ripple.global_position = global_pos
	get_tree().root.add_child(ripple)
