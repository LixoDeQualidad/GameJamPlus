extends Area2D

@export var tela_scene: PackedScene   # arraste a cena da tela no Inspetor

var player_perto := false
var tela_aberta: Node = null


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_perto = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_perto = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_perto and tela_aberta == null:
		abrir_tela()

func abrir_tela() -> void:
	tela_aberta = tela_scene.instantiate()
	get_tree().current_scene.add_child(tela_aberta)
	tela_aberta.tree_exited.connect(func(): tela_aberta = null)
	get_tree().paused = true   # pausa o jogo enquanto usa o PC
