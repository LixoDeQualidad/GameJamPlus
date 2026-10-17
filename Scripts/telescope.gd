extends Area2D

@export var view_scene: PackedScene   # arraste TelescopeView.tscn aqui

var player: Node2D = null
var view: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body == player and view == null:
		player = null

func _unhandled_input(event: InputEvent) -> void:
	if player and view == null and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_open_view()

func _open_view() -> void:
	view = view_scene.instantiate()
	view.global_position = global_position  # a visão começa no telescópio
	view.closed.connect(_on_view_closed)
	get_tree().current_scene.add_child(view)
	player.set_physics_process(false)       # trava o player

func _on_view_closed() -> void:
	view = null
	if player:
		player.set_physics_process(true)
		var cam := player.get_node_or_null("Camera2D") as Camera2D
		if cam:
			cam.make_current()              # devolve a câmera ao player
