extends Node2D

# Emitido quando o item (ex.: a pizza) aparece depois da porta abrir
signal item_spawned(item: Node)

@export var knock_interval: float = 3.0
@export_multiline var dialog_text: String = "Vi que você pediu comida, o entregador estava lá embaixo esperando por você, 
então eu peguei"
@export var chars_per_second: float = 30.0
@export var pitch_variation: float = 0.1
@export var npc_scene: PackedScene

@onready var knock_sound: AudioStreamPlayer2D = $KnockSound
@onready var talk_sound: AudioStreamPlayer2D = $PeepholeUI/TalkSound
@onready var icon: Label = $Icon
@onready var area: Area2D = $InteractionArea
@onready var knock_timer: Timer = $KnockTimer
@onready var peephole_ui: CanvasLayer = $PeepholeUI
@onready var dialog_label: Label = $PeepholeUI/Panel/Label
@onready var peephole_image: Sprite2D = $PeepholeUI/PeepholeImage
@onready var door_sprite: Sprite2D = $DoorSprite
@export var item_scene: PackedScene
@export var item_offset: Vector2 = Vector2(0, 2)

var player_in_range := false
var peeking := false
var player_ref: Node = null
var typing_id := 0  # evita que digitações antigas continuem rodando
var dialog_finished := false
var door_opened := false


func _ready() -> void:
	peephole_ui.hide()
	icon.show()

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	knock_timer.wait_time = knock_interval
	knock_timer.timeout.connect(_knock)

	_knock()
	knock_timer.start()


func _knock() -> void:
	knock_sound.play()


func _unhandled_input(event: InputEvent) -> void:
	if door_opened:
		return
	if event.is_action_pressed("interact") and player_in_range:
		if peeking:
			_close_peephole()
		else:
			_open_peephole()


func _open_peephole() -> void:
	peeking = true
	dialog_finished = false
	peephole_ui.show()
	peephole_image.modulate.a = 0.0
	peephole_image.show()
	var fade := create_tween()
	fade.tween_property(peephole_image, "modulate:a", 1.0, 0.4)

	if player_ref:
		player_ref.set_physics_process(false)

	_type_text(dialog_text)


func _type_text(text: String) -> void:
	typing_id += 1
	var my_id := typing_id

	dialog_label.text = text
	dialog_label.visible_characters = 0

	var delay := 1.0 / chars_per_second

	for i in text.length():
		# Se fechou a mira ou começou outra digitação, para
		if my_id != typing_id or not peeking:
			return

		dialog_label.visible_characters = i + 1

		var c := text[i]
		if c != " " and c != "\n" and c != "," and c != "." and c != "!" and c != "?":
			talk_sound.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
			talk_sound.play()

		await get_tree().create_timer(delay).timeout

	# A fala terminou (só se essa digitação ainda for a atual)
	if my_id == typing_id:
		talk_sound.stop()
		dialog_finished = true


func _close_peephole() -> void:
	peeking = false
	typing_id += 1          # cancela a digitação em andamento
	talk_sound.stop()
	peephole_ui.hide()
	if player_ref:
		player_ref.set_physics_process(true)

	# Se a fala foi até o fim, abre a porta
	if dialog_finished:
		_open_door()


func _open_door() -> void:
	door_opened = true
	icon.hide()
	knock_timer.stop()
	area.set_deferred("monitoring", false)

	# Porta some com fade
	var tween := create_tween()
	tween.tween_property(door_sprite, "modulate:a", 0.0, 0.3)
	await tween.finished
	door_sprite.hide()

	# NPC aparece no lugar da porta
	if npc_scene == null:
		push_warning("npc_scene não foi definida no Inspector da porta!")
		return

	var npc := npc_scene.instantiate()
	npc.modulate.a = 0.0
	get_parent().add_child(npc)
	npc.global_position = door_sprite.global_position

	var npc_tween := create_tween()
	npc_tween.tween_property(npc, "modulate:a", 1.0, 0.3)
	
	if item_scene == null:
		push_warning("item_scene não foi definida no Inspector da porta!")
		return

	var item := item_scene.instantiate()
	item.modulate.a = 0.0
	get_parent().add_child(item)
	item.global_position = door_sprite.global_position + item_offset
	item_spawned.emit(item)

	npc_tween.parallel().tween_property(item, "modulate:a", 1.0, 0.3)


func _on_body_entered(body: Node2D) -> void:
	if door_opened:
		return
	if body.is_in_group("Player"):
		player_in_range = true
		player_ref = body
		icon.hide()
		knock_timer.stop()


func _on_body_exited(body: Node2D) -> void:
	if door_opened:
		return
	if body.is_in_group("Player"):
		player_in_range = false
		if peeking:
			_close_peephole()
		player_ref = null

		# Se a porta abriu ao fechar a mira, não volta com ícone e batidas
		if door_opened:
			return

		icon.show()
		knock_timer.start()
