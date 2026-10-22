extends Node2D

func _ready() -> void:
	#TEMPORARY - FOR TESTING!!!
	Global.coins += 40000
	$coinLabel.text = "Coins: " + str(int(Global.coins))
	$shopBack/Scroll/VBoxContainer/Upgrade1/currentBoost.text = "Boost: " + str(Global.damage_boost) + "x"
	$shopBack/Scroll/VBoxContainer/Upgrade2/currentBoost.text = "Boost: " + str(Global.attackSpeed_boost) + "x"
	$shopBack/Scroll/VBoxContainer/Upgrade3/currentBoost.text = "Boost: " + str(Global.health_boost) + "x"
	
	#set progress bars when shop is opened (so it saves)
	$shopBack/Scroll/VBoxContainer/Upgrade1/ProgressBar.value = Global.damageProgressBar
	$shopBack/Scroll/VBoxContainer/Upgrade2/ProgressBar.value = Global.speedProgressBar
	$shopBack/Scroll/VBoxContainer/Upgrade3/ProgressBar.value = Global.hpProgressBar
	
	#set level labels when shop is opened
	$shopBack/Scroll/VBoxContainer/Upgrade1/levelLabel.text = "Level: " + str(int(Global.damageLevel)) + "/16"
	$shopBack/Scroll/VBoxContainer/Upgrade2/levelLabel.text = "Level: " + str(int(Global.speedLevel)) + "/16"
	$shopBack/Scroll/VBoxContainer/Upgrade3/levelLabel.text = "Level: " + str(int(Global.hpLevel)) + "/16"
	
	#set price text (on button) when shop is opened
	$shopBack/Scroll/VBoxContainer/Upgrade1/damagePurchaseButton.text = str(int(Global.damageUpgCost)) + " coins"
	$shopBack/Scroll/VBoxContainer/Upgrade2/AttackSpeedpurchaseButton.text = str(int(Global.speedUpgCost)) + " coins"
	$shopBack/Scroll/VBoxContainer/Upgrade3/purchaseButton.text = str(int(Global.hpUpgCost)) + " coins"

func _process(delta: float) -> void:
	$coinLabel.text = "Coins: " + str(int(Global.coins))

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_damage_purchase_button_pressed() -> void:
	if Global.coins >= Global.damageUpgCost and $shopBack/Scroll/VBoxContainer/Upgrade1/ProgressBar.value < 16:
		Global.coins -= int(Global.damageUpgCost)
		Global.damageUpgCost *= 1.2
		
		$shopBack/Scroll/VBoxContainer/Upgrade1/ProgressBar.value += 1
		Global.damageProgressBar += 1.0
		$shopBack/Scroll/VBoxContainer/Upgrade1/damagePurchaseButton.text = str(int(Global.damageUpgCost)) + " coins"
		Global.damage_boost += 0.2
		Global.damageLevel = $shopBack/Scroll/VBoxContainer/Upgrade1/ProgressBar.value
		$shopBack/Scroll/VBoxContainer/Upgrade1/levelLabel.text = "Level: " + str(int(Global.damageLevel)) + "/16"
		$shopBack/Scroll/VBoxContainer/Upgrade1/currentBoost.text = "Boost: " + str(Global.damage_boost) + "x"
	else:
		pass

func _on_attack_speedpurchase_button_pressed() -> void:
	if Global.coins >= Global.speedUpgCost and $shopBack/Scroll/VBoxContainer/Upgrade2/ProgressBar.value < 16:
		Global.coins -= int(Global.speedUpgCost)
		Global.speedUpgCost *= 1.2
		
		$shopBack/Scroll/VBoxContainer/Upgrade2/ProgressBar.value += 1
		Global.speedProgressBar += 1.0
		$shopBack/Scroll/VBoxContainer/Upgrade2/AttackSpeedpurchaseButton.text = str(int(Global.speedUpgCost)) + " coins"
		Global.attackSpeed_boost += 0.2
		Global.speedLevel = $shopBack/Scroll/VBoxContainer/Upgrade2/ProgressBar.value
		$shopBack/Scroll/VBoxContainer/Upgrade2/levelLabel.text = "Level: " + str(int(Global.speedLevel)) + "/16"
		$shopBack/Scroll/VBoxContainer/Upgrade2/currentBoost.text = "Boost: " + str(Global.attackSpeed_boost) + "x"
	else:
		pass

func _on_purchase_button_pressed() -> void:
	if Global.coins >= Global.hpUpgCost and $shopBack/Scroll/VBoxContainer/Upgrade3/ProgressBar.value < 16:
		Global.coins -= int(Global.hpUpgCost)
		Global.hpUpgCost *= 1.2
		
		$shopBack/Scroll/VBoxContainer/Upgrade3/ProgressBar.value += 1
		Global.hpProgressBar += 1.0
		$shopBack/Scroll/VBoxContainer/Upgrade3/purchaseButton.text = str(int(Global.hpUpgCost)) + " coins"
		Global.health_boost += 0.2
		Global.hpLevel = $shopBack/Scroll/VBoxContainer/Upgrade3/ProgressBar.value
		$shopBack/Scroll/VBoxContainer/Upgrade3/levelLabel.text = "Level: " + str(int(Global.hpLevel)) + "/16"
		$shopBack/Scroll/VBoxContainer/Upgrade3/currentBoost.text = "Boost: " + str(Global.health_boost) + "x"
	else:
		pass
