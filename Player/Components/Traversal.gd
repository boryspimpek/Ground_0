extends Node

@export_group("Traversal")
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8

@onready var player: CharacterBody3D = get_parent()
@onready var animation_tree: AnimationTree = player.get_node("AnimationTree")

const ANIM_JUMP_SHOT = "parameters/JumpShot/request"

func update(delta: float) -> void:
	# Grawitacja.
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta

	# Skok.
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = jump_velocity

		animation_tree.set(
			ANIM_JUMP_SHOT,
			AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		)
