extends Node

var current_energy: int = 50
var shovel_cost: int = 5.0

func _ready() -> void:
	var passive_timer = Timer.new()
	passive_timer.wait_time
	passive_timer.autostart = true
	passive_timer.timeout.connect(_on_passive_energy_tick)
	add_child(passive_timer)

func add_energy(amount: int) -> void:
	current_energy += amount
	SignalBus.energy_changed.emit(current_energy)

func try_spend_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		SignalBus.energy_changed.emit(current_energy)
		return true
	return false

func try_use_shovel() -> bool:
	return try_spend_energy(shovel_cost)

func _on_passive_energy_tick() -> void:
	add_energy(10)
