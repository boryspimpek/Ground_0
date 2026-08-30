shader_type spatial;
// Tryb przezroczystości
render_mode depth_draw_opaque, cull_back;
uniform vec3 albedo_color : source_color = vec3(0.1, 0.1, 0.1); 
uniform sampler2D albedo_texture : source_color; 
// Skalowanie UV tekstury
// X = kafelkowanie wzdłuż
// Y = kafelkowanie w poprzek
uniform vec2 albedo_uv_scale = vec2(10.0, 1.0);

// --- Normal mapa ---
uniform sampler2D normal_texture : hint_normal;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;

// Ustawienia proceduralnego poszarpania
uniform sampler2D noise_texture : hint_default_black; // Tu wgramy FastNoiseLite
uniform float edge_sharpness : hint_range(0.01, 1.0) = 0.05; // Ostrość przejścia (zygzak vs rozmycie)
uniform float ruggedness : hint_range(0.0, 1.0) = 0.3; // Jak głębokie są wyrwy
uniform float base_width : hint_range(0.0, 1.0) = 0.5; // Średnia szerokość 
uniform float world_scale = 1.0; // Skalowanie poszarpania wzdłuż 
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	// 1. Obliczamy pozycję wzdłuż.
	// Używamy UV.x.
	float road_position = UV.x * world_scale;
	
	// 2. Pobieramy wartość szumu (poszarpania) dla tej pozycji.
	float jagged_offset = texture(noise_texture, vec2(road_position, 0.0)).r;
	
	// 3. Modulujemy szum przez parametry.
	jagged_offset = (jagged_offset - 0.5) * ruggedness * 2.0;
	
	// 4. Obliczamy finalną maskę krawędzi.
	float y_dist = abs(UV.y - 0.5);
	
	float mask = smoothstep(
		base_width - edge_sharpness + jagged_offset,
		base_width + jagged_offset,
		y_dist
	);
	
	// 1 = środek, 0 = brzegi
	float alpha = 1.0 - mask;
	// 5. Kolor + tekstura
	vec3 fill_color = albedo_color;
	
	// Skalowanie / kafelkowanie tekstury (te same UV co albedo)
	vec2 tex_uv = UV * albedo_uv_scale;
	fill_color *= texture(albedo_texture, tex_uv).rgb;
	
	ALBEDO = fill_color;
	
	// --- Normal mapping ---
	NORMAL_MAP = texture(normal_texture, tex_uv).rgb;
	NORMAL_MAP_DEPTH = normal_strength;
	
	// Przezroczystość
	ALPHA = alpha;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}