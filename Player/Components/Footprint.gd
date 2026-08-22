extends Node

@export var footprint_scene: PackedScene
@export var left_foot_marker: Marker3D
@export var right_foot_marker: Marker3D
@export var ground_collision_mask: int = 1   # ustaw maskę pod warstwę terenu
@export var timer: float = 3.0  # czas życia śladu

@onready var raycast_up_offset: float = 0.3   # o ile podnieść origin nad marker
@onready var raycast_distance: float = 0.6    # jak daleko w dół szukać ziemi
@onready var surface_offset: float = 0.01  # jak bardzo unieść ślad nad ziemię

func left_footstep() -> void:
	spawn_footprint(left_foot_marker)

func right_footstep() -> void:
	spawn_footprint(right_foot_marker)

func spawn_footprint(marker: Marker3D) -> void:
	var space_state := get_tree().root.world_3d.direct_space_state
	var origin := marker.global_position + Vector3.UP * raycast_up_offset
	var target := origin + Vector3.DOWN * (raycast_up_offset + raycast_distance)

	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.collision_mask = ground_collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := space_state.intersect_ray(query)

	if result.is_empty():
		return

	var footprint := footprint_scene.instantiate()
	get_tree().current_scene.add_child(footprint)

	var original_scale: Vector3 = footprint.scale

	var up_dir: Vector3 = result.normal
	var forward_dir: Vector3 = -marker.global_transform.basis.z

	var basis := Basis()
	basis.y = up_dir
	basis.x = forward_dir.slide(up_dir).normalized()
	basis.z = basis.x.cross(basis.y).normalized()

	var spawn_position: Vector3 = result.position + up_dir * surface_offset

	footprint.global_transform = Transform3D(basis, spawn_position)
	footprint.scale = original_scale

	get_tree().create_timer(timer).timeout.connect(footprint.queue_free)