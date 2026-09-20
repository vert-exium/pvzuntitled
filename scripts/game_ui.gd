extends CanvasLayer

@onready var cc_label: Label = $topPanel/currentCard
@onready var cooldown_label: Label = $topPanel/ccCooldown

var currently_selected_card: String = "generator"
var level_script: Node = null

func _ready() -> void:
	# Button signals
	$CardContainer/generatorButton.pressed.connect(_on_generator_pressed)
	$CardContainer/throwerButton.pressed.connect(_on_thrower_pressed)
	$CardContainer/shovelButton.pressed.connect(_on_shovel_pressed)
	$CardContainer/bomberButton.pressed.connect(_on_bomber_button_pressed)
	$CardContainer/shielderButton.pressed.connect(_on_shielder_button_pressed)
	
	# Set energy costs
	$CardContainer/shovelButton/costLabel.text = str(RunState.shovel_cost)
	$CardContainer/throwerButton/costLabel.text = str(CardDatabase.CARDS["thrower"]["cost"])
	$CardContainer/generatorButton/costLabel.text = str(CardDatabase.CARDS["generator"]["cost"])
	$CardContainer/bomberButton/costLabel.text = str(CardDatabase.CARDS["bomber"]["cost"])
	$CardContainer/shielderButton/costLabel.text = str(CardDatabase.CARDS["shielder"]["cost"])
	
	# Initial label setup
	_update_card_label("generator")
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

func _on_shielder_button_pressed() -> void:
	_select_card("shielder")
