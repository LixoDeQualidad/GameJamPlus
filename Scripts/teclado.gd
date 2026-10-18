extends Area2D

signal interagido
var ja_interagido := false

@onready var dica: Label = $Label

@export var ui_teclado: PackedScene = preload("res://Cenas/teclado_ui.tscn")

var jogador_na_area := false
var ui_aberta: Node = null

func _ready() -> void:
	dica.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_na_area = true
		dica.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_na_area = false
		dica.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if jogador_na_area and event.is_action_pressed("interact"):
		interagir()

func interagir() -> void:
	if ui_aberta:
		return
	ui_aberta = ui_teclado.instantiate()
	get_tree().current_scene.add_child(ui_aberta)
	ui_aberta.fechado.connect(func(): ui_aberta = null)
	if not ja_interagido:
			ja_interagido = true
			interagido.emit()
