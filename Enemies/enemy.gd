extends CharacterBody3D

@export var speed: float = 4.0
@export var rotation_speed: float = 12.0

@onready var health: Health = $Health
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visuals: Node3D = $Visuals

var target: Node3D = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("enemies")
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	
	# Podpięcie bezpiecznego omijania innych wrogów (Avoidance)
	nav_agent.velocity_computed.connect(_on_velocity_computed)

func _physics_process(delta: float) -> void:
	# Grawitacja
	if not is_on_floor():
		velocity.y -= gravity * delta

	if not is_instance_valid(target):
		nav_agent.set_velocity(Vector3.ZERO)
		return

	# Ustawienie celu nawigacji
	nav_agent.target_position = target.global_position

	# Sprawdzamy czy osiągnęliśmy dystans ataku (Target Desired Distance w Inspektorze)
	if nav_agent.is_target_reached():
		nav_agent.set_velocity(Vector3.ZERO)
		_try_attack()
	else:
		var next_path_pos = nav_agent.get_next_path_position()
		var move_dir = (next_path_pos - global_position).normalized()
		var target_velocity = move_dir * speed
		
		# Wyszyłamy prośbę o bezpieczny ruch (z uwzględnieniem omijania innych wrogów)
		nav_agent.set_velocity(target_velocity)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	move_and_slide()

	# Obrót modelu w stronę ruchu
	var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
	if horizontal_vel.length_squared() > 0.01:
		var target_dir = global_position + horizontal_vel
		var target_basis = visuals.global_transform.looking_at(target_dir, Vector3.UP).basis
		visuals.global_transform.basis = visuals.global_transform.basis.slerp(target_basis, rotation_speed * get_physics_process_delta_time())


func _try_attack() -> void:
	# Obróć wroga bezpośrednio w stronę gracza podczas ataku
	if is_instance_valid(target):
		visuals.look_at(Vector3(target.global_position.x, visuals.global_position.y, target.global_position.z), Vector3.UP)
	

# --- SYGNAŁY Z DETECTION AREA ---
func _on_detection_area_body_entered(body: Node3D) -> void:
	print("Wykryto ciało: ", body.name)
	if body.is_in_group("player"):
		target = body

func _on_detection_area_body_exited(body: Node3D) -> void:
	print("Ciało opuściło obszar: ", body.name)
	if body == target:
		target = null

# --- OBSŁUGA OBRAŻEŃ (TWÓJ ISTNIEJĄCY KOD) ---
func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)

func _on_damaged(amount: float, source: Node) -> void:
	var source_name := str(source.name) if source else "nieznane źródło"
	print(name, " otrzymał ", amount, " obrażeń, HP: ", health.current_health, " from ", source_name)

func _on_died(source: Node) -> void:
	var source_name := str(source.name) if source else "nieznane źródło"
	print(name, " zniszczony przez ", source_name)
	queue_free()
