extends Node
class_name AmmoController

@onready var inventory: WeaponInventory = $"../WeaponInventory"

var _ammo_in_magazine: Array[int] = []
var _is_reloading: bool = false
var _reload_timer: float = 0.0

var is_reloading: bool:
	get:
		return _is_reloading

var current_ammo: int:
	get:
		if _ammo_in_magazine.is_empty():
			return 0
		return _ammo_in_magazine[inventory.current_index]
	set(value):
		if _ammo_in_magazine.is_empty():
			return
		_ammo_in_magazine[inventory.current_index] = value


func _ready() -> void:
	_ammo_in_magazine.resize(inventory.weapon_list.size())
	for i in inventory.weapon_list.size():
		var w: Resource = inventory.weapon_list[i]
		_ammo_in_magazine[i] = w.magazine_size if w else 0

	if inventory.weapon_data:
		EventBus.ammo_changed.emit(current_ammo, inventory.weapon_data.magazine_size)

	EventBus.weapon_changed.connect(_on_weapon_changed)


func _on_weapon_changed(_weapon: Resource) -> void:
	_is_reloading = false
	EventBus.ammo_changed.emit(current_ammo, inventory.weapon_data.magazine_size)


func update(delta: float) -> void:
	if _is_reloading:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_finish_reload()


func can_shoot() -> bool:
	return not _is_reloading and current_ammo > 0


func consume_round() -> void:
	current_ammo -= 1
	EventBus.ammo_changed.emit(current_ammo, inventory.weapon_data.magazine_size)


func start_reload() -> void:
	if not inventory.weapon_data:
		return
	if _is_reloading:
		return
	if current_ammo >= inventory.weapon_data.magazine_size:
		return
	_is_reloading = true
	_reload_timer = inventory.weapon_data.reload_time
	EventBus.reload_started.emit(inventory.weapon_data.reload_time)


func _finish_reload() -> void:
	_is_reloading = false
	current_ammo = inventory.weapon_data.magazine_size
	EventBus.ammo_changed.emit(current_ammo, inventory.weapon_data.magazine_size)
	EventBus.reload_finished.emit()