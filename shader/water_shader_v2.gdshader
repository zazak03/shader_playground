shader_type spatial;

//render_mode specular_toon;

uniform float map_scale = 2.;
uniform float time_scale = 0.05;
uniform float height_scale = 0.5;
uniform float normal_map_scale: hint_range(0.0, 1.0) = 0.;
uniform sampler2D noise1;
uniform sampler2D noise2;
uniform sampler2D normalmap;
uniform float epsilon: hint_range(0.0, 0.2) = 0.05;

uniform vec3 albedo_1st : source_color;
uniform vec3 albedo_2nd : source_color;


varying vec2 tex_position;

float height(vec2 pos){
	return mix(texture(noise1, (pos + vec2(0., TIME*time_scale))/map_scale).x, texture(noise2, (pos + vec2(TIME*time_scale, 0.))/map_scale ).x, 0.5) * height_scale;
}

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void vertex() {
	tex_position = VERTEX.xz / 2.0 + 0.5 ;
	VERTEX.y += height(tex_position);
	//world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz / 2.;  
	//NORMAL = mix(cross(TANGENT, BINORMAL), NORMAL, normal_map_scale);
}

void fragment() {
	vec2 wrld_vertex = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
	TANGENT = normalize(vec3(0.0, height(wrld_vertex + vec2(0., epsilon)) - height(wrld_vertex - vec2(0., epsilon)), epsilon*2.));
	BINORMAL = normalize(vec3(epsilon*2., height(wrld_vertex + vec2(epsilon, 0.)) - height(wrld_vertex - vec2(epsilon, 0.)), 0.0));
	NORMAL = mix(cross(TANGENT, BINORMAL), NORMAL, normal_map_scale);
	
	RIM = 0.0;
	//METALLIC = 0.0;
	ROUGHNESS = 0.08 * (1.0 - fresnel(5.0, NORMAL, VIEW));
	ROUGHNESS = 0.1;
	ALBEDO = mix(vec3(0.01, 0.03, 0.05), albedo_2nd, fresnel(5.0, NORMAL, VIEW));
}
