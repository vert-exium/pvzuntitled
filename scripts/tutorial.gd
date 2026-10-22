extends Node2D

@onready var label: Label = $tutorialLabel

var current_stage = 1
var max_stage = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Welcome to the tutorial! This will teach you the basic mechanics of Man Vs. Machine! \n Press the next button to advance to the next step!"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_next_button_pressed() -> void:
	if current_stage < max_stage:
		current_stage += 1
		update_stage(current_stage)

func _on_previous_button_pressed() -> void:
	if current_stage > 1:
		current_stage -= 1
		update_stage(current_stage)

func update_stage(stage: int):
	if stage == 1:
		hide_all()
		label.text = "Welcome to the tutorial! This will teach you the basic mechanics of Man Vs. Machine! \n Press the next button to advance to the next step!"
	elif stage == 2:
		hide_all()
		label.text = "First, this is the main menu. It has a few options: \n Play will take you right into the loadout selector. \n Settings will let you adjust audio settings. \n Index will take you to a page where you can view a list of all enemies and cards in the game. \n The shop button lets you upgrade various stats to make your runs easier!"
	elif stage == 3:
		hide_all()
		#label.text = 

func hide_all():
	$stage2Control.hide()
