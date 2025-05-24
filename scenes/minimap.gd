extends Control

# Referència al diccionari de tiles del main
var tiles_ref = null

# Mida del minimapa
const MAP_SIZE = Vector2(200, 200)
const TILE_SIZE = 8

func _ready():
	size = MAP_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw():
	if tiles_ref == null:
		return
	# Dibuixa cada tile
	for key in tiles_ref:
		var info = tiles_ref[key]
		var pos = info["pos"] / 8 + MAP_SIZE / 2  # Escala i centra el mapa
		var color = Color(0.2, 0.2, 0.2, 1) if info["estat"] == 0 else Color(0.6, 1, 0.6, 1)
		draw_circle(pos, TILE_SIZE / 2.0, color)

func update_minimap():
	queue_redraw()
