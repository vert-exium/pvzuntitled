extends Node

# This script is autoloaded. Manages various functions and stores
# variables for all scripts to access while the game is running.

# Variables
var current_energy: int = 100
var energy_bonus: int = 0 
var shovel_cost: int = 20

# Creates a timer, adjusts it's properties, and
# connects the timeout signal to a function.
func _ready() -> void:
	var passive_timer = Timer.new()
	passive_timer.autostart = true
	passive_timer.timeout.connect(_on_passive_energy_tick)
	add_child(passive_timer)

# Adds the requested amount of energy and 
# emits the energy changed signal in SignalBus.
func add_energy(amount: int) -> void:
	current_energy += amount
	SignalBus.energy_changed.emit(current_energy)

# Checks if the user has enough energy to
# spend on the requested amount of energy. 
# If so, deducts that amount from the total
# energy and emits the energy changed signal
# in SignalBus.
# Returns a bool, either true if successful
# or false if it wasn't.
func try_spend_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		SignalBus.energy_changed.emit(current_energy)
		return true
	return false

# A function which tries to use the shovel 
# by spending the required amount of energy.
# Returns true/false if successful or not.
func try_use_shovel() -> bool:
	return try_spend_energy(shovel_cost)

# Every tick (when the timer runs out),
# adds X amount of energy.
func _on_passive_energy_tick() -> void:
	add_energy(10)
