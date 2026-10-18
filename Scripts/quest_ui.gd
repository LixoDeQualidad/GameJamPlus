extends CanvasLayer

@onready var painel: PanelContainer = $Painel
@onready var label: Label = $Painel/Margem/Label

# Objeto que emite o sinal "fechado"
@export var objeto_fechado: Node

# Cena para a qual trocar ao completar a quest
@export_file("*.tscn") var proxima_cena: String = "res://Cenas/room_dia_1_pt_2.tscn"

enum Quest { EXPLORAR, PEDIR_COMIDA, NENHUMA }
var quest_atual: Quest = Quest.EXPLORAR

var total := 5
var feitos := 0

func _ready() -> void:
	# Continua rodando com o jogo pausado (o PC pausa o jogo)
	process_mode = Node.PROCESS_MODE_ALWAYS

	var itens := get_tree().get_nodes_in_group("item_quest")
	total = itens.size()
	for item in itens:
		item.interagido.connect(_on_item_interagido)

	# Conecta o sinal desde o início (só é processado na quest certa)
	if objeto_fechado and not objeto_fechado.fechado.is_connected(_on_fechado):
		objeto_fechado.fechado.connect(_on_fechado)

	# O app de comida é criado dinamicamente pelo PC, então detecta quando ele entra na árvore
	get_tree().node_added.connect(_on_node_added)

	_atualizar_texto()

func _on_node_added(node: Node) -> void:
	if node.has_signal("pedido_finalizado") and not node.pedido_finalizado.is_connected(_on_pedido_finalizado):
		node.pedido_finalizado.connect(_on_pedido_finalizado)

func _on_pedido_finalizado(_itens: Dictionary, _total: float) -> void:
	_on_fechado()

# ---------- QUEST 1: EXPLORAR ----------

func _on_item_interagido() -> void:
	if quest_atual != Quest.EXPLORAR:
		return
	feitos += 1
	_atualizar_texto()
	if feitos >= total:
		_completar_explorar()

func _completar_explorar() -> void:
	label.text = "✔ Explore o quarto"
	label.modulate = Color.LIME_GREEN
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(painel, "modulate:a", 0.0, 0.8)
	tween.tween_callback(_iniciar_pedir_comida)

# ---------- QUEST 2: PEÇA COMIDA ----------

func _iniciar_pedir_comida() -> void:
	quest_atual = Quest.PEDIR_COMIDA
	label.text = "Peça comida"
	label.modulate = Color.WHITE
	painel.show()

	painel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(painel, "modulate:a", 1.0, 0.5)

func _on_fechado() -> void:
	if quest_atual != Quest.PEDIR_COMIDA:
		return
	_completar_pedir_comida()

func _completar_pedir_comida() -> void:
	quest_atual = Quest.NENHUMA
	label.text = "✔ Peça comida"
	label.modulate = Color.LIME_GREEN
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(painel, "modulate:a", 0.0, 0.8)
	tween.tween_callback(_trocar_cena)

# ---------- TROCA DE CENA ----------

func _trocar_cena() -> void:
	painel.hide()
	if proxima_cena.is_empty():
		push_warning("proxima_cena não foi definida no Inspector.")
		return
	get_tree().paused = false
	get_tree().change_scene_to_file(proxima_cena)

# ---------- UI ----------

func _atualizar_texto() -> void:
	if quest_atual == Quest.EXPLORAR:
		label.text = "Explore o quarto (%d/%d)" % [feitos, total]
