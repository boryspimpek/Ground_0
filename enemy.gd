extends StaticBody3D

@export var max_health: float = 100.0
var health: float

func _ready() -> void:
	health = max_health

func take_damage(amount: float) -> void:
	health -= amount
	print(name, " otrzymał ", amount, " obrażeń, HP: ", health)

	if health <= 0.0:
		print(name, " zniszczony")
		queue_free()
