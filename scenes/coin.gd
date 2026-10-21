extends Area2D

var added_coins = (LevelManager.current_wave/20 + 1) * 10
var magnet_range: float = 800.0
var is_collected: bool = false
var magnet_speed: float = 0.0

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)

func _process(delta: float) -> void:
	if is_collected:
		return
		
	var mouse_pos = get_global_mouse_position()
	var distance = global_position.distance_to(mouse_pos)
	
	if distance < magnet_range:
		magnet_speed += 1000.0 * delta
		global_position = global_position.move_toward(mouse_pos, magnet_speed * delta)
		
		if distance < 15.0:
			collect_coin()

func _on_mouse_entered() -> void:
	collect_coin()

func collect_coin() -> void:
	if is_collected:
		return
	is_collected = true
	SignalBus.coin_collected.emit(added_coins)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)
