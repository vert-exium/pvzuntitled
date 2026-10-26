extends Control

@onready var texture = $backRect

# Defines each color that the texture rectangle will
# fade to. Stored in an array that can only contain colors
const COLOR_ARRAY: Array[Color] = [
	Color("6b000eff"),
	Color("421419ff"),
	Color("381722ff"),
	Color("331723ff"),
	Color("59221fff"),
	Color("3f1407ff"),
	Color("331008ff")
]

# Tracks the index (# of item in array) of the current color
var current_color_index: int = 0

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _ready() -> void:
	if COLOR_ARRAY.is_empty():
		return
	
	# Sets the color of the texture to the
	# first item in the color array
	texture.modulate = COLOR_ARRAY[0]
	start_color_loop()

func start_color_loop() -> void:
	current_color_index = (current_color_index + 1) % COLOR_ARRAY.size()
	var next_color = COLOR_ARRAY[current_color_index]
	var tween = create_tween()
	tween.tween_property(texture, "modulate", next_color, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(start_color_loop)


func _on_audio_player_finished() -> void:
	$audioPlayer.play()
