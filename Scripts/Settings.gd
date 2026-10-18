extends Node

var music_volume: float = 1.0
var sfx_volume: float = 1.0

const SAVE_PATH = "user://settings.cfg"
const ACTIONS_TO_SAVE = ["ui_left", "ui_right", "ui_up", "ui_down", "interact"]


func _ready() -> void:
	load_settings()
	apply_volumes()
	load_keybinds()

func apply_volumes() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))

func save_settings() -> void:
	var config = ConfigFile.new()
	config.load(SAVE_PATH)  # mantém keybinds já salvos
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		# Volume é linear de 0.0 a 1.0; clamp corrige valores salvos com a faixa antiga dos sliders.
		music_volume = clampf(config.get_value("audio", "music_volume", 1.0), 0.0, 1.0)
		sfx_volume = clampf(config.get_value("audio", "sfx_volume", 1.0), 0.0, 1.0)

func save_keybinds() -> void:
	var config = ConfigFile.new()
	config.load(SAVE_PATH)  # mantém volume já salvo

	for action in ACTIONS_TO_SAVE:
		var events = InputMap.action_get_events(action)
		var data := []
		for e in events:
			if e is InputEventKey:
				# As teclas do Input Map usam physical_keycode (keycode fica 0),
				# então é preciso salvar os dois para não perder a tecla.
				data.append({
					"type": "key",
					"keycode": e.keycode,
					"physical_keycode": e.physical_keycode,
				})
			elif e is InputEventMouseButton:
				data.append({"type": "mouse", "button_index": e.button_index})
		config.set_value("keybinds", action, data)

	config.save(SAVE_PATH)

func load_keybinds() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return

	for action in ACTIONS_TO_SAVE:
		if not config.has_section_key("keybinds", action):
			continue
		var data = config.get_value("keybinds", action, [])

		# Monta a lista de eventos válidos antes de apagar os padrões do projeto.
		var new_events := []
		for entry in data:
			if entry["type"] == "key":
				var ev = InputEventKey.new()
				ev.keycode = entry.get("keycode", 0)
				ev.physical_keycode = entry.get("physical_keycode", 0)
				if ev.keycode == 0 and ev.physical_keycode == 0:
					continue  # entrada inválida (salva por versão antiga) — ignora
				new_events.append(ev)
			elif entry["type"] == "mouse":
				var ev = InputEventMouseButton.new()
				ev.button_index = entry["button_index"]
				new_events.append(ev)

		# Se o arquivo não tem nenhuma tecla válida, mantém o padrão do projeto.
		if new_events.is_empty():
			continue

		InputMap.action_erase_events(action)
		for ev in new_events:
			InputMap.action_add_event(action, ev)
