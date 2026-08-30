extends Node3D

@export var is_broken: bool = false       # Zaznacz "true" tylko na 3 wybranych latarniach!

@export_group("Nodes")
@export var light_node: Light3D
@export var mesh_node: MeshInstance3D
@export var surface_index: int = 0

@export_group("Flicker Settings")
@export var base_energy: float = 4.0
@export var flicker_speed: float = 0.04
@export var broken_severity: float = 0.4

var _timer: float = 0.0
var _target_material: StandardMaterial3D

func _ready() -> void:
	if mesh_node:
		var mat = mesh_node.get_active_material(surface_index)
		if mat is StandardMaterial3D:
			_target_material = mat
	
	# Jeśli latarnia NIE jest zepsuta, ustawiamy jej stałe światło i wyłączamy _process
	if not is_broken:
		if light_node:
			light_node.light_energy = base_energy
		if _target_material:
			_target_material.emission_energy_multiplier = base_energy * 0.75
		set_process(false) # Wyłącza pętlę _process(), oszczędzając procesor!

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= flicker_speed:
		_timer = 0.0
		_update_flicker()
		
func _update_flicker() -> void:
	var energy = _calculate_energy()
	
	# 1. Zmiana energii światła rzucanego na otoczenie
	if light_node:
		light_node.light_energy = energy
	
	# 2. Zmiana jasności tekstury emisji na żarówce
	if _target_material:
		_target_material.emission_energy_multiplier = energy * 0.75

func _calculate_energy() -> float:
	var roll = randf()
	
	if roll < broken_severity:
		# Stan zgaszony / iskra (ciemność lub bardzo niskie napięcie)
		return randf_range(0.0, 0.15)
	elif roll > 0.92:
		# Przebicie prądu - mocny, krótki rozbłysk ponad normę
		return base_energy * randf_range(1.4, 2.0)
	else:
		# Normalne świecenie z delikatnym drganiem prądu
		return base_energy * randf_range(0.7, 1.0)