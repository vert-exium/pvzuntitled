extends Node2D

@onready var timer = $Timer

func _ready() -> void:
	var stats = CardDatabase.get_card("generator")
	timer.wait_time = stats["tick_rate"]
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	var stats = CardDatabase.get_card("generator")
	RunState.add_energy(stats["energy_yield"])
