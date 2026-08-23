extends Resource
class_name GrenadeData

@export_group("Identyfikacja")
@export var id: String = ""
@export var grenade_name: String = ""

@export_group("Rzut")
@export var throw_force: float = 12.0
@export var throw_upward_angle: float = 0.3
@export var fuse_time: float = 2.5
@export var max_count: int = 3

@export_group("Wybuch")
@export var damage: float = 80.0
@export var explosion_radius: float = 5.0
@export var min_damage_multiplier: float = 0.2

@export_group("Wizualia i dźwięk")
@export var grenade_scene: PackedScene
@export var explosion_effect_scene: PackedScene
@export var throw_sound: AudioStream
@export var explosion_sound: AudioStream
