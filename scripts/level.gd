extends Node2D


const ROWS: int = 5
const COLS: int = 8

@export var cell_size: Vector2 = Vector2(80, 80)
@export var grid_origin: Vector2 = Vector2(100, 280)

var grid_occupied: Dictionary = {}

@onready var plants_container: Node2D = $Plants
@onready var enemies_container: Node2D = $Enemies

var generator_scene = preload("res://scenes/generator.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var grid_pos = world_to_grid

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
	return not grid_occupied.has(grid_pos)
