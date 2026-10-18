extends Area2D
signal interagido
signal chegou

@onready var dica: Label = $Label
@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") # opcional
@onready var dialogue_box = get_node("/root/roomDia1Pt2/DialogueBox")

@export_group("Diálogo")
@export var dialogue_lines: Array[String] = [
	"A chuva... Está chegando o dia, vai ser muito especial..."
]

@export_group("Movimento")
@onready var destino = get_node("/root/roomDia1Pt2/destinoNPC")
@export var velocidade := 60.0
@export var comecar_andando := true    # se false, chame iniciar_caminhada() por código

var destino_pos: Vector2
var dialogue_index := 0
var is_talking := false
var player_in_range := false
var ja_interagido := false
var andando := false
var pode_interagir := false
var ultima_direcao := Vector2.DOWN


func _ready() -> void:
	dica.visible = false
	_tocar_anim("idle")

	if destino:
		destino_pos = destino.global_position  # guarda a posição uma única vez

	if destino and comecar_andando:
		iniciar_caminhada()
	else:
		pode_interagir = true


# ---------- MOVIMENTO ----------

func iniciar_caminhada() -> void:
	if destino == null:
		return
	andando = true
	pode_interagir = false
	dica.visible = false


func _physics_process(delta: float) -> void:
	if not andando:
		return

	var direcao := destino_pos - global_position
	ultima_direcao = direcao

	_atualizar_animacao_andando(direcao)

	global_position = global_position.move_toward(destino_pos, velocidade * delta)

	if global_position.distance_to(destino_pos) < 1.0:
		global_position = destino_pos
		_chegar()


func _atualizar_animacao_andando(direcao: Vector2) -> void:
	if sprite == null:
		return

	# Decide pelo eixo dominante
	if abs(direcao.x) > abs(direcao.y):
		sprite.flip_h = direcao.x < 0
		_tocar_anim("walk_side")
	elif direcao.y > 0:
		sprite.flip_h = false
		_tocar_anim("walk_front")
	else:
		# Indo para cima: usa walk_back se existir, senão walk_side
		sprite.flip_h = false
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("walk_back"):
			_tocar_anim("walk_back")
		else:
			_tocar_anim("walk_side")


func _chegar() -> void:
	andando = false
	pode_interagir = true
	_tocar_anim("idle")
	chegou.emit()
	if player_in_range:
		dica.visible = true


func _tocar_anim(nome: String) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(nome):
		return
	if sprite.animation != nome or not sprite.is_playing():
		sprite.play(nome)


# ---------- INTERAÇÃO ----------

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		dica.visible = pode_interagir

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		_end_dialogue()
		dica.visible = false


func _process(_delta):
	if not pode_interagir:
		return

	if player_in_range and Input.is_action_just_pressed("interact"):
		if not is_talking:
			_start_dialogue()
			if not ja_interagido:
				ja_interagido = true
				interagido.emit()
		elif dialogue_box.is_typing:
			dialogue_box.skip_typing()
		else:
			_advance_dialogue()


# ---------- DIÁLOGO ----------

func _start_dialogue():
	is_talking = true
	dialogue_index = 0
	dica.visible = false
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
	dialogue_box.hide()
	if player_in_range and pode_interagir:
		dica.visible = true
