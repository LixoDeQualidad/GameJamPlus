extends CanvasLayer

signal tecla_pressionada(indice: int)
signal fechado

# Todas as teclas tocam o mesmo som (o stream do nó Som), cada uma um semitom
# mais aguda que a anterior, da esquerda para a direita (Tecla01 = índice 0).
@export var semitom_inicial := -24.0   # afinação da Tecla01 (-24 = duas oitavas abaixo do som original)
@export var semitons_por_tecla := 1.0
@export var pausar_jogo := true

@onready var teclas: Control = $Teclado/Teclas
@onready var som: AudioStreamPlayer = $Som

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # continua funcionando com o jogo pausado
	if pausar_jogo:
		get_tree().paused = true

	var indice := 0
	for botao in teclas.get_children():
		if botao is Button:
			botao.pressed.connect(_on_tecla.bind(indice))
			indice += 1

func _on_tecla(indice: int) -> void:
	if som.stream:
		# Um player por nota, para notas seguidas não mudarem a afinação umas das outras
		var nota := AudioStreamPlayer.new()
		nota.stream = som.stream
		nota.volume_db = som.volume_db
		nota.bus = som.bus
		nota.pitch_scale = pow(2.0, (semitom_inicial + indice * semitons_por_tecla) / 12.0)
		nota.finished.connect(nota.queue_free)
		add_child(nota)
		nota.play()
	tecla_pressionada.emit(indice)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):   # ESC
		fechar()
		get_viewport().set_input_as_handled()

func fechar() -> void:
	if pausar_jogo:
		get_tree().paused = false
	fechado.emit()
	queue_free()
