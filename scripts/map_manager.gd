extends Node2D
class_name MapManager

# Diccionari per guardar les dades de cada tile
var tiles = {} # Format: { pos_clau: { "node": tile, "pos": Vector2, "estat": estat } }

# Constants per les dimensions de les tiles
const HEX_WIDTH = 64 # Amplada de la tile
const HEX_HEIGHT = 56 # Alçada de la tile

# Offsets axials per als 6 veïns (pointy top)
const directions = [
	Vector2(1, 0), # E
	Vector2(0, 1), # NE
	Vector2(-1, 1), # NW
	Vector2(-1, 0), # W
	Vector2(0, -1), # SW
	Vector2(1, -1) # SE
]

# Converteix coordenades axials a coordenades cartesianes
func axial_to_pixel(q: int, r: int) -> Vector2:
	var x = HEX_WIDTH * 0.75 * q # Calcula la posició x de la tile
	var y = HEX_HEIGHT * (r + q / 2.0) # Calcula la posició y de la tile
	return Vector2(x, y)

# Inicialitza el mapa amb la primera tile
func initialize_map(scene: PackedScene) -> void:
	# Centre (descobert)
	var center_hex = scene.instantiate()
	center_hex.position = Vector2(0, 0)
	center_hex.set_state(center_hex.State.REVEALED)
	center_hex.q = 0
	center_hex.r = 0
	add_child(center_hex)
	tiles["0,0"] = { "node": center_hex, "pos": Vector2(0, 0), "estat": center_hex.state }
	center_hex.connect("estat_canviat", Callable(self, "_on_tile_state_changed").bind(scene))

	# Genera les tiles veïnes inicials
	for dir in directions:
		_create_neighbor_tile(0, 0, dir, scene)

# Crea una nova tile veïna
func _create_neighbor_tile(parent_q: int, parent_r: int, direction: Vector2, scene: PackedScene) -> void:
	var q = parent_q + int(direction.x)
	var r = parent_r + int(direction.y)
	var key = str(q) + "," + str(r)
	
	if not tiles.has(key):
		var neighbor = scene.instantiate()
		var parent_pos = axial_to_pixel(parent_q, parent_r)
		neighbor.position = parent_pos
		neighbor.set_state(neighbor.State.HIDDEN)
		neighbor.q = q
		neighbor.r = r
		add_child(neighbor)
		var final_pos = axial_to_pixel(q, r)
		neighbor.animate_to_position(final_pos)
		tiles[key] = { "node": neighbor, "pos": final_pos, "estat": neighbor.state }
		neighbor.connect("estat_canviat", Callable(self, "_on_tile_state_changed").bind(scene))

# Actualitza l'estat d'una tile i genera veïns si s'ha descobert
func _on_tile_state_changed(q: int, r: int, estat: int, scene: PackedScene) -> void:
	var key = str(q) + "," + str(r)
	if tiles.has(key):
		tiles[key]["estat"] = estat
		print("Tile posició ", q, ",", r, " passa a ", estat, ".")

		if estat == 1: # State.REVEALED
			for dir in directions:
				_create_neighbor_tile(q, r, dir, scene)

# Retorna el diccionari de tiles
func get_tiles() -> Dictionary:
	return tiles

# Retorna la posició d'una tile
func get_tile_position(q: int, r: int) -> Vector2:
	var key = str(q) + "," + str(r)
	if tiles.has(key):
		return tiles[key]["pos"]
	return Vector2.ZERO

# Retorna l'estat d'una tile
func get_tile_state(q: int, r: int) -> int:
	var key = str(q) + "," + str(r)
	if tiles.has(key):
		return tiles[key]["estat"]
	return -1 
