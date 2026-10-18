extends Area2D
@onready var dica: Label = $Label
signal interagido
var ja_interagido := false


@export var dialogue_lines: Array[String] = [
	"Eu não tenho vontade de sair..."


]

var dialogue_index := 0
var is_talking := false

var player_in_range: Node = null

@onready var dialogue_box = get_node("/root/RoomDia1/DialogueBox")# ajuste o caminho

func _ready() -> void:
	dica.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range:
		player_in_range.play_nop()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("play_nop"):
		player_in_range = body
		dica.visible = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		_end_dialogue()
		dica.visible = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if not is_talking:
			_start_dialogue()
		elif dialogue_box.is_typing:
			dialogue_box.skip_typing()
		else:
			_advance_dialogue()
		if not ja_interagido:
			ja_interagido = true
			interagido.emit()


func _start_dialogue():
	is_talking = true
	dialogue_index = 0
	dialogue_box.show()
	dialogue_box.set_text(dialogue_lines[dialogue_index])

func _advance_dialogue():
	dialogue_index += 1
	if dialogue_index >= dialogue_lines.size():
		_end_dialogue()
	else:
		dialogue_box.set_text(dialogue_lines[dialogue_index])

func _end_dialogue():
	is_talking = false
	dialogue_box.stop_typing()
	dialogue_box.hide()
