extends OmniLight3D

@export_group("Base Parameters")
@export var base_energy: float = 2.0        # Średnia jasność światła
@export var base_range: float = 8.0         # Średni zasięg (Omni Range)

@export_group("Flicker Intensity")
@export var energy_flicker: float = 0.6     # Jak mocno ma drgać jasność (+/-)
@export var range_flicker: float = 0.8      # Jak mocno ma zmieniać się zasięg (+/-)
@export var noise_speed: float = 12.0       # Szybkość "tańca" ognia

@export var color_bright: Color = Color("ffa033") # Jasny pomarańcz (szczyt płomienia)
@export var color_dim: Color = Color("d64500")    # Ciemny pomarańcz/czerwień (przygaśnięcie)

var _time: float = 0.0
var _noise := FastNoiseLite.new()

func _ready() -> void:
	# Konfiguracja szumu dla organicznego efektu
	_noise.seed = randi()
	_noise.frequency = 0.1

func _process(delta: float) -> void:
	_time += delta * noise_speed
	
	# Pobieramy wartość z wygładzonego szumu (zamiast czystego randf)
	var n: float = _noise.get_noise_1d(_time) # Wartość od -1.0 do 1.0
	
	# Nakładamy drganie na jasność i zasięg
	light_energy = maxf(0.0, base_energy + (n * energy_flicker))
	omni_range = maxf(0.0, base_range + (n * range_flicker))
	
	var color_factor: float = clamp((n + 1.0) / 2.0, 0.0, 1.0)
	light_color = color_dim.lerp(color_bright, color_factor)
