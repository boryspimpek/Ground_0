extends Node
class_name Health

signal health_changed(current: float, max: float)
signal damaged(amount: float, source: Node)
signal died(source: Node)

@export var max_health: float = 100.0

var current_health: float

var is_dead: bool:
	get:
		return current_health <= 0.0


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func take_damage(amount: float, source: Node = null) -> void:
	if is_dead:
		return
	if amount <= 0.0:
		return

	current_health = max(current_health - amount, 0.0)
	damaged.emit(amount, source)
	health_changed.emit(current_health, max_health)

	if is_dead:
		died.emit(source)


func heal(amount: float) -> void:
	if is_dead:
		return
	if amount <= 0.0:
		return

	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)