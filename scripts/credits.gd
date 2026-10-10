extends Control

@export var auto_scroll_speed: float = 10.0
@export var resume_delay: float = 2.5

@onready var scroll_container: ScrollContainer = $ScrollContainer

var is_auto_scrolling: bool = true
var pause_timer: float = 0.0
var scroll_bar: VScrollBar
var scroll_accumulator: float = 0.0

func _ready() -> void:
	scroll_bar = scroll_container.get_v_scroll_bar()

func _process(delta: float) -> void:
	if not is_auto_scrolling:
		pause_timer -= delta
		if pause_timer <= 0.0:
			is_auto_scrolling = true
		return
	
	if is_auto_scrolling:
		scroll_accumulator += auto_scroll_speed * delta
		
		if scroll_accumulator >= 1.0:
			var pixels_to_move = int(scroll_accumulator)
			scroll_container.scroll_vertical += pixels_to_move
			scroll_accumulator -= pixels_to_move

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			trigger_manual_interrupt()
		elif event is InputEventScreenDrag or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			trigger_manual_interrupt()

func trigger_manual_interrupt() -> void:
	is_auto_scrolling = false
	pause_timer = resume_delay
	scroll_accumulator = 0.0
