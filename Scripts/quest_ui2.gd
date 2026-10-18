extends CanvasLayer

@onready var painel: PanelContainer = $Painel
@onready var label: Label = $Painel/Margem/Label

# Item da pizza que completa a quest 1 (precisa ter o sinal "interagido")
@export var item_pizza: Node

# Porta que cria a pizza em tempo de jogo (sinal "item_spawned")
@export var porta: Node

# Item da cama que completa a quest 2 (precisa ter o sinal "interagido")
@export var item_cama: Node

# Textos das quests (edite no Inspector)
@export var texto_pizza: String = "Coma a pizza"
@export var texto_cama: String = "Vá para a cama"

# Cena para a qual trocar ao completar a última quest
@export_file("*.tscn") var proxima_cena: String = ""

enum Quest { COMER_PIZZA, IR_PARA_CAMA, NENHUMA }
var quest_atual: Quest = Quest.COMER_PIZZA

func _ready() -> void:
	# Continua rodando mesmo com o jogo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Quest 1: sinal da pizza (já na cena ou criada pela porta)
	if item_pizza:
		_conectar_pizza(item_pizza)
	if porta:
		porta.item_spawned.connect(_conectar_pizza)
	if not item_pizza and not porta:
		push_warning("item_pizza ou porta precisa ser definido no Inspector.")

	# Quest 2: sinal da cama
	if item_cama:
		if not item_cama.interagido.is_connected(_on_cama_interagida):
			item_cama.interagido.connect(_on_cama_interagida)
	else:
		push_warning("item_cama não foi definido no Inspector.")

	_mostrar_quest(texto_pizza)

# ---------- QUEST 1: COMER A PIZZA ----------

func _conectar_pizza(pizza: Node) -> void:
	if not pizza.interagido.is_connected(_on_pizza_interagida):
		pizza.interagido.connect(_on_pizza_interagida)

func _on_pizza_interagida() -> void:
	if quest_atual != Quest.COMER_PIZZA:
		return
	_completar_pizza()

func _completar_pizza() -> void:
	# Muda o estado já aqui para evitar completar duas vezes
	quest_atual = Quest.NENHUMA
	label.text = "✔ " + texto_pizza
	label.modulate = Color.LIME_GREEN
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(painel, "modulate:a", 0.0, 0.8)
	tween.tween_callback(_iniciar_ir_para_cama)

# ---------- QUEST 2: IR PARA A CAMA ----------

func _iniciar_ir_para_cama() -> void:
	quest_atual = Quest.IR_PARA_CAMA
	_mostrar_quest(texto_cama)

func _on_cama_interagida() -> void:
	if quest_atual != Quest.IR_PARA_CAMA:
		return
	_completar_cama()

func _completar_cama() -> void:
	quest_atual = Quest.NENHUMA
	label.text = "✔ " + texto_cama
	label.modulate = Color.LIME_GREEN
	var tween := create_tween()
	tween.tween_interval(1.0)
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

func _mostrar_quest(texto: String) -> void:
	label.text = texto
	label.modulate = Color.WHITE
	painel.show()
	painel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(painel, "modulate:a", 1.0, 0.5)
