extends Node

# Dictionary containing all cards:

const CARDS = {
	"generator": {
		"name": "Generator",
		"type": "generator",
		"cost": 50,
		"cooldown": 10.0,
		"health": 100,
		"energy_yield": 15,
		"tick_rate": 5
	},
	"thrower": {
		"name": "Thrower",
		"type": "shooter",
		"cost": 100,
		"cooldown": 15.0,
		"health": 150,
		"damage": 20,
		"fire_rate": 1.5
	},
	"bomber": {
		"name": "Bomber",
		"type": "shooter",
		"cost": 350,
		"cooldown": 20.0,
		"health": 200,
		"damage": 25,
		"fire_rate": 4,
	}
}

func get_card(card_id: String) -> Dictionary:
	if CARDS.has(card_id):
		return CARDS[card_id]
	print("card not found: ", card_id)
	return {}
