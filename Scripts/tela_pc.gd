extends CanvasLayer

func _ready() -> void:
	MusicManager.play_game_music()
	# Necessário para a tela funcionar com o jogo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	MusicManager.play_game_music()

	$Button.pressed.connect(_abrir_app.bind(1))
	$BtnFechar.pressed.connect(fechar)

func _unhandled_input(event: InputEvent) -> void:
	# ESC (ui_cancel) também fecha o computador
	if event.is_action_pressed("ui_cancel"):
		fechar()

func _abrir_app(numero: int) -> void:
	match numero:
		1:
			print("Abrindo App 1")
			# Abre o app dentro da tela do PC (herda o PROCESS_MODE_ALWAYS)
			var app := preload("res://Cenas/app_comida.tscn").instantiate()
			add_child(app)
		2:
			print("Abrindo App 2")
		3:
			print("Abrindo App 3")

func fechar() -> void:
	get_tree().paused = false
	queue_free()
