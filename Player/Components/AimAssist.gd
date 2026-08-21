# AimAssist.gd
extends Node
class_name AimAssist

@export var enabled: bool = true
@export var enemy_group: StringName = &"enemies"
@export var assist_radius: float = 15.0
@export_range(0.0, 90.0, 0.5) var assist_cone_angle: float = 25.0  # połowa kąta stożka, w stopniach
@export_range(0.0, 1.0, 0.01) var pull_strength: float = 0.6      # 0 = brak assista, 1 = pełny snap na cel

@onready var player: CharacterBody3D = get_parent()

func get_assisted_direction(raw_aim_dir: Vector3) -> Vector3:
	if not enabled or raw_aim_dir.length_squared() <= 0.0001:
		return raw_aim_dir

	var target := _find_best_target(raw_aim_dir)
	if target == null:
		return raw_aim_dir

	var to_target := target.global_position - player.global_position
	to_target.y = 0.0
	to_target = to_target.normalized()

	return raw_aim_dir.slerp(to_target, pull_strength)


func _find_best_target(raw_aim_dir: Vector3) -> Node3D:
	var best: Node3D = null
	var best_score := -INF
	var cone_cos := cos(deg_to_rad(assist_cone_angle))

	for enemy in player.get_tree().get_nodes_in_group(enemy_group):
		var enemy_node := enemy as Node3D
		if enemy_node == null:
			continue

		var to_enemy: Vector3 = enemy_node.global_position - player.global_position
		to_enemy.y = 0.0
		var dist := to_enemy.length()
		if dist < 0.001 or dist > assist_radius:
			continue

		var dir := to_enemy / dist
		var dot := raw_aim_dir.dot(dir)
		if dot < cone_cos:
			continue  # poza stożkiem celowania

		# preferuj cele bliżej środka stożka i bliżej gracza
		var score := dot - (dist / assist_radius) * 0.3
		if score > best_score:
			best_score = score
			best = enemy_node

	return best