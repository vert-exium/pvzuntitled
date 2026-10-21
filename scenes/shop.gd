extends Control


var current_coins = Global.coins


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#TEMP - FOR TESTING!!!!
	current_coins += 200
	$coinLabel.text = "Coins: " + str(int(current_coins))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
