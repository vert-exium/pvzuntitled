extends Button # Or TextureButton / Control

@onready var label: Label = $"../strengthLabel"
@onready var cardManager = $"../cardManager" 
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	pass

func _on_mouse_entered() -> void:
	var tween = create_tween()
	if cardManager.calculate_total_strength() < 50:
		tween.tween_property(label, "modulate", Color.GREEN, 0.5)
	else:
		tween.tween_property(label, "modulate", Color.RED, 0.5)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(label, "modulate", Color.WHITE, 0.5)
