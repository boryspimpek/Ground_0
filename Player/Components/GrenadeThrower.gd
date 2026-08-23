extends Node
class_name GrenadeThrower

@export var grenade_data: Resource
@export var throw_marker: Marker3D

@onready var player: CharacterBody3D = get_parent()

var _current_count: int
var _cooldown_timer: float = 0.0
const THROW_COOLDOWN := 0.5

func _ready() -> void:
	_current_count = grenade_data.max_count
	EventBus.grenade_count_changed.emit(_current_count, grenade_data.max_count)

func update(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	if Input.is_action_just_pressed("throw") and _cooldown_timer <= 0.0:
		print("Throwing grenade")
		_throw()

func _throw() -> void:
	if _current_count <= 0:
		return
	if not grenade_data.grenade_scene:
		push_warning("Brak grenade_scene w GrenadeData!")
		return

	_current_count -= 1
	_cooldown_timer = THROW_COOLDOWN
	EventBus.grenade_count_changed.emit(_current_count, grenade_data.max_count)

	var grenade: Node = grenade_data.grenade_scene.instantiate()
	player.get_tree().current_scene.add_child(grenade)
	grenade.global_position = throw_marker.global_position

	var forward := player.global_transform.basis.z.normalized()
	var throw_dir: Vector3 = (forward + Vector3.UP * grenade_data.throw_upward_angle).normalized()

	grenade.setup(grenade_data, player)
	grenade.apply_central_impulse(throw_dir * grenade_data.throw_force)

	print("Grenade thrown! Current count: %d" % _current_count)