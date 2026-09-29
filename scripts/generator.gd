extends Area2D

# Loads timer node
@onready var timer = $Timer


# Loads the stats for the generator card, connects the timer,
# configures it, and starts the animation.
func _ready() -> void:
	var stats = CardDatabase.get_card("generator")
	timer.wait_time = stats["tick_rate"]
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	$generatorSprite.play("generator")

# When the timer runs out, loads stats from the database,
# adds the appropriate amount of energy, and starts the 
# animation functions.
func _on_timer_timeout() -> void:
	var stats = CardDatabase.get_card("generator")
	var amount = stats["energy_yield"]
	
	RunState.add_energy(amount)
	animate_unit_bounce()
	spawn_floating_text(amount)

# Sets the scale instantly, and creates a tween 
# to animate it back to 1x scale
func animate_unit_bounce() -> void:
	scale = Vector2(1.1, 0.9)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

# Creates a label and sets it up (text, font size, color, position)
func spawn_floating_text(amount: int) -> void:
	var popup = Label.new()
	popup.text = "+" + str(amount)
	popup.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	popup.add_theme_font_size_override("font_size", 24)
	popup.position = Vector2(-15, -40)
	
	add_child(popup)
	
	# Creates a tween which animates the position and transparency of the 
	# floating label. When the tweens finish, despawn the label.
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(popup, "position", popup.position + Vector2(0, -50), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, "modulate:a", 0.0, 1.5)
	tween.chain().tween_callback(popup.queue_free)
