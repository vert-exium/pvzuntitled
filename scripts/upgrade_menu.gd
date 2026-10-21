extends Node2D

#define coins (from global script)
var coins: int = Global.coins

var damageBarValue = Global.damageProgressBar
var speedBarValue = Global.speedProgressBar
var healthBarValue = Global.hpProgressBar

#Global variables used in this script
#var damage_boost = 1.0
#var attackSpeed_boost = 1.0
#var health_boost = 1.0

#var damageProgressBar = 1.0
#var speedProgressBar = 1.0
#var hpProgressBar = 1.0 

#var damageLevel = 1
#var speedLevel = 1
#var hpLevel = 1

#var damageUpgCost = 100
#var speedUpgCost = 100
#var hpUpgCost = 100



func _ready() -> void:
	#TEMPORARY - FOR TESTING!!!
	coins += 20000
	$coinLabel.text = "Coins: " + str(int(coins))
	$shopBack/Scroll/VBoxContainer/Upgrade1/currentBoost.text = "Boost: " + str(Global.damage_boost) + "x"
	$shopBack/Scroll/VBoxContainer/Upgrade2/currentBoost.text = "Boost: " + str(Global.attackSpeed_boost) + "x"
	$shopBack/Scroll/VBoxContainer/Upgrade3/currentBoost.text = "Boost: " + str(Global.health_boost) + "x"
	#set progress bars when shop is opened (so it saves)
	$shopBack/Scroll/VBoxContainer/Upgrade1/ProgressBar.value = damageBarValue
	$shopBack/Scroll/VBoxContainer/Upgrade2/ProgressBar.value = speedBarValue
	$shopBack/Scroll/VBoxContainer/Upgrade3/ProgressBar.value = healthBarValue
	#set level labels when shop is opened
	$shopBack/Scroll/VBoxContainer/Upgrade1/levelLabel.text = "Level: " + str(int(Global.damageLevel)) + "/16"
	$shopBack/Scroll/VBoxContainer/Upgrade2/levelLabel.text = "Level: " + str(int(Global.speedLevel)) + "/16"
	$shopBack/Scroll/VBoxContainer/Upgrade3/levelLabel.text = "Level: " + str(int(Global.hpLevel)) + "/16"
	#set price text (on button) when shop is opened
	$shopBack/Scroll/VBoxContainer/Upgrade1/damagePurchaseButton.text = str(int(Global.damageUpgCost)) + " coins"
	$shopBack/Scroll/VBoxContainer/Upgrade2/AttackSpeedpurchaseButton.text = str(int(Global.speedUpgCost)) + " coins"
	$shopBack/Scroll/VBoxContainer/Upgrade3/purchaseButton.text = str(int(Global.hpUpgCost)) + " coins"
func _process(delta: float) -> void:
	pass

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_damage_purchase_button_pressed() -> void:
	if coins >= Global.damageUpgCost and not $shopBack/Scroll/VBoxContainer/Upgrade1/ProgressBar.value >= 16:
		Global.damageUpgCost *= 1.2
		coins -= Global.damageUpgCost
		$shopBack/Scroll/VBoxContainer/Upgrade1/ProgressBar.value += 1
		Global.damageProgressBar += 1.0
		$shopBack/Scroll/VBoxContainer/Upgrade1/damagePurchaseButton.text = str(int(Global.damageUpgCost)) + " coins"
		$coinLabel.text = "Coins: " + str(int(coins))
		Global.damage_boost += 0.2
		print("Damage boost: " + str(Global.damage_boost))
		Global.damageLevel = $shopBack/Scroll/VBoxContainer/Upgrade1/ProgressBar.value
		$shopBack/Scroll/VBoxContainer/Upgrade1/levelLabel.text = "Level: " + str(int(Global.damageLevel)) + "/16"
		$shopBack/Scroll/VBoxContainer/Upgrade1/currentBoost.text = "Boost: " + str(Global.damage_boost) + "x"
	else:
		print("yo yo yo! Upgrade cant go that far! (or too poor)")


func _on_attack_speedpurchase_button_pressed() -> void:
	if coins >= Global.speedUpgCost and not $shopBack/Scroll/VBoxContainer/Upgrade2/ProgressBar.value >= 16:
		Global.speedUpgCost *= 1.2
		coins -= Global.speedUpgCost
		$shopBack/Scroll/VBoxContainer/Upgrade2/ProgressBar.value += 1
		Global.speedProgressBar += 1.0
		$shopBack/Scroll/VBoxContainer/Upgrade2/AttackSpeedpurchaseButton.text = str(int(Global.speedUpgCost)) + " coins"
		$coinLabel.text = "Coins: " + str(int(coins))
		Global.attackSpeed_boost += 0.2
		print("Speed boost: " + str(Global.attackSpeed_boost))
		Global.speedLevel = $shopBack/Scroll/VBoxContainer/Upgrade2/ProgressBar.value
		$shopBack/Scroll/VBoxContainer/Upgrade2/levelLabel.text = "Level: " + str(int(Global.speedLevel)) + "/16"
		$shopBack/Scroll/VBoxContainer/Upgrade2/currentBoost.text = "Boost: " + str(Global.attackSpeed_boost) + "x"
	else:
		print("yo yo yo! Upgrade cant go that far! (or too poor)")
