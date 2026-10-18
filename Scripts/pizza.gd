extends Area2D
signal interagido

@onready var dica: Label = $Label
@export var nome_item: String = "Item"


@export var dialogue_lines: Array[String] = [
	"...que ta até gostoso"
]
  # arraste a imagem aqui pelo Inspector

var dialogue_index := 0
var is_talking := false
var player_in_range := false
var image_open := false
var ja_interagido := false

@onready var dialogue_box = get_node("/root/roomDia1Pt2/DialogueBox") # ajuste o caminho


func _ready() -> void:
	dica.visible = false



func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		dica.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		_end_dialogue()   # só fecha a caixa, sem apagar o item
		_close_image()
		dica.visible = false



func _process(_delta):
	# Enquanto a imagem está aberta, ignora a interação normal
	if image_open:
		return

	if player_in_range and Input.is_action_just_pressed("interact"):
		interagido.emit()
		if not is_talking:
			_start_dialogue()
			if not ja_interagido:
				ja_interagido = true
				interagido.emit()
		elif dialogue_box.is_typing:
			dialogue_box.skip_typing()
		else:
			_advance_dialogue()






func _close_image() -> void:

	if player_in_range:
		dica.visible = true


func _start_dialogue():
	is_talking = true
	dialogue_index = 0
	dialogue_box.show()
	dialogue_box.set_text(dialogue_lines[dialogue_index])

func _advance_dialogue():
	dialogue_index += 1
	if dialogue_index >= dialogue_lines.size():
		_end_dialogue()
		queue_free()   # <-- item some depois que o diálogo termina
	else:
		dialogue_box.set_text(dialogue_lines[dialogue_index])


func _end_dialogue():
	is_talking = false
	dialogue_box.hide()
