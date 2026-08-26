extends Area3D
class_name HitboxComponent

@export var damage: float = 10.0
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	# Domyślnie wyłączony – włączamy go tylko na ułamek sekundy z animacji
	disable_hitbox()
	body_entered.connect(_on_body_entered)

func enable_hitbox() -> void:
	collision_shape.disabled = false

func disable_hitbox() -> void:
	collision_shape.set_deferred("disabled", true)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, owner) # owner przekazuje wroga jako źródło
