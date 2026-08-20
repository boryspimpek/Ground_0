extends MeshInstance3D

@export var lifetime: float = 5.0
@export var fade_duration: float = 2.0

func _ready() -> void:
	var mat := get_active_material(0) as StandardMaterial3D
	# Jeśli materiał jest współdzielony między instancjami, zrób unikalną kopię:
	mat = mat.duplicate()
	set_surface_override_material(0, mat)

	await get_tree().create_timer(lifetime).timeout

	var tween := create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, fade_duration)
	tween.tween_callback(queue_free)
