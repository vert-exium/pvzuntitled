extends Node2D

@onready var label: Label = $tutorialLabel

var current_stage = 1
var max_stage = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Welcome to the tutorial! This will teach you the basic mechanics of Man Vs. Machine! \n Press the next button to advance to the next step!"
	hide_all()

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
		$stage2Control.show()
		label.text = "First, this is the main menu. It has a few options: \n Play will take you right into the loadout selector. \n Settings will let you adjust audio settings. \n Index will take you to a page where you can view a list of all enemies and cards in the game. \n The shop button lets you upgrade various stats to make your runs easier! \n Press next when ready to enter the interactive loadout selection tutorial!"
	elif stage == 3:
		hide_all()
		$stage3Control.show()
		label.text = "This is the loadout selection menu! Each card has a strength value. There is a limit, so choose your loadout wisely. \n As well as this, the lower the strength, the more energy you will start with. \n For now, select the generator card and the thrower card, and press confirm when you're ready to move on!"


func hide_all():
	$stage2Control.hide()
	$stage3Control.hide()


func _on_confirm_button_pressed() -> void:
	pass
