extends Resource
class_name WeaponData

@export_group("Identyfikacja")
@export var id: String = ""
@export var weapon_name: String = ""

@export_group("Strzelanie")
@export var is_automatic: bool = false
@export var cooldown: float = 0.2
@export var damage: float = 10.0
@export var max_range: float = 30.0
@export var min_falloff_range: float = 15.0
@export var min_damage_multiplier: float = 0.5

@export_group("Rozrzut")
@export var pellets_per_shot: int = 1
@export var spread_angle: float = 0.0

@export_group("Magazynek")
@export var magazine_size: int = 12
@export var reload_time: float = 1.5

@export_group("Wizualia i dźwięk")
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 60.0
@export var muzzle_flash_scene: PackedScene
@export var fire_sound: AudioStream
@export var reload_sound: AudioStream
