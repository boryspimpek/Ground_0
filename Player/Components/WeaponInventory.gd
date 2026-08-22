extends Node
class_name WeaponInventory

@export var weapon_list: Array[Resource] = []

var _current_weapon_index: int = 0

var weapon_data: Resource:
	get:
		if weapon_list.is_empty():
			return null
		return weapon_list[_current_weapon_index]

var current_index: int:
	get:
		return _current_weapon_index


func _ready() -> void:
	if weapon_data:
		EventBus.weapon_changed.emit(weapon_data)


func switch_weapon() -> void:
	if weapon_list.is_empty():
		return
	_current_weapon_index = wrapi(_current_weapon_index + 1, 0, weapon_list.size())
	EventBus.weapon_changed.emit(weapon_data)