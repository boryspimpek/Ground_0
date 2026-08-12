extends Node

@onready var animation_tree: AnimationTree = get_parent().get_node("AnimationTree")

const ANIM_SHOOT_SHOT = "parameters/FiringShot/request"

func update() -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot()


func shoot() -> void:
	animation_tree.set(
		ANIM_SHOOT_SHOT,
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	)