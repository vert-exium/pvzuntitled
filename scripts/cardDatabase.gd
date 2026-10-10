extends Node


# Dictionary which stores information for each card. These can have custom values as well,
# dedicated to specific cards, but they typically contain the following info:
# Internal Name
#    - Display Name (can be capitalized)
#    - Type (currently generator, shooter, or close range)
#    - Cost (energy)
#    - Cooldown to place the card again (in seconds)
#    - Health
#    - As previously mentioned, can contain custom info, such as tick rate, fire rate,
#      damage, knockback, etc. 

const CARDS = {
	"generator": {
		"name": "Generator",
		"type": "generator",
		"cost": 50,
		"cooldown": 8.0,
		"health": 100,
		"energy_yield": 15,
		"tick_rate": 5
	},

	"thrower": {
		"name": "Thrower",
		"type": "shooter",
		"cost": 100,
		"cooldown": 10.0,
		"health": 150,
		"damage": 20,
		"fire_rate": 1.5
	},

	"bomber": {
		"name": "Bomber",
		"type": "shooter",
		"cost": 500,
		"cooldown": 10.0,
		"health": 200,
		"damage": 25,
		"fire_rate": 4
	},

	"shielder": {
		"name": "Shielder",
		"type": "close_range",
		"cost": 350,
		"cooldown": 15,
		"health": 400,
		"damage": 5,
		"fire_rate": 1.5
	},

	"swordsman": {
		"name": "swordsman",
		"type": "close_range",
		"cost": 600,
		"cooldown": 20,
		"health": 250,
		"damage": 25,
		"fire_rate": 1.0,
		"knockback": 20
	},
	"archer": {
		"name": "archer",
		"type": "shooter",
		"cost": 200, 
		"cooldown": 10,
		"health": 200,
		"damage": 30,
		"fire_rate": 2.5
	}
}

# A function which inputs the requested card's ID (internal name) and returns the card's info

func get_card(card_id: String) -> Dictionary:
	if CARDS.has(card_id):
		return CARDS[card_id]
	print("card not found: ", card_id)
	return {}
