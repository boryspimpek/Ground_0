extends Node3D

var _target: Vector3
var _speed: float = 60.0

func launch(target_point: Vector3, speed: float) -> void:
	_target = target_point
	_speed = speed
	look_at(_target, Vector3.UP)


func _physics_process(delta: float) -> void:
	var distance_this_frame := _speed * delta
	var remaining := global_position.distance_to(_target)

	if remaining <= distance_this_frame:
		global_position = _target
		queue_free() # tutaj docelowo: efekt trafienia (impact particle)
		return

	global_position += (_target - global_position).normalized() * distance_this_frame
