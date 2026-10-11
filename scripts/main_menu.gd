extends Node2D

# Store the background ColorRect for cleaner code
@onready var background: TextureRect = $background

const BACKGROUND_COLORS: Array[Color] = [
	Color("#1a1b35"),
	Color("#251c3b"),
	Color("#3a1b3d"),
	Color("#421d33"),
	Color("#381c2f"),
	Color("#2f1c24"),
	Color("#3b1d24"),
	Color("#2d201c"),
	Color("#24221c"),
	Color("#1f241d"),
	Color("#1c2826"),
	Color("#16262a"),
	Color("#16222a"),
	Color("#192530"),
	Color("#1a2033"),
	Color("#231e3d")
]

# Tracks which color to go to (as a number
# of the index of the colors array)
var current_color_index: int = 0
var last_spawn_pos: Vector2 = Vector2.ZERO
var drag_spawn_distance: float = 35.0

func _ready() -> void:
	if background:
		background.modulate = BACKGROUND_COLORS[0]
		start_background_color_loop()
		
		background.mouse_filter = Control.MOUSE_FILTER_STOP
		background.gui_input.connect(_on_background_gui_input)

func start_background_color_loop() -> void:
	if BACKGROUND_COLORS.is_empty():
		return
	
	current_color_index = (current_color_index + 1) % BACKGROUND_COLORS.size()
	var next_color = BACKGROUND_COLORS[current_color_index]
	var tween = create_tween()
	tween.tween_property(background, "modulate", next_color, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(start_background_color_loop)

func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		spawn_ripple(event.position, false)
	
	elif event is InputEventMouseMotion:
		if event.position.distance_to(last_spawn_pos) >= drag_spawn_distance:
			spawn_ripple(event.position, true)
			last_spawn_pos = event.position

func spawn_ripple(pos: Vector2, is_drag: bool) -> void:
	var ripple = Control.new()
	ripple.set_script(load("res://scripts/ripple.gd"))
	ripple.position = pos
	
	if is_drag:
		ripple.max_radius = 70.0
	
	background.add_child(ripple)



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/loadout_select.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")


func _on_index_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/index.tscn")


func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
