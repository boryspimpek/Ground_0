extends StaticBody3D

@onready var health: Health = $Health

func _ready() -> void:
	add_to_group("enemies")
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)


func _on_damaged(amount: float, source: Node) -> void:
	print(name, " otrzymał ", amount, " obrażeń, HP: ", health.current_health, " from ", source.name if source else "nieznane źródło")


func _on_died(_source: Node) -> void:
	print(name, " zniszczony przez ", _source.name if _source else "nieznane źródło")
	queue_free()