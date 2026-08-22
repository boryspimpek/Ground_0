extends StaticBody3D

@onready var health: Health = $Health

func _ready() -> void:
	add_to_group("enemies")
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)


func _on_damaged(amount: float, source: Node) -> void:
	var source_name := str(source.name) if source else "nieznane źródło"
	print(name, " otrzymał ", amount, " obrażeń, HP: ",
		health.current_health, " from ", source_name)


func _on_died(source: Node) -> void:
	var source_name := str(source.name) if source else "nieznane źródło"
	print(name, " zniszczony przez ", source_name)
	queue_free()