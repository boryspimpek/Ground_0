extends RigidBody3D
class_name Grenade

@onready var audio_player: AudioStreamPlayer3D = $"AudioPlayer"


var _data: Resource
var _source: Node
var _fuse_timer: float

func setup(data: Resource, source: Node) -> void:
	_data = data
	_source = source
	_fuse_timer = data.fuse_time

func _physics_process(delta: float) -> void:
	_fuse_timer -= delta
	if _fuse_timer <= 0.0:
		_explode()

func _explode() -> void:
	var space_state := get_world_3d().direct_space_state
	var shape := SphereShape3D.new()
	shape.radius = _data.explosion_radius

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), global_position)
	query.collide_with_bodies = true
	query.exclude = [self]

	var results := space_state.intersect_shape(query)
	var already_hit: Array[Node] = []

	for hit in results:
		var body: Node = hit.collider
		if body in already_hit:
			continue
		already_hit.append(body)

		if body.has_method("take_damage"):
			var distance := global_position.distance_to(body.global_position)
			var dmg := _calculate_damage(distance)
			body.take_damage(dmg, _source)

	_spawn_explosion_effect()
	if _data.explosion_sound:
		audio_player.stream = _data.explosion_sound
		audio_player.reparent(get_tree().current_scene, true)
		audio_player.play()
	get_tree().create_timer(audio_player.stream.get_length()).timeout.connect(audio_player.queue_free)
	queue_free()

func _calculate_damage(distance: float) -> float:
	var t: float = clamp(distance / _data.explosion_radius, 0.0, 1.0)
	var damage: float = lerp(_data.damage, _data.damage * _data.min_damage_multiplier, t)
	print("Calculated damage: ", damage, " at distance: ", distance)
	return damage

func _spawn_explosion_effect() -> void:
	if not _data.explosion_effect_scene:
		return
	var effect: Node3D = _data.explosion_effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	get_tree().create_timer(2.0).timeout.connect(effect.queue_free)
