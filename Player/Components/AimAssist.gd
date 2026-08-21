extends Node
class_name AimAssist

@export var enabled: bool = true
@export var enemy_group: StringName = &"enemies"
@export var assist_radius: float = 15.0
@export_range(0.0, 90.0, 0.5) var assist_cone_angle: float = 25.0
@export_range(0.0, 90.0, 0.5) var lose_target_angle: float = 35.0
@export_range(0.0, 1.0, 0.01) var pull_strength: float = 0.75

@onready var player: CharacterBody3D = get_parent()

var _locked_target: Object = null


func get_assisted_direction(raw_aim_dir: Vector3) -> Vector3:
	if not enabled or raw_aim_dir.length_squared() <= 0.0001:
		_locked_target = null
		return raw_aim_dir

	_update_locked_target(raw_aim_dir)

	if _locked_target == null or not is_instance_valid(_locked_target):
		_locked_target = null
		return raw_aim_dir

	var target_node := _locked_target as Node3D

	if target_node == null:
		_locked_target = null
		return raw_aim_dir

	var to_target := target_node.global_position - player.global_position
	to_target.y = 0.0

	if to_target.length_squared() <= 0.0001:
		_locked_target = null
		return raw_aim_dir

	to_target = to_target.normalized()

	return raw_aim_dir.slerp(
		to_target,
		clamp(pull_strength, 0.0, 1.0)
	)
	

func _update_locked_target(raw_aim_dir: Vector3) -> void:
	# Jeśli poprzedni cel został usunięty, wyczyść referencję.
	if _locked_target != null and not is_instance_valid(_locked_target):
		_locked_target = null

	# Jeżeli mamy istniejący obiekt, dopiero teraz sprawdzamy jego typ.
	if _locked_target != null:
		var target_node := _locked_target as Node3D

		if target_node != null:
			if _is_valid_target(target_node, raw_aim_dir, lose_target_angle):
				return
		else:
			_locked_target = null

	# Nie mamy celu albo poprzedni cel został zgubiony.
	_locked_target = _find_best_target(raw_aim_dir, assist_cone_angle)
	

func _is_valid_target(
	target: Node3D,
	raw_aim_dir: Vector3,
	max_angle_deg: float
) -> bool:
	if target == null or not is_instance_valid(target):
		return false

	var to_target: Vector3 = target.global_position - player.global_position
	to_target.y = 0.0

	var dist := to_target.length()

	if dist < 0.001 or dist > assist_radius:
		return false

	var angle := raw_aim_dir.angle_to(to_target.normalized())

	return angle <= deg_to_rad(max_angle_deg)
	

func _find_best_target(
	raw_aim_dir: Vector3,
	cone_angle_deg: float
) -> Node3D:
	var best: Node3D = null
	var best_score: float = -INF
	var cone_cos: float = cos(deg_to_rad(cone_angle_deg))

	for enemy in player.get_tree().get_nodes_in_group(enemy_group):
		var enemy_node := enemy as Node3D

		if enemy_node == null:
			continue

		if not is_instance_valid(enemy_node):
			continue

		var to_enemy: Vector3 = (
			enemy_node.global_position - player.global_position
		)

		to_enemy.y = 0.0

		var dist := to_enemy.length()

		if dist < 0.001 or dist > assist_radius:
			continue

		var dir := to_enemy / dist
		var dot := raw_aim_dir.dot(dir)

		if dot < cone_cos:
			continue

		var score := dot - (dist / assist_radius) * 0.3

		if score > best_score:
			best_score = score
			best = enemy_node

	return best
