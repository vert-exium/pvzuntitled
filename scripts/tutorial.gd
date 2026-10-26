extends Node2D

@onready var label: Label = $tutorialLabel
@onready var panel = $textPanel
@onready var tutorial_label = $textPanel/tutorialLabel



var current_stage = 1
var max_stage = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_label("Welcome to the tutorial! This will teach you the basic mechanics of Man Vs. Machine! \n Press the next button to advance to the next step!")
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
		$previousButton.disabled = true
		update_label("Welcome to the tutorial! This will teach you the basic mechanics of Man Vs. Machine! \n Press the next button to advance to the next step!")
	elif stage == 2:
		hide_all()
		$nextButton.disabled = false
		$previousButton.disabled = false
		update_label("The objective of Man Vs. Machine is to defend the field from enemies. You must place units to defend one of five lanes, where enemies will spawn in. Your goal is to last as long as you can and upgrade your stats!")
	elif stage == 3:
		hide_all()
		$stage2Control.show()
		$nextButton.disabled = false
		$previousButton.disabled = false
		update_label("First, this is the main menu. It has a few options: \n Play will take you right into the loadout selector. \n Settings will let you adjust audio settings. \n Index will take you to a page where you can view a list of all enemies and cards in the game. \n The shop button lets you upgrade various stats to make your runs easier! \n Press next when ready to enter the interactive loadout selection tutorial!")
	elif stage == 4:
		hide_all()
		$nextButton.disabled = false
		$stage3Control.show()
		$previousButton.disabled = false
		update_label("This is the loadout selection menu! Each card has a strength value. There is a limit, so choose your loadout wisely. \n As well as this, the lower the strength, the more energy you will start with. \n For now, select the generator card and the thrower card, and press confirm when you're ready to move on!")
	elif stage == 5:
		hide_all()
		$nextButton.disabled = false
		$previousButton.disabled = false
		$stage4Control.show()
		update_label("On the very left, you will see three text boxes. The very top one indicates the amount of energy you have. You spend energy on placing cards! \n The middle text shows you the name of the currently selected card. \n The bottom text shows you the cooldown to place the selected card. Each card has a unique cooldown period! \n When you load in with this loadout, there will be 3 cards avaliable. The first is the hammer. You can use this to remove cards, and it costs 20 energy. \n The second will be the thrower. This unit will throw a projectile at units. It costs 100 energy. \n The final card is the generator. This card will periodically generate bonus energy. It's useful to build these up at the back, but make sure you have enough units to defend the field. ")
	elif stage == 6:
		$nextButton.disabled = false
		hide_all()
		$stage6Control.show()
		update_label("This is the main screen. Once you select a card, it will be highlighted in green. \n Then, a grid will be drawn over the screen. It will be red if selecting the shovel, or green with any other card. \n The grid will have the opposite color highlighted in any spaces that are already taken. For example, the placed thrower is highlighted in red. Simply click an avaliable space to place your card!")
	elif stage == 7:
		hide_all()
		update_label("You've reached the end! \n When you're ready, try hopping into a round! If you get confused, feel free to return here for more help. \n Always remember to have fun!")
		$nextButton.disabled = true

func hide_all():
	$stage2Control.hide()
	$stage3Control.hide()
	$stage4Control.hide()
	$stage6Control.hide()

func _on_confirm_button_pressed() -> void:
	hide_all()
	current_stage = 4
	update_stage(current_stage)


func update_label(new_text: String) -> void:
	tutorial_label.text = new_text
	
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var horizontal_padding: float = 40.0
	var vertical_padding: float = 30.0
	
	tutorial_label.custom_minimum_size.x = panel.size.x - horizontal_padding
	tutorial_label.size.x = panel.size.x - horizontal_padding
	
	var max_font_size: int = 45
	var min_font_size: int = 8
	var current_font_size: int = max_font_size
	
	tutorial_label.add_theme_font_size_override("font_size", current_font_size)
	await get_tree().process_frame
	
	var max_allowed_height = panel.size.y - vertical_padding
	while current_font_size > min_font_size and tutorial_label.get_minimum_size().y > max_allowed_height:
		current_font_size -= 1
		tutorial_label.add_theme_font_size_override("font_size", current_font_size)
		await get_tree().process_frame
	
	tutorial_label.position.x = horizontal_padding / 2.0
	tutorial_label.position.y = (panel.size.y - tutorial_label.get_minimum_size().y) / 2.0
