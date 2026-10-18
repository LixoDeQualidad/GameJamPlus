extends CharacterBody2D

@export var speed: float = 120.0
# passos-quarto.mp3 tem ~3.2s de silêncio no começo; começa a tocar depois dele
@export var footstep_start: float = 3.2
var is_busy := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var footstep_sound: AudioStreamPlayer2D = $SomPassos
@onready var interact_sound: AudioStreamPlayer2D = $SomAcao

# Guarda a última direção para escolher a animação de idle correta
var last_direction: String = "Front"

func _physics_process(_delta: float) -> void:
	if is_busy:
		velocity = Vector2.ZERO
		move_and_slide()
		_stop_footsteps()
		return

	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	_update_animation(direction)
	_update_footsteps(direction)

func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		# Parado: toca o idle da última direção
		match last_direction:
			"Front":
				anim.play("IdleFront")
			"Back":
				anim.play("IdleBack")
			"Side":
				anim.play("IdleSide")
		return

	# Movendo: prioriza o eixo com maior valor
	if abs(direction.x) > abs(direction.y):
		anim.play("walkSide")
		anim.flip_h = direction.x > 0  # espelha para a esquerda
		last_direction = "Side"
	elif direction.y > 0:
		anim.play("walkDown")
		last_direction = "Front"
	else:
		anim.play("wlakUp")  # nome conforme está no seu SpriteFrames
		last_direction = "Back"

# Toca o som de passos em loop enquanto o player se move
func _update_footsteps(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if not footstep_sound.playing:
			footstep_sound.play(footstep_start)
	else:
		_stop_footsteps()

func _stop_footsteps() -> void:
	if footstep_sound.playing:
		footstep_sound.stop()

func play_nop() -> void:
	if is_busy:
		return # evita reiniciar a animação se apertar E de novo
	is_busy = true
	_stop_footsteps()
	interact_sound.play()
	anim.play("nop")
	await anim.animation_finished
	is_busy = false
