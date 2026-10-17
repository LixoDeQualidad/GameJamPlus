extends Node2D

signal closed

@export var speed: float = 300.0
@export var max_distance: float = 800.0   # até onde a visão pode se afastar
@export var zoom_level: float = 2.0

@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	camera.zoom = Vector2(zoom_level, zoom_level)
	camera.make_current()

func _process(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	camera.position += dir * speed * delta
	camera.position = camera.position.limit_length(max_distance)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		closed.emit()
		queue_free()
