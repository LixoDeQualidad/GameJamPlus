extends Control
## Minigame de pedir comida no PC (Godot 4.x)
## Cena: apenas um nó Control (raiz) com este script. A interface é montada por código.

signal pedido_finalizado(itens: Dictionary, total: float)
signal fechado

const CARDAPIO := [
	{"nome": "Pizza", "preco": 40.0},
	{"nome": "Hambúrguer", "preco": 28.0},
	{"nome": "Sushi", "preco": 55.0},
	{"nome": "Refrigerante", "preco": 8.0},
	{"nome": "Sorvete", "preco": 15.0},
]

var carrinho: Dictionary = {}  # nome -> quantidade
var _lista_carrinho: VBoxContainer
var _label_total: Label
var _botao_pedir: Button
var _status: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_montar_ui()
	_atualizar_carrinho()


func _montar_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Fundo escuro (também bloqueia cliques no jogo atrás)
	var fundo := ColorRect.new()
	fundo.color = Color(0.03, 0.05, 0.08, 0.92)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	# "Janela" do site/app
	var janela := PanelContainer.new()
	janela.custom_minimum_size = Vector2(720, 420)
	centro.add_child(janela)

	var margem := MarginContainer.new()
	for lado in ["left", "right", "top", "bottom"]:
		margem.add_theme_constant_override("margin_" + lado, 12)
	janela.add_child(margem)

	var raiz := VBoxContainer.new()
	raiz.add_theme_constant_override("separation", 10)
	margem.add_child(raiz)

	# Barra de título
	var barra := HBoxContainer.new()
	raiz.add_child(barra)
	var titulo := Label.new()
	titulo.text = "🍔 PedeAí - Delivery"
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.add_child(titulo)
	var btn_fechar := Button.new()
	btn_fechar.text = "X"
	btn_fechar.pressed.connect(fechar)
	barra.add_child(btn_fechar)

	raiz.add_child(HSeparator.new())

	# Conteúdo: cardápio (esquerda) | carrinho (direita)
	var conteudo := HBoxContainer.new()
	conteudo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	conteudo.add_theme_constant_override("separation", 20)
	raiz.add_child(conteudo)

	# --- Cardápio ---
	var col_menu := VBoxContainer.new()
	col_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conteudo.add_child(col_menu)
	var lbl_menu := Label.new()
	lbl_menu.text = "Cardápio"
	col_menu.add_child(lbl_menu)

	for item in CARDAPIO:
		var linha := HBoxContainer.new()
		var nome := Label.new()
		nome.text = "%s - R$ %.2f" % [item.nome, item.preco]
		nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		linha.add_child(nome)
		var btn := Button.new()
		btn.text = "+"
		btn.pressed.connect(_adicionar.bind(item.nome))
		linha.add_child(btn)
		col_menu.add_child(linha)

	# --- Carrinho ---
	var col_carrinho := VBoxContainer.new()
	col_carrinho.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conteudo.add_child(col_carrinho)
	var lbl_carrinho := Label.new()
	lbl_carrinho.text = "Seu pedido"
	col_carrinho.add_child(lbl_carrinho)

	_lista_carrinho = VBoxContainer.new()
	_lista_carrinho.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_carrinho.add_child(_lista_carrinho)

	_label_total = Label.new()
	col_carrinho.add_child(_label_total)

	_botao_pedir = Button.new()
	_botao_pedir.text = "Finalizar pedido"
	_botao_pedir.pressed.connect(_finalizar)
	col_carrinho.add_child(_botao_pedir)

	_status = Label.new()
	raiz.add_child(_status)


func _adicionar(nome: String) -> void:
	carrinho[nome] = carrinho.get(nome, 0) + 1
	_atualizar_carrinho()


func _remover(nome: String) -> void:
	carrinho[nome] -= 1
	if carrinho[nome] <= 0:
		carrinho.erase(nome)
	_atualizar_carrinho()


func _preco(nome: String) -> float:
	for item in CARDAPIO:
		if item.nome == nome:
			return item.preco
	return 0.0


func _total() -> float:
	var t := 0.0
	for nome in carrinho:
		t += _preco(nome) * carrinho[nome]
	return t


func _atualizar_carrinho() -> void:
	for filho in _lista_carrinho.get_children():
		filho.queue_free()

	for nome in carrinho:
		var linha := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "%dx %s" % [carrinho[nome], nome]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		linha.add_child(lbl)
		var btn := Button.new()
		btn.text = "-"
		btn.pressed.connect(_remover.bind(nome))
		linha.add_child(btn)
		_lista_carrinho.add_child(linha)

	_label_total.text = "Total: R$ %.2f" % _total()


func _finalizar() -> void:
	if carrinho.is_empty():
		_status.text = "Seu carrinho está vazio!"
		return

	_botao_pedir.disabled = true
	_status.text = "Pedido enviado! Chega em ~30 min."
	pedido_finalizado.emit(carrinho.duplicate(), _total())

	await get_tree().create_timer(1.5).timeout
	fechar()


func fechar() -> void:
	fechado.emit()
	queue_free()
