extends CanvasLayer

@onready var label = $Panel/Label
@onready var sound_player = $Panel/AudioStreamPlayer2D # veja a nota abaixo

@export var typing_speed := 0.03
@export var voice_sound: AudioStream

var full_text := ""
var is_typing := false
var char_index := 0
var typing_id := 0

func set_text(text: String):
	typing_id += 1
	var my_id := typing_id

	full_text = text
	label.text = ""
	char_index = 0
	is_typing = true

	# Só troca o som se voice_sound foi definido; senão mantém o stream do nó AudioStreamPlayer2D
	if voice_sound:
		sound_player.stream = voice_sound
	sound_player.pitch_scale = randf_range(0.95, 1.05)

	_type_text(my_id)

func _type_text(my_id: int):
	while char_index < full_text.length():
		if my_id != typing_id or not is_typing:
			return

		label.text += full_text[char_index]
		char_index += 1

		# Religa o som se ele tiver acabado
		if not sound_player.playing:
			sound_player.play()

		await get_tree().create_timer(typing_speed).timeout

	if my_id == typing_id:
		_finish_typing()

func skip_typing():
	typing_id += 1  # cancela a digitação em andamento
	label.text = full_text
	_finish_typing()

func stop_typing():
	typing_id += 1
	_finish_typing()

func _finish_typing():
	is_typing = false
	sound_player.stop()
