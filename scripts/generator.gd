extends Area2D

@onready var timer = $Timer

func _ready() -> void:
	var stats = CardDatabase.get_card("generator")
	timer.wait_time = stats["tick_rate"]
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	$generatorSprite.play("generator")

func _on_timer_timeout() -> void:
	var stats = CardDatabase.get_card("generator")
	var amount = stats["energy_yield"]
	
	RunState.add_energy(amount)
	animate_plant_bounce()
	spawn_floating_text(amount)

func animate_plant_bounce() -> void:
	scale = Vector2(1.1, 0.9)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func spawn_floating_text(amount: int) -> void:
	var popup = Label.new()
	popup.text = "+" + str(amount)
	popup.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	popup.add_theme_font_size_override("font_size", 24)
	popup.position = Vector2(-15, -40)
	
	add_child(popup)
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(popup, "position", popup.position + Vector2(0, -50), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, "modulate:a", 0.0, 1.5)
	tween.chain().tween_callback(popup.queue_free)
