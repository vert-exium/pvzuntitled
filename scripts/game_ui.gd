extends CanvasLayer

# Variables
@onready var cc_label: Label = $topPanel/currentCard
@onready var cooldown_label: Label = $topPanel/ccCooldown
var current_energy = RunState.current_energy
var currently_selected_card: String = ""
var level_script: Node = null


# Stores all card scenes in a dictionary
var card_scenes = {
	"bomber": preload("res://scenes/bomber_card_ui.tscn"),
	"shielder": preload("res://scenes/shielder_card_ui.tscn"),
	"generator": preload("res://scenes/generator_card_ui.tscn"),
	"thrower": preload("res://scenes/thrower_card_ui.tscn"),
	"swordsman": preload("res://scenes/swordsman_card_ui.tscn")
}



func _ready() -> void:
	# Sets the base energy
	var base_energy: int = 100
	RunState.current_energy = base_energy + RunState.energy_bonus
	current_energy = RunState.current_energy
	print("Initial Level Energy: ", RunState.current_energy)
	await get_tree().process_frame 
	
	# Loadout setup
	var loadout = Global.saved_loadout
	var card_scale: float = 0.58
	for id in loadout:
		#insert loadout and connect
		if card_scenes.has(id):
			var card_instance = card_scenes[id].instantiate()
			if "card_id" in card_instance:
				card_instance.card_id = id
			if card_instance.has_signal("card_clicked"):
				card_instance.card_clicked.connect(_select_card)
			$CardContainer.add_child(card_instance)
	_update_card_label("")

# Constantly updates the cooldown label and the energy display label
func _process(_delta: float) -> void:
	$topPanel/energyLabel.text = "ENERGY: " + str(RunState.current_energy)
	_update_cooldown_label()


# Function to select a card. If the same card that is equipped is clicked again,
# sets the currently selected card to nothing (effectively deselecting it). Otherwise,
# just sets the currently selected card to whatever was clicked.
func _select_card(card_id: String) -> void:
	if currently_selected_card == card_id:
		currently_selected_card = ""
		SignalBus.card_selected.emit("")
		_update_card_label("")
	else:
		currently_selected_card = card_id
		SignalBus.card_selected.emit(card_id)
		_update_card_label(card_id)


# Sets the card label. If none present, sets it to Card: None. If it's the shovel,
# sets accordingly. Otherwise, sets it to the name of the card.
func _update_card_label(card_id: String) -> void:
	if card_id == "":
		cc_label.text = "Card: None"
	elif card_id == "shovel":
		cc_label.text = "Card: Hammer"
	else:
		var card_data = CardDatabase.get_card(card_id)
		if not card_data.is_empty():
			cc_label.text = "Card: " + card_data["name"]
		else:
			cc_label.text = "Card: None"

func _update_cooldown_label() -> void:
	# Immediately show Ready if noCooldowns debug flag is enabled
	if DebugMenu.noCooldowns or currently_selected_card == "shovel" or currently_selected_card == "":
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
