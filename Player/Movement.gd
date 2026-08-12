extends Node

@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var aim_threshold: float = 0.2
## Szybkość wygładzania przejścia animacji biegu/stania (im wyższa, tym szybsza reakcja)
@export var blend_smooth_speed: float = 8.0 

@onready var player: CharacterBody3D = get_parent()
@onready var animation_tree: AnimationTree = player.get_node("AnimationTree")

const ANIM_IS_AIMING = "parameters/IsAiming/transition_request"
const ANIM_WALK_BLEND = "parameters/NormalWalk/blend_position"
const ANIM_STRAFE_BLEND = "parameters/Strafe/blend_position"

var _is_aiming := false

func update(delta: float) -> void:
	var move_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir := Vector3(move_input.x, 0, move_input.y).normalized()

	var aim_input := Input.get_vector("aim_left", "aim_right", "aim_forward", "aim_back")

	_is_aiming = aim_input.length() > aim_threshold
	animation_tree.set(ANIM_IS_AIMING, "strafe" if _is_aiming else "normal")

	if _is_aiming:
		var aim_dir := Vector3(aim_input.x, 0, aim_input.y).normalized()

		if aim_dir:
			var target_rotation = atan2(aim_dir.x, aim_dir.z)
			player.rotation.y = lerp_angle(player.rotation.y, target_rotation, 20.0 * delta)

		var local_move = player.transform.basis.inverse() * move_dir
		var target_strafe = Vector2(local_move.x, local_move.z)
		
		# Płynny strafe (przydatny przy puszczeniu analoga)
		var current_strafe: Vector2 = animation_tree.get(ANIM_STRAFE_BLEND)
		var smoothed_strafe = current_strafe.move_toward(target_strafe, blend_smooth_speed * delta)
		animation_tree.set(ANIM_STRAFE_BLEND, smoothed_strafe)

		if move_dir:
			player.velocity.x = move_dir.x * walk_speed
			player.velocity.z = move_dir.z * walk_speed
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, walk_speed)
			player.velocity.z = move_toward(player.velocity.z, 0, walk_speed)

	else:
		if move_dir:
			var target_rotation = atan2(move_dir.x, move_dir.z)
			player.rotation.y = lerp_angle(player.rotation.y, target_rotation, 15.0 * delta)

			player.velocity.x = move_dir.x * run_speed
			player.velocity.z = move_dir.z * run_speed
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, run_speed)
			player.velocity.z = move_toward(player.velocity.z, 0, run_speed)

		# POPRAWKA: Płynne wygładzanie Blend1D (NormalWalk)
		# Wartość docelowa zależy od tego czy gracz się porusza (1.0 = Bieg, 0.0 = Stanie)
		var target_blend := 1.0 if move_dir else 0.0
		var current_blend: float = animation_tree.get(ANIM_WALK_BLEND)
		
		var smoothed_blend = move_toward(current_blend, target_blend, blend_smooth_speed * delta)
		animation_tree.set(ANIM_WALK_BLEND, smoothed_blend)