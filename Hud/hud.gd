extends CanvasLayer
@onready var ammo_label: Label = $MarginContainer/VBoxContainer/AmmoLabel
@onready var reload_label: Label = $MarginContainer/VBoxContainer/ReloadLabel
@onready var inventory: WeaponInventory
@onready var ammo: AmmoController

var _weapon_name := ""
var _ammo_current := 0
var _ammo_max := 0

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	inventory = player.get_node("WeaponInventory")
	ammo = player.get_node("AmmoController")

	EventBus.weapon_changed.connect(_on_weapon_changed)
	EventBus.ammo_changed.connect(_on_ammo_changed)
	EventBus.reload_started.connect(_on_reload_started)
	EventBus.reload_finished.connect(_on_reload_finished)
	reload_label.visible = false
	if inventory.weapon_data:
		_on_weapon_changed(inventory.weapon_data)
		_on_ammo_changed(ammo.current_ammo, inventory.weapon_data.magazine_size)

func _on_weapon_changed(weapon: Resource) -> void:
	_weapon_name = weapon.weapon_name if weapon != null else ""
	_update_ammo_label()

func _on_ammo_changed(current: int, magazine: int) -> void:
	_ammo_current = current
	_ammo_max = magazine
	_update_ammo_label()

func _update_ammo_label() -> void:
	ammo_label.text = "%s: %d / %d" % [_weapon_name, _ammo_current, _ammo_max]

func _on_reload_started(_duration: float) -> void:
	reload_label.visible = true

func _on_reload_finished() -> void:
	reload_label.visible = false
