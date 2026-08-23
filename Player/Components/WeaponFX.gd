extends Node
class_name WeaponFX

@export var muzzle: Marker3D

@onready var player: CharacterBody3D = get_parent()
@onready var audio_player: AudioStreamPlayer3D = $"../AudioPlayer"


func play_sound(stream: AudioStream) -> void:
	if not stream:
		return
	audio_player.global_position = player.global_position
	audio_player.stream = stream
	audio_player.play()


func spawn_muzzle_flash(weapon_data: Resource) -> void:
	if not weapon_data.muzzle_flash_scene:
		return
	var flash: Node = weapon_data.muzzle_flash_scene.instantiate()
	muzzle.add_child(flash)
	get_tree().create_timer(1.0).timeout.connect(flash.queue_free)


func spawn_impact_effect(weapon_data: Resource, position: Vector3, normal: Vector3) -> void:
	if not weapon_data.impact_effect_scene:
		push_warning("Brak impact_effect_scene w WeaponData!")
		return

	var effect: Node3D = weapon_data.impact_effect_scene.instantiate()
	player.get_tree().current_scene.add_child(effect)
	effect.global_position = position

	if normal != Vector3.ZERO:
		var up_hint := Vector3.RIGHT if abs(normal.dot(Vector3.UP)) > 0.99 else Vector3.UP
		effect.global_transform.basis = Basis.looking_at(normal, up_hint)

	effect.emitting = true
	get_tree().create_timer(1.0).timeout.connect(effect.queue_free)
	

func spawn_projectile_trail(weapon_data: Resource, muzzle_position: Vector3, target_point: Vector3) -> void:
	if not weapon_data.projectile_scene:
		return
	var projectile: Node = weapon_data.projectile_scene.instantiate()
	player.get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle_position
	if projectile.has_method("launch"):
		projectile.launch(target_point, weapon_data.projectile_speed)