extends CanvasLayer

@onready var cc_label: Label = $topPanel/currentCard
@onready var cooldown_label: Label = $topPanel/ccCooldown

var currently_selected_card: String = "generator"
var level_script: Node = null

var card_scenes = {
	"bomber": preload("res://scenes/bomber_card_ui.tscn"),
	"shielder": preload("res://scenes/shielder_card_ui.tscn"),
	"generator": preload("res://scenes/generator_card_ui.tscn"),
	"thrower": preload("res://scenes/thrower_card_ui.tscn")
}




func _ready() -> void:
	await get_tree().process_frame 
	for child in $CardContainer.get_children():
		print("Card: ", child.name, " | Size: ", child.size, " | Pos: ", child.position)
	var loadout = Global.saved_loadout
	var card_scale: float = 0.58
	for id in loadout:
		if card_scenes.has(id):
			var card_instance = card_scenes[id].instantiate()
			if "card_id" in card_instance:
				card_instance.card_id = id
			if card_instance.has_signal("card_clicked"):
				card_instance.card_clicked.connect(_select_card)

			$CardContainer.add_child(card_instance)
	#Update label constantly
func _process(_delta: float) -> void:
	$topPanel/energyLabel.text = "ENERGY: " + str(RunState.current_energy)
	_update_cooldown_label()
func _select_card(card_id: String) -> void:
	currently_selected_card = card_id
	SignalBus.card_selected.emit(card_id)
	_update_card_label(card_id)

func _update_card_label(card_id: String) -> void:
	if card_id == "shovel":
		cc_label.text = "Card: Shovel"
	else:
		var card_data = CardDatabase.get_card(card_id)
		if not card_data.is_empty():
			cc_label.text = "Card: " + card_data["name"]
		else:
			cc_label.text = "Card: None"

func _update_cooldown_label() -> void:
	if currently_selected_card == "shovel" or currently_selected_card == "":
		cooldown_label.text = "Cooldown: Ready"
		return

	if not is_instance_valid(level_script):
		level_script = get_tree().current_scene

	if level_script and level_script.has_method("get_remaining_cooldown"):
		var remaining = level_script.get_remaining_cooldown(currently_selected_card)
		if remaining > 0.0:
			cooldown_label.text = "Cooldown: %.1fs" % remaining
		else:
			cooldown_label.text = "Cooldown: Ready"

# Button Pressed Callbacks
func _on_generator_pressed() -> void:
	_select_card("generator")

func _on_thrower_pressed() -> void:
	_select_card("thrower")

func _on_shovel_pressed() -> void:
	_select_card("shovel")

func _on_bomber_button_pressed() -> void:
	_select_card("bomber")
	print("Bomber selected")

func _on_shielder_button_pressed() -> void:
	_select_card("shielder")
