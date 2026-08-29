extends Node3D

# Podepnij swoje węzły w Inspectorze lub użyj ścieżek
@export_group("Light Nodes")
@export var spot_light_left: SpotLight3D
@export var spot_light_right: SpotLight3D

@export_group("Mesh Nodes")
@export var mesh_left: MeshInstance3D
@export var mesh_right: MeshInstance3D

@export_group("Flicker Settings")
@export var base_energy: float = 3.0       # Standardowa moc reflektora
@export var flicker_speed: float = 0.05    # Częstotliwość losowania (w sekundach)

var _timer: float = 0.0

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= flicker_speed:
		_timer = 0.0
		_update_flicker()

func _update_flicker() -> void:
	# Reflektor lewy (np. mocniej uszkodzony - częściej gaśnie)
	var energy_left = _get_flicker_energy(0.35)
	_apply_light_state(spot_light_left, mesh_left, energy_left)

	# Reflektor prawy (np. lekko przygasający)
	var energy_right = _get_flicker_energy(0.85)
	_apply_light_state(spot_light_right, mesh_right, energy_right)

func _get_flicker_energy(health_factor: float) -> float:
	# Losujemy czy w danej klatce światło zgasło/spięło
	var roll = randf()
	
	if roll > health_factor:
		# Całkowite zgaszenie lub małe "spięcie" (bardzo niska energia)
		return randf_range(0.0, 0.2)
	elif roll < 0.1:
		# Błysk o wyższej mocy niż standardowa (przebicie prądu)
		return base_energy * randf_range(1.3, 1.8)
	else:
		# Normalna praca z delikatnym drganiem napięcia
		return base_energy * randf_range(0.7, 1.0)

func _apply_light_state(light: SpotLight3D, mesh: MeshInstance3D, energy: float) -> void:
	if light:
		light.light_energy = energy
	
	if mesh:
		# Dopasowujemy jasność emisji materiału kuli do mocy światła
		var mat = mesh.get_active_material(0) as StandardMaterial3D
		if mat:
			mat.emission_energy_multiplier = energy * 0.8