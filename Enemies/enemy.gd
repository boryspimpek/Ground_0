extends CharacterBody3D

@export var speed: float = 4.0
@export var rotation_speed: float = 12.0
@export var flying: bool = false

@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.5  # sekundy między atakami


@onready var health: Health = $Health
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var visuals: Node3D = self
@onready var electric: Node3D = get_node_or_null("ElectricAttack")

var pre_attack_distance: float = 1.0
var pre_attack_done := false
var attack_timer: float = 0.0

var target: Node3D = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("enemies")
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
		detection_area.body_entered.connect(_on_detection_area_body_entered)
	if not detection_area.body_exited.is_connected(_on_detection_area_body_exited):
		detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	# Podpięcie bezpiecznego omijania innych wrogów (Avoidance)
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	if electric:
		electric.visible = false  # Ukryj efekt elektryczny na początku

func _physics_process(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta

	# Latajacy wrog utrzymuje wysokosc zamiast podlegac grawitacji.
	if not flying and not is_on_floor():
		velocity.y -= gravity * delta

	if not is_instance_valid(target):
		nav_agent.set_velocity(Vector3.ZERO)
		_set_electric_visible(false)
		return

	var distance_to_target := global_position.distance_to(target.global_position)
	if flying:
		var horizontal_offset := target.global_position - global_position
		horizontal_offset.y = 0.0
		distance_to_target = horizontal_offset.length()

	var pre_attack_trigger_distance := nav_agent.target_desired_distance + pre_attack_distance

	if distance_to_target <= pre_attack_trigger_distance and not pre_attack_done:
		pre_attack_done = true
		_prepare_attack()

	if distance_to_target <= nav_agent.target_desired_distance:
		velocity = Vector3.ZERO
		nav_agent.set_velocity(Vector3.ZERO)
		_try_attack()
		return

	if distance_to_target > pre_attack_trigger_distance:
		pre_attack_done = false
		_set_electric_visible(false)

	if flying:
		var flying_direction := target.global_position - global_position
		flying_direction.y = 0.0

		if flying_direction.length_squared() > 0.01:
			velocity = flying_direction.normalized() * speed
			move_and_slide()
			_rotate_towards_velocity()

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

func _set_electric_visible(effect_visible: bool) -> void:
	if electric:
		electric.visible = effect_visible

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	move_and_slide()
	_rotate_towards_velocity()

func _rotate_towards_velocity() -> void:
	# Obrót modelu w stronę ruchu
	var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
	if horizontal_vel.length_squared() > 0.01:
		var target_dir = global_position + horizontal_vel
		var target_basis = visuals.global_transform.looking_at(target_dir, Vector3.UP).basis
		visuals.global_transform.basis = visuals.global_transform.basis.slerp(target_basis, rotation_speed * get_physics_process_delta_time())

func _prepare_attack() -> void:
	# Włącz efekt elektryczny przed atakiem
	_set_electric_visible(true)
	print("Przygotowanie ataku")

func _try_attack() -> void:
	if not is_instance_valid(target):
		return

	# Obróć wroga bezpośrednio w stronę gracza podczas ataku
	visuals.look_at(Vector3(target.global_position.x, visuals.global_position.y, target.global_position.z), Vector3.UP)

	if attack_timer > 0.0:
		return  # jeszcze cooldown, nie zadajemy obrażeń

	attack_timer = attack_cooldown
	print("Atakowanie celu: ", target.name, " | ma take_damage? ", target.has_method("take_damage"))

	if target.has_method("take_damage"):
		target.take_damage(attack_damage, self)

# --- SYGNAŁY Z DETECTION AREA ---
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Wykryto: ", body.name, " | typ: ", body.get_class(), " | ścieżka: ", body.get_path())
		target = body

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == target:
		print("Ciało opuściło obszar: ", body.name)
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


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Gracz wszedł w ElectricAttack/Area3D: ", body.name)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Gracz wyszedł z ElectricAttack/Area3D: ", body.name)
