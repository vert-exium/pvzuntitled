extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CardContainer/generatorButton.pressed.connect(_on_generator_pressed)
	$CardContainer/throwerButton.pressed.connect(_on_thrower_pressed)
	$CardContainer/shovelButton.pressed.connect(_on_shovel_pressed)
	$CardContainer/shovelButton/costLabel.text = str(RunState.shovel_cost)
	$CardContainer/throwerButton/costLabel.text = str(CardDatabase.CARDS["thrower"]["cost"])
	$CardContainer/generatorButton/costLabel.text = str(CardDatabase.CARDS["generator"]["cost"])
	$CardContainer/bomberButton/costLabel.text = str(CardDatabase.CARDS["bomber"]["cost"])
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$topPanel/energyLabel.text = "ENERGY: " + str(RunState.current_energy)

func _on_generator_pressed() -> void:
	SignalBus.card_selected.emit("generator")

func _on_thrower_pressed() -> void:
	SignalBus.card_selected.emit("thrower")

func _on_shovel_pressed() -> void:
	SignalBus.card_selected.emit("shovel")

func _on_bomber_button_pressed() -> void:
	SignalBus.card_selected.emit("bomber")
