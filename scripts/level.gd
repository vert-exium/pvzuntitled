extends Node2D

# Defines the grid size
const ROWS: int = 5
const COLS: int = 8

# Loads the cursor image
const SHOVEL_CURSOR = preload("res://assets/cursor.png") 

# Defines the size of the cells, where the grid starts, and the grid drawer node
@export var cell_size: Vector2 = Vector2(160, 160)
@export var grid_origin: Vector2 = Vector2(160, 245)
@onready var grid_drawer: Node2D = $GridDrawer

@export var line_color: Color = Color(0.0, 0.0, 0.0, 0.4)
@export var line_thickness: float = 2.0

var grid_tween: Tween
var enemy_placement_options 
# Creates a dictionary to track which grids are free and which are occupied.
var grid_occupied: Dictionary = {}

# Tracks the last timestamp (in milliseconds) when each card was placed
var card_cooldowns: Dictionary = {}

# Define the nodes that contain plant and enemy scenes.
@onready var plants_container: Node2D = $Plants
@onready var enemies_container: Node2D = $Enemies

# Preloads enemy scenes
var enemy_scene_normal = preload("res://scenes/enemy.tscn")
var enemy_scene_tank = preload("res://scenes/tank.tscn")

# A variable to store the currently selected card
var currently_selected_card: String = ""

# A dictionary that stores the scenes for all cards
var plant_scenes: Dictionary = {
	"generator": preload("res://scenes/generator.tscn"),
	"thrower": preload("res://scenes/thrower.tscn"),
	"bomber": preload("res://scenes/bomber.tscn"),
	"shielder": preload("res://scenes/shielder.tscn"),
	"swordsman": preload("res://scenes/swordsman.tscn"),
	"archer": preload("res://scenes/archer.tscn")
}

# Connects signals, and starts the level
func _ready() -> void:
	$musicPlayer.play()
	SignalBus.card_selected.connect(_on_card_selected)
	SignalBus.request_enemy_spawn.connect(_on_request_enemy_spawn)
	grid_drawer.draw.connect(_draw_grid_overlay)
	if grid_drawer:
		grid_drawer.modulate.a = 0.0
	LevelManager.call_deferred("start_level")

# Stores the currently selected card, and prints a debug message.
func _on_card_selected(card_id: String) -> void:
	currently_selected_card = card_id
	print("Equipped " + currently_selected_card)
	
	if currently_selected_card == "shovel":
		Input.set_custom_mouse_cursor(SHOVEL_CURSOR, Input.CURSOR_ARROW)
	else:
		Input.set_custom_mouse_cursor(null)
	
	if grid_drawer != null:
		grid_drawer.queue_redraw()
		
		if grid_tween and grid_tween.is_running():
			grid_tween.kill()
		
		grid_tween = create_tween()
		
		if currently_selected_card != "":
			grid_tween.tween_property(grid_drawer, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_SINE)
		else:
			grid_tween.tween_property(grid_drawer, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE)

func _process(delta: float) -> void:
	if is_instance_valid(grid_drawer):
		grid_drawer.queue_redraw()

func _draw_grid_overlay() -> void:
	var is_shovel = (currently_selected_card == "shovel")
	
	for row in range(ROWS):
		for col in range(COLS):
			var grid_pos = Vector2i(col, row)
			var cell_pos = grid_origin + Vector2(col * cell_size.x, row * cell_size.y)
			var rect = Rect2(cell_pos, cell_size)
			var empty = is_cell_empty(grid_pos)
			
			if is_shovel:
				if empty:
					grid_drawer.draw_rect(rect, Color(0.9, 0.0, 0.0, 0.3))
				else:
					grid_drawer.draw_rect(rect, Color(0.2, 0.9, 0.2, 0.5))
					grid_drawer.draw_rect(rect, Color(0.2, 1.0, 0.2, 0.8), false, 3.0)
			else:
				if empty:
					grid_drawer.draw_rect(rect, Color(0.2, 0.9, 0.2, 0.3))
				else:
					grid_drawer.draw_rect(rect, Color(0.9, 0.0, 0.0, 0.5))
					grid_drawer.draw_rect(rect, Color(1.0, 0.0, 0.0, 0.6), false, 3.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var grid_pos = world_to_grid(get_global_mouse_position())
		
		if not is_valid_cell(grid_pos):
			return
			
		if currently_selected_card == "shovel":
			if not is_cell_empty(grid_pos):
				if RunState.try_use_shovel():
					grid_occupied[grid_pos].queue_free()
					grid_occupied.erase(grid_pos)
			return

		if is_cell_empty(grid_pos) and currently_selected_card != "":
			place_plant(currently_selected_card, grid_pos)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local_pos = world_pos - grid_origin
	var col = int(local_pos.x / cell_size.x)
	var row = int(local_pos.y / cell_size.y)
	return Vector2i(col, row)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return grid_origin + Vector2(
		grid_pos.x * cell_size.x + (cell_size.x / 2.0),
		grid_pos.y * cell_size.y + (cell_size.y / 2.0)
	)

func is_valid_cell(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < COLS and grid_pos.y >= 0 and grid_pos.y < ROWS

func is_cell_empty(grid_pos: Vector2i) -> bool:
	if grid_occupied.has(grid_pos):
		if not is_instance_valid(grid_occupied[grid_pos]):
			grid_occupied.erase(grid_pos)
			return true
		return false
	return true

func is_card_on_cooldown(card_id: String) -> bool:
	if DebugMenu.noCooldowns:
		return false

	if not card_cooldowns.has(card_id):
		return false
		
	var card_data = CardDatabase.get_card(card_id)
	if card_data.is_empty():
		return false

	var cooldown_duration_ms = card_data["cooldown"] * 1000.0
	var time_since_last_use = Time.get_ticks_msec() - card_cooldowns[card_id]
	
	return time_since_last_use < cooldown_duration_ms

func get_remaining_cooldown(card_id: String) -> float:
	if DebugMenu.noCooldowns:
		return 0.0

	if not card_cooldowns.has(card_id):
		return 0.0
		
	var card_data = CardDatabase.get_card(card_id)
	if card_data.is_empty():
		return 0.0

	var cooldown_duration_ms = card_data["cooldown"] * 1000.0
	var time_since_last_use = Time.get_ticks_msec() - card_cooldowns[card_id]
	var remaining_ms = cooldown_duration_ms - time_since_last_use
	
	return max(0.0, remaining_ms / 1000.0)

func place_plant(card_id: String, grid_pos: Vector2i) -> bool:
	var card_data = CardDatabase.get_card(card_id)
	if card_data.is_empty():
		return false
		
	if is_card_on_cooldown(card_id):
		print(card_id, " is on cooldown! Remaining: ", get_remaining_cooldown(card_id), "s")
		return false
	
	if not RunState.try_spend_energy(card_data["cost"]):
		print("Not enough energy!")
		return false
	
	var scene_to_spawn = plant_scenes[card_id]
	var plant = scene_to_spawn.instantiate()
	
	plant.position = grid_to_world(grid_pos)
	plants_container.add_child(plant)
	
	grid_occupied[grid_pos] = plant
	
	if not DebugMenu.noCooldowns:
		card_cooldowns[card_id] = Time.get_ticks_msec()
		print(card_id, " planted successfully. Cooldown started.")
	else:
		card_cooldowns.erase(card_id)
		print(card_id, " planted successfully. (No Cooldown)")
		
	return true

# Function to spawn enemies based on wave budget
func spawn_enemy(lane_index: int, budget: float) -> void:
	if lane_index < 0 or lane_index >= ROWS:
		return

	# Set enemy costs
	# When adding an enemy add a var (unit)_cost: float = (unit_cost)
	var normal_cost: float = 1.0
	var tank_cost: float = 2.0

	# Early exit if budget can't afford even the cheapest enemy
	if budget < normal_cost:
		return

	# Filter affordable enemies based on available budget
	# Add an if statement comparing the budget to the cost: budget >= unit_cost
	# Essentially just copy an if statement and change it a bit
	var affordable_options: Array = []
	if budget >= normal_cost:
		affordable_options.append(enemy_scene_normal)
	if budget >= tank_cost:
		affordable_options.append(enemy_scene_tank)

	if affordable_options.is_empty():
		return

	# Pick a random enemy from the options we can actually afford
	var chosen_enemy = affordable_options.pick_random()

	var enemy_to_place: PackedScene
	var cost_deducted: float = 0.0
	var chosen_id: String = ""
#Set the enemy to be placed and other values
# For every added enemy, make another elif statement, same as the previous except with variables for that enemy
# if chosen_enemy == enemy_scene_placeholder:
	#enemy_to_palce = enemy_scene_placeholder
	#cost_deducted = placeholder_cost
	#chosen_id = "placholder"
	if chosen_enemy == enemy_scene_tank:
		enemy_to_place = enemy_scene_tank
		cost_deducted = tank_cost
		chosen_id = "tank"
	elif chosen_enemy == enemy_scene_normal:
		enemy_to_place = enemy_scene_normal
		cost_deducted = normal_cost
		chosen_id = "normal"

	#Prevent instantiating a null scene
	if enemy_to_place == null:
		print("No enemy to place.")
		return

	var enemy = enemy_to_place.instantiate()
	enemy.enemy_id = chosen_id
	enemy.lane = lane_index

	var spawn_y = grid_origin.y + (lane_index * cell_size.y) + (cell_size.y / 2.0)
	var spawn_x = grid_origin.x + (COLS * cell_size.x) + 50.0
	enemy.position = Vector2(spawn_x, spawn_y)

	enemies_container.add_child(enemy)

	# Deduct cost from LevelManager
	LevelManager.register_spawned_enemy(cost_deducted)

# Receives the signal with the current budget argument
func _on_request_enemy_spawn(budget: float) -> void:
	var random_lane = randi() % ROWS
	spawn_enemy(random_lane, budget)

# A function which draws the faint overlay over the grid
func _draw() -> void:
	var grid_width = COLS * cell_size.x
	var grid_height = ROWS * cell_size.y
	
	for col in range(COLS + 1):
		var x = grid_origin.x + (col * cell_size.x)
		draw_line(Vector2(x, grid_origin.y), Vector2(x, grid_origin.y + grid_height), line_color, line_thickness)
	
	for row in range(ROWS + 1):
		var y = grid_origin.y + (row * cell_size.y)
		draw_line(Vector2(grid_origin.x, y), Vector2(grid_origin.x + grid_width, y), line_color, line_thickness)
