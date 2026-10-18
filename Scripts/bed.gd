extends Node2D

@onready var sleep_anim: AnimatedSprite2D = $PlayerSleepAnim
@onready var interact_area: Area2D = $InteractionArea
@onready var exit_point: Marker2D = $ExitPoint

var player_in_range: Node2D = null
var is_occupied := false
var busy := false  # evita spam durante animações

func _ready() -> void:
	sleep_anim.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range and not is_occupied:
		player_in_range = null

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or busy:
		return
	if is_occupied:
		_get_up()
	elif player_in_range:
		_lay_down()

func _lay_down() -> void:
	busy = true
	is_occupied = true

	# Trava e esconde o player
	player_in_range.set_physics_process(false)
	player_in_range.set_process_unhandled_input(false)
	player_in_range.visible = false
	player_in_range.get_node("CollisionShape2D").set_deferred("disabled", true)

	# Toca a animação na cama
	sleep_anim.visible = true
	sleep_anim.play("lay_down")
	await sleep_anim.animation_finished
	busy = false

func _get_up() -> void:
	busy = true


	sleep_anim.visible = false

	# Devolve o player
	var player := player_in_range
	player.global_position = exit_point.global_position
	player.visible = true
	player.get_node("CollisionShape2D").set_deferred("disabled", false)
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)

	is_occupied = false
	busy = false
