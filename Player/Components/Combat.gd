extends Node

@onready var player: CharacterBody3D = get_parent()
@onready var movement: Node = player.get_node("Movement")
@onready var animation_tree: AnimationTree = player.get_node("AnimationTree")

@onready var inventory: WeaponInventory = $"../WeaponInventory"
@onready var ammo: AmmoController = $"../AmmoController"
@onready var firing: WeaponFiring = $"../WeaponFiring"
@onready var fx: WeaponFX = $"../WeaponFX"

const ANIM_SHOOT_SHOT = "parameters/FiringShot/request"

var _cooldown_timer: float = 0.0


func update(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	ammo.update(delta)

	if Input.is_action_just_pressed("weapon_next"):
		inventory.switch_weapon()
		_cooldown_timer = 0.0

	if Input.is_action_just_pressed("reload"):
		_reload()

	var weapon_data: Resource = inventory.weapon_data
	var trigger_pulled := false
	if movement.is_aiming() and weapon_data and weapon_data.is_automatic:
		trigger_pulled = Input.is_action_pressed("shoot")
	elif movement.is_aiming() and weapon_data:
		trigger_pulled = Input.is_action_just_pressed("shoot")

	if trigger_pulled and _cooldown_timer <= 0.0:
		shoot()


func shoot() -> void:
	if not movement.is_aiming():
		return

	var weapon_data: Resource = inventory.weapon_data
	if not weapon_data:
		push_warning("Brak przypisanego WeaponData w Combat!")
		return

	if not ammo.can_shoot():
		if not ammo.is_reloading:
			print("Pusty magazynek!")
			_reload()
		return

	ammo.consume_round()
	_cooldown_timer = weapon_data.cooldown

	# animation_tree.set(ANIM_SHOOT_SHOT, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	fx.spawn_muzzle_flash(weapon_data)
	fx.play_sound(weapon_data.fire_sound)

	var hits: Array = firing.fire(weapon_data)
	for hit in hits:
		if hit.hit:
			fx.spawn_impact_effect(weapon_data, hit.position, hit.normal)
		fx.spawn_projectile_trail(weapon_data, fx.muzzle.global_position, hit.position)


func _reload() -> void:
	var was_reloading := ammo.is_reloading
	ammo.start_reload()
	if not was_reloading and ammo.is_reloading:
		fx.play_sound(inventory.weapon_data.reload_sound)
