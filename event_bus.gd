extends Node

@warning_ignore("unused_signal")
signal weapon_changed(weapon: Resource)
@warning_ignore("unused_signal")
signal ammo_changed(current: int, magazine: int)
@warning_ignore("unused_signal")
signal reload_started(duration: float)
@warning_ignore("unused_signal")
signal reload_finished()
@warning_ignore("unused_signal")
signal grenade_count_changed(current: int, maximum: int)
