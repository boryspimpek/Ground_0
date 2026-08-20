extends Node

@export var weapon_list: Array[Resource] = []
@export var muzzle: Marker3D

@onready var player: CharacterBody3D = get_parent()
@onready var animation_tree: AnimationTree = player.get_node("AnimationTree")
@onready var aim_origin: Marker3D = player.get_node("AimOrigin")
@onready var audio_player: AudioStreamPlayer3D = $"../AudioPlayer"

const ANIM_SHOOT_SHOT = "parameters/FiringShot/request"

var _cooldown_timer: float = 0.0
var _current_weapon_index: int = 0

var _ammo_in_magazine: Array[int] = []
var _is_reloading: bool = false
var _reload_timer: float = 0.0

var weapon_data: Resource:
	get:
		if weapon_list.is_empty():
			return null
		return weapon_list[_current_weapon_index]

var current_ammo: int:
	get:
		if _ammo_in_magazine.is_empty():
			return 0
		return _ammo_in_magazine[_current_weapon_index]
	set(value):
		if _ammo_in_magazine.is_empty():
			return
		_ammo_in_magazine[_current_weapon_index] = value


func _ready() -> void:
	_ammo_in_magazine.resize(weapon_list.size())
	for i in weapon_list.size():
		var w: Resource = weapon_list[i]
		_ammo_in_magazine[i] = w.magazine_size if w else 0

	if weapon_data:
		EventBus.weapon_changed.emit(weapon_data)
		EventBus.ammo_changed.emit(current_ammo, weapon_data.magazine_size)


func update(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	if _is_reloading:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_finish_reload()

	if Input.is_action_just_pressed("weapon_next"):
		_switch_weapon()

	if Input.is_action_just_pressed("reload"):
		_start_reload()

	var trigger_pulled := false
	if weapon_data and weapon_data.is_automatic:
		trigger_pulled = Input.is_action_pressed("shoot")
	else:
		trigger_pulled = Input.is_action_just_pressed("shoot")

	if trigger_pulled and _cooldown_timer <= 0.0:
		shoot()


func shoot() -> void:
	if not weapon_data:
		push_warning("Brak przypisanego WeaponData w Combat!")
		return

	if _is_reloading:
		return

	if current_ammo <= 0:
		print("Pusty magazynek!")
		_start_reload()
		return

	current_ammo -= 1
	EventBus.ammo_changed.emit(current_ammo, weapon_data.magazine_size)

	_cooldown_timer = weapon_data.cooldown

	animation_tree.set(ANIM_SHOOT_SHOT, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	_spawn_muzzle_flash()
	_play_sound(weapon_data.fire_sound)

	var forward := player.transform.basis.z

	for i in weapon_data.pellets_per_shot:
		var shot_dir := _apply_spread(forward, weapon_data.spread_angle)
		_fire_ray(shot_dir)


func _start_reload() -> void:
	if not weapon_data:
		return
	if _is_reloading:
		return
	if current_ammo >= weapon_data.magazine_size:
		return

	_is_reloading = true
	_reload_timer = weapon_data.reload_time
	_play_sound(weapon_data.reload_sound)
	EventBus.reload_started.emit(weapon_data.reload_time)


func _play_sound(stream: AudioStream) -> void:
	if not stream:
		return
	audio_player.global_position = muzzle.global_position
	audio_player.stream = stream
	audio_player.play()


func _finish_reload() -> void:
	_is_reloading = false
	current_ammo = weapon_data.magazine_size
	EventBus.ammo_changed.emit(current_ammo, weapon_data.magazine_size)
	EventBus.reload_finished.emit()
	

func _switch_weapon() -> void:
	if weapon_list.is_empty():
		return

	_is_reloading = false
	_current_weapon_index = wrapi(_current_weapon_index + 1, 0, weapon_list.size())
	_cooldown_timer = 0.0

	EventBus.weapon_changed.emit(weapon_data)
	EventBus.ammo_changed.emit(current_ammo, weapon_data.magazine_size)
	
func _spawn_muzzle_flash() -> void:
	if not weapon_data.muzzle_flash_scene:
		return

	var flash: Node = weapon_data.muzzle_flash_scene.instantiate()
	muzzle.add_child(flash)

func _apply_spread(direction: Vector3, angle_degrees: float) -> Vector3:
	if angle_degrees <= 0.0:
		return direction
	var random_angle := deg_to_rad(randf_range(-angle_degrees, angle_degrees))
	return direction.rotated(Vector3.UP, random_angle)


func _fire_ray(direction: Vector3) -> void:
	var space_state := player.get_world_3d().direct_space_state
	var origin := aim_origin.global_position
	var target: Vector3 = origin + direction * weapon_data.max_range

	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [player.get_rid()]
	# TODO: ustaw collision_mask na warstwy "Enemies" + "Environment"

	var result := space_state.intersect_ray(query)

	var hit_point: Vector3
	if result:
		hit_point = result.position
		var distance := origin.distance_to(hit_point)
		var dmg := _calculate_damage(distance)

		var collider = result.collider
		if collider.has_method("take_damage"):
			collider.take_damage(dmg)
	else:
		hit_point = target

	_spawn_projectile_trail(hit_point)


func _calculate_damage(distance: float) -> float:
	if distance <= weapon_data.min_falloff_range:
		return weapon_data.damage

	if distance >= weapon_data.max_range:
		return weapon_data.damage * weapon_data.min_damage_multiplier

	var t: float = (distance - weapon_data.min_falloff_range) / (weapon_data.max_range - weapon_data.min_falloff_range)
	return lerp(weapon_data.damage, weapon_data.damage * weapon_data.min_damage_multiplier, t)


func _spawn_projectile_trail(target_point: Vector3) -> void:
	if not weapon_data.projectile_scene:
		return

	var projectile: Node = weapon_data.projectile_scene.instantiate()
	player.get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle.global_position

	if projectile.has_method("launch"):
		projectile.launch(target_point, weapon_data.projectile_speed)
