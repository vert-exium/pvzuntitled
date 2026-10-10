extends Button

@onready var label: Label = $"../strengthLabel"

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	# Use the lightweight check function instead of the main one
	var current_strength = CardManager.get_current_strength()
	var tween = create_tween()
	
	if current_strength <= 50:
		tween.tween_property(self, "modulate", Color.GREEN, 0.2)
		label.add_theme_color_override("font_outline_color", Color.GREEN)
	else:
		tween.tween_property(self, "modulate", Color.RED, 0.2)
		label.add_theme_color_override("font_outline_color", Color.RED)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	label.add_theme_color_override("font_outline_color", Color.WHITE)
