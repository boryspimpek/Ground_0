extends CharacterBody3D

@onready var movement: Node = $Movement
@onready var traversal: Node = $Traversal
@onready var combat: Node = $Combat
@onready var grenade_thrower: Node = $GrenadeThrower
@onready var animation_tree: AnimationTree = $AnimationTree

func _ready() -> void:
	if not animation_tree:
		push_error("Brak węzła AnimationTree o nazwie 'AnimationTree' jako dziecko Gracza!")
		return
	
	animation_tree.active = true

func _physics_process(delta: float) -> void:

	traversal.update(delta)

	movement.update(delta)

	combat.update(delta)
	grenade_thrower.update(delta)

	move_and_slide()
