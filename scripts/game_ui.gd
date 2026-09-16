extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CardContainer/generatorButton.pressed.connect(_on_generator_pressed)
	$CardContainer/throwerButton.pressed.connect(_on_thrower_pressed)
	$CardContainer/shovelButton.pressed.connect(_on_shovel_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_generator_pressed() -> void:
	SignalBus.card_selected.emit("generator")

func _on_thrower_pressed() -> void:
	SignalBus.card_selected.emit("thrower")

func _on_shovel_pressed() -> void:
	SignalBus.card_selected.emit("shovel")
