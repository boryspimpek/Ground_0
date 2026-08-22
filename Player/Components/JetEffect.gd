extends Node
class_name JetEffect

@export var left_jet: MeshInstance3D
@export var right_jet: MeshInstance3D

@onready var traversal: Node = get_parent().get_node("Traversal")

func _ready() -> void:
	traversal.airborne_changed.connect(_on_airborne_changed)
	_set_visible(false)

func _on_airborne_changed(is_airborne: bool) -> void:
	_set_visible(is_airborne)

func _set_visible(value: bool) -> void:
	left_jet.visible = value
	right_jet.visible = value
