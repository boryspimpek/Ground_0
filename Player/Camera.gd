extends Camera3D

@export_group("Target Follow")
## Węzeł gracza lub innego celu do śledzenia. Jeśli pusty, spróbuje znaleźć w grupie "player".
@export var target: Node3D
## Szybkość płynnego podążania kamery za graczem
@export var follow_speed: float = 10.0

# Wektor offsetu wyliczany automatycznie na podstawie pozycji ustawionej w edytorze
var _calculated_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Jeśli target nie został przypisany w Inspectorze, szukamy pierwszego węzła w grupie "player"
	if not target:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0]
	
	# Obliczamy offset na podstawie pozycji kamery ustawionej w edytorze
	if target:
		_calculated_offset = global_position - target.global_position

func _physics_process(delta: float) -> void:
	if not target:
		return

	# Docelowa pozycja kamery z uwzględnieniem zapamiętanego dystansu
	var target_position = target.global_position + _calculated_offset
	
	# Płynne podążanie
	global_position = global_position.lerp(target_position, follow_speed * delta)

# Funkcja pomocnicza do wyliczania punktu celowania pod myszką
func get_ground_position_under_mouse(custom_y_level: float = 0.0) -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = project_ray_origin(mouse_pos)
	var ray_dir = project_ray_normal(mouse_pos)

	var plane = Plane(Vector3.UP, custom_y_level)
	var intersection = plane.intersects_ray(ray_origin, ray_dir)

	if intersection:
		return intersection
	return Vector3.ZERO