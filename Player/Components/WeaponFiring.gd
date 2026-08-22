extends Node
class_name WeaponFiring

@onready var player: CharacterBody3D = get_parent()
@onready var aim_origin: Marker3D = player.get_node("AimOrigin")


func fire(weapon_data: Resource) -> Array:
	var forward := player.global_transform.basis.z.normalized()
	var hits: Array = []
	for i in weapon_data.pellets_per_shot:
		var shot_dir := _apply_spread(forward, weapon_data.spread_angle)
		hits.append(_fire_ray(shot_dir, weapon_data))
	return hits


func _apply_spread(direction: Vector3, angle_degrees: float) -> Vector3:
	if angle_degrees <= 0.0:
		return direction
	var random_angle := deg_to_rad(randf_range(-angle_degrees, angle_degrees))
	return direction.rotated(Vector3.UP, random_angle)


func _fire_ray(direction: Vector3, weapon_data: Resource) -> Dictionary:
	var space_state := player.get_world_3d().direct_space_state
	var origin := aim_origin.global_position
	var target: Vector3 = origin + direction * weapon_data.max_range

	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [player.get_rid()]
	var result := space_state.intersect_ray(query)

	if result:
		var distance := origin.distance_to(result.position)
		var dmg := _calculate_damage(distance, weapon_data)
		var collider = result.collider
		if collider.has_method("take_damage"):
			collider.take_damage(dmg)
		return {"hit": true, "position": result.position, "normal": result.normal}

	return {"hit": false, "position": target, "normal": Vector3.ZERO}


func _calculate_damage(distance: float, weapon_data: Resource) -> float:
	if distance <= weapon_data.min_falloff_range:
		return weapon_data.damage
	if distance >= weapon_data.max_range:
		return weapon_data.damage * weapon_data.min_damage_multiplier
	var t: float = (distance - weapon_data.min_falloff_range) / (weapon_data.max_range - weapon_data.min_falloff_range)
	return lerp(weapon_data.damage, weapon_data.damage * weapon_data.min_damage_multiplier, t)