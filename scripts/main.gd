extends Node2D

const HEX_TILE_SCENE = preload("res://scenes/HexTile.tscn")

# Offsets axials per als 6 veïns (pointy top)
var directions = [
	Vector2(1, 0), # E
	Vector2(0, 1), # NE
	Vector2(-1, 1), # NW
	Vector2(-1, 0), # W
	Vector2(0, -1), # SW
	Vector2(1, -1) # SE
]

const HEX_WIDTH = 64 # Amplada de la tile
const HEX_HEIGHT = 56 # Alçada de la tile

# Diccionari per guardar les dades de cada tile
var tiles = {} # Format: { pos_clau: { "node": tile, "pos": Vector2, "estat": estat } }

# Converteix coordenades axials a coordenades cartesianes
func axial_to_pixel(q, r):
	var x = HEX_WIDTH * 0.75 * q # Calcula la posició x de la tile
	var y = HEX_HEIGHT * (r + q / 2.0) # Calcula la posició y de la tile
	return Vector2(x, y) # Retorna la posició en coordenades cartesianes

# Inicialitza el joc
func _ready():
	# Centra el Node2D al centre de la pantalla
	position = get_viewport_rect().size / 2 # Centra el Node2D al centre de la pantalla

	# Centre (descobert)
	var center_hex = HEX_TILE_SCENE.instantiate() # Crea una nova tile
	center_hex.position = Vector2(0, 0) # Inicia a la posició (0, 0)
	center_hex.set_state(center_hex.State.REVEALED) # Actualitza l'estat de la tile
	center_hex.q = 0 # Actualitza la coordenada q de la tile
	center_hex.r = 0 # Actualitza la coordenada r de la tile
	add_child(center_hex) # Afegeix la tile al Node2D
	tiles["0,0"] = { "node": center_hex, "pos": Vector2(0, 0), "estat": center_hex.state } # Afegeix la tile al diccionari
	center_hex.connect("estat_canviat", Callable(self, "update_tile_state")) # Connecta el senyal de canvi d'estat a la funció update_tile_state

	# Per cada direcció, crea una nova tile i la posa sota la central
	for dir in directions:
		var neighbor = HEX_TILE_SCENE.instantiate() # Crea una nova tile
		neighbor.position = Vector2(0, 40) # Inicia sota la central
		neighbor.set_state(neighbor.State.HIDDEN) # Actualitza l'estat de la tile
		neighbor.q = int(dir.x) # Actualitza la coordenada q de la tile
		neighbor.r = int(dir.y) # Actualitza la coordenada r de la tile
		add_child(neighbor) # Afegeix la tile al Node2D
		var final_pos = axial_to_pixel(dir.x, dir.y) # Converteix les coordenades axials a coordenades cartesianes
		neighbor.animate_to_position(final_pos) # Anima la tile a la posició final
		var key = str(int(dir.x)) + "," + str(int(dir.y)) # Crea una clau per la tile
		tiles[key] = { "node": neighbor, "pos": final_pos, "estat": neighbor.state } # Afegeix la tile al diccionari
		neighbor.connect("estat_canviat", Callable(self, "update_tile_state")) # Connecta el senyal de canvi d'estat a la funció update_tile_state

	$CanvasLayer/Minimap.tiles_ref = tiles
	$CanvasLayer/Minimap.update_minimap()

# Actualitza l'estat de la tile i genera veïns si s'ha descobert
func update_tile_state(q: int, r: int, estat):
	var key = str(q) + "," + str(r) # Crea una clau per la tile
	if tiles.has(key): # Si la tile existeix al diccionari
		tiles[key]["estat"] = estat # Actualitza l'estat de la tile
		print("Tile posició ", q, ",", r, " passa a ", estat, ".") # Mostra un missatge en la consola
		# Si la tile passa a descoberta, genera veïns si no existeixen
		if estat == 1: # 1 = REVEALED
			for dir in directions: # Per cada direcció
				var nq = q + int(dir.x) # Calcula la coordenada q del veí
				var nr = r + int(dir.y) # Calcula la coordenada r del veí
				var nkey = str(nq) + "," + str(nr) # Crea una clau per el veí
				if not tiles.has(nkey): # Si el veí no existeix al diccionari
					var neighbor = HEX_TILE_SCENE.instantiate() # Crea una nova tile
					var parent_pos = axial_to_pixel(q, r) # Converteix les coordenades axials a coordenades cartesianes
					neighbor.position = parent_pos # Inicia exactament a la posició de la tile actual
					neighbor.set_state(neighbor.State.HIDDEN) # Actualitza l'estat de la tile
					neighbor.q = nq # Actualitza la coordenada q del veí
					neighbor.r = nr # Actualitza la coordenada r del veí
					add_child(neighbor) # Afegeix la tile al Node2D
					var final_pos = axial_to_pixel(nq, nr) # Converteix les coordenades axials a coordenades cartesianes
					neighbor.animate_to_position(final_pos) # Anima la tile a la posició final
					tiles[nkey] = { "node": neighbor, "pos": final_pos, "estat": neighbor.state } # Afegeix la tile al diccionari
					neighbor.connect("estat_canviat", Callable(self, "update_tile_state")) # Connecta el senyal de canvi d'estat a la funció update_tile_state

	$CanvasLayer/Minimap.update_minimap()
