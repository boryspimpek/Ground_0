extends CharacterBody3D

@export var push_force: float = 1.5 # Mnożnik siły popychania

@onready var movement: Node = $Movement
@onready var traversal: Node = $Traversal
@onready var combat: Node = $Combat
@onready var grenade_thrower: Node = $GrenadeThrower
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var health: Health = $Health

func _ready() -> void:
	animation_tree.active = true

func _physics_process(delta: float) -> void:

	traversal.update(delta)

	movement.update(delta)

	combat.update(delta)
	grenade_thrower.update(delta)

	move_and_slide()
	_handle_push_collisions()

func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)

func _handle_push_collisions() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody3D:
			# Kierunek pchnięcia (od odwrotności wektora normalnego kolizji)
			var push_dir: Vector3 = -collision.get_normal()
			
			# Ignorujemy siłę w pionie (żeby gracz nie popychał ziemi w dół ani nie podbijał obiektów skacząc na nie)
			push_dir.y = 0.0
			push_dir = push_dir.normalized()

			# Miejsce przyłożenia siły (offset od środka masy beczki)
			var hit_offset: Vector3 = collision.get_position() - collider.global_position

			# Przykładamy impuls do RigidBody3D
			collider.apply_impulse(push_dir * push_force, hit_offset)