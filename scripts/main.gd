extends Node2D

# Carrega lesscenes
const HEX_TILE_SCENE = preload("res://scenes/hexTile.tscn")
const MapManagerResource = preload("res://scripts/map_manager.gd")

# Referència al MapManager
var map_manager: MapManagerResource

# Inicialitza el joc
func _ready():
	position = get_viewport_rect().size / 2 # Centra el Node2D al centre de la pantalla

	# Inicialitza el MapManager
	map_manager = MapManagerResource.new() # Crea una nova instància del MapManager
	add_child(map_manager) # Afegeix el MapManager al Node2D
	map_manager.initialize_map(HEX_TILE_SCENE) # Inicialitza el MapManager
	map_manager.position = Vector2.ZERO # Centra el MapManager al centre de la pantalla
