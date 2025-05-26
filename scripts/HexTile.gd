extends Area2D

# Emits quan canvia l'estat de la tile
signal estat_canviat(q, r, estat)

# Enum per l'estat de la tile
enum State { HIDDEN, REVEALED }

# Variables de la tile
var state = State.HIDDEN # Estat actual de la tile
var original_position = Vector2.ZERO # Posició original de la tile
var tween: Tween # Tween per animar la tile
var q: int # Coordenada q de la tile
var r: int # Coordenada r de la tile
var is_animating = false # Indica si la tile està en procés d'animació

# Actualitza l'estat de la tile i emiteix el senyal
func set_state(new_state):
	state = new_state # Actualitza l'estat de la tile
	match state: # Actualitza el color de la tile segons l'estat
		State.HIDDEN: # Color fosc
			$Sprite2D.modulate = Color(0.2, 0.2, 0.2, 1)
		State.REVEALED: # Color clar
			$Sprite2D.modulate = Color(1, 1, 1, 1)
	emit_signal("estat_canviat", q, r, state) # Emiteix el senyal de canvi d'estat

# Inicialitza la tile
func _ready():
	original_position = position # Actualitza la posició original de la tile
	
# Detecta el clic de la tile
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_animating:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if state == State.HIDDEN:
			set_state(State.REVEALED)
			if tween: tween.kill()
			tween = create_tween()
			tween.tween_property(self, "position", original_position, 0.15)
			$AudioStreamPlayer2D.play()

# Detecta el pas del ratolí sobre la tile
func _on_mouse_entered() -> void:
	if state == State.HIDDEN and not is_animating: # Si la tile està amagada i no està en procés d'animació
		if tween: tween.kill() # Atura qualsevol tween anterior
		tween = create_tween() # Crea un nou tween
		tween.tween_property(self, "position", original_position + Vector2(0, -3), 0.15) # Anima la tile a la posició original + 3 píxels amunt

# Detecta el pas del ratolí fora de la tile
func _on_mouse_exited() -> void:
	if not is_animating: # Si no està en procés d'animació
		if tween: tween.kill() # Atura qualsevol tween anterior
		tween = create_tween() # Crea un nou tween
		tween.tween_property(self, "position", original_position, 0.15) # Anima la tile a la posició original

# Anima la tile a la posició original
func animate_to_position(target_position: Vector2, duration := 0.4):
	is_animating = true # Indica que la tile està en procés d'animació
	if tween: tween.kill() # Atura qualsevol tween anterior
	tween = create_tween() # Crea un nou tween
	tween.tween_property(self, "position", target_position, duration) # Anima la tile a la posició target
	tween.tween_callback(Callable(self, "_on_animation_finished")) # Quan finalitza l'animació, crida a la funció _on_animation_finished

# Quan finalitza l'animació
func _on_animation_finished():
	is_animating = false # Indica que la tile no està en procés d'animació
	original_position = position # Actualitza la posició original de la tile

# Actualitza la posició original de la tile
func _set_original_position():
	original_position = position # Actualitza la posició original de la tile
