extends Node2D


const ROWS: int = 5
const COLS: int = 8

@export var cell_size: Vector2 = Vector2(160, 160)
@export var grid_origin: Vector2 = Vector2(160, 200)

var grid_occupied: Dictionary = {}

@onready var plants_container: Node2D = $Plants
@onready var enemies_container: Node2D = $Enemies

var generator_scene = preload("res://scenes/generator.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")

var currently_selected_card: String = "generator"

var plant_scenes: Dictionary = {
	"generator": preload("res://scenes/generator.tscn"),
	"thrower": preload("res://scenes/thrower.tscn")
}

func _ready() -> void:
	SignalBus.card_selected.connect(_on_card_selected)

func _on_card_selected(card_id: String) -> void:
	currently_selected_card = card_id
	print("Equipped ", currently_selected_card)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var grid_pos = world_to_grid(get_global_mouse_position())
		
		print("--- CLICK DETECTED ---")
		print("Energy is currently: ", RunState.current_energy)
		print("Holding card: ", currently_selected_card)
		print("Target Grid Pos: ", grid_pos)
		
		if not is_valid_cell(grid_pos):
			print("Result: Click ignored (Outside of grid)")
			return
			
		# SHOVEL LOGIC
		if currently_selected_card == "shovel":
			if not is_cell_empty(grid_pos):
				print("Result: Found a plant here! Attempting to spend 5 energy...")
				if RunState.try_use_shovel():
					print("Result: Energy spent! Plant destroyed.")
					grid_occupied[grid_pos].queue_free()
					grid_occupied.erase(grid_pos)
				else:
					print("Result: FAILED to spend energy for shovel.")
			else:
				print("Result: Nothing to shovel here.")
			return
			
		# PLANTING LOGIC
		if is_cell_empty(grid_pos):
			print("Result: Cell empty, trying to plant...")
			place_plant(currently_selected_card, grid_pos)
		else:
			print("Result: Cannot plant, cell is full.")


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

func place_plant(card_id: String, grid_pos: Vector2i) -> bool:
	var card_data = CardDatabase.get_card(card_id)
	
	if card_data.is_empty():
		return false
	
	if not RunState.try_spend_energy(card_data["cost"]):
		print("Not enough energy!")
		return false
	
	var scene_to_spawn = plant_scenes[card_id]
	var plant = scene_to_spawn.instantiate()
	
	plant.position = grid_to_world(grid_pos)
	plants_container.add_child(plant)
	
	grid_occupied[grid_pos] = plant
	return true


func spawn_enemy(lane_index: int) -> void:
	if lane_index < 0 or lane_index >= ROWS:
		return
	
	var enemy = enemy_scene.instantiate()
	enemy.lane = lane_index
	
	var spawn_y = grid_origin.y + (lane_index * cell_size.y) + (cell_size.y / 2.0)
	var spawn_x = grid_origin.x + (COLS * cell_size.x) + 50.0
	
	enemy.position = Vector2(spawn_x, spawn_y)
	enemies_container.add_child(enemy)


func _on_wave_timer_timeout() -> void:
	var random_lane = randi() % ROWS
	spawn_enemy(random_lane)
