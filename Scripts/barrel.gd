extends RigidBody3D

@onready var health: Health = $Health

# Opcjonalnie: sceny z efektami niszczenia
@export var explosion_effect: PackedScene  # Np. cząsteczki eksplozji / ognia
@export var debris_scene: PackedScene      # Np. połamane deski / kawałki metalu

func _ready() -> void:
	# Podpinamy się pod sygnał z komponentu Health
	health.died.connect(_on_died)

# Funkcja przekazująca obrażenia (taki sam interfejs jak u gracza/wroga)
func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)

func _on_died(_source: Node) -> void:
	_destroy_barrel()

func _destroy_barrel() -> void:
	# 1. Spawn efektu cząsteczkowego/eksplozji w miejscu beczki
	if explosion_effect:
		var effect_instance = explosion_effect.instantiate() as Node3D
		get_parent().add_child(effect_instance)
		effect_instance.global_transform = global_transform

	# 2. Spawn gruzu/kawałków (jeśli masz przygotowane)
	if debris_scene:
		var debris_instance = debris_scene.instantiate() as Node3D
		get_parent().add_child(debris_instance)
		debris_instance.global_transform = global_transform

	# 3. Usunięcie beczki ze sceny
	queue_free()
