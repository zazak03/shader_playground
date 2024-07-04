shader_type spatial;

render_mode specular_toon;

uniform float map_scale = 2.;
uniform float time_scale = 0.05;
uniform float time_height_scale = 0.2;
uniform float height_scale = 0.05;
uniform float normal_scale: hint_range(0.0, 1.0) = 0.;
uniform sampler2D noise1;
uniform sampler2D depth_texture: hint_depth_texture;
uniform float depth_max_vision = 10.;

uniform vec3 albedo_2nd : source_color;


varying vec2 tex_position;

float depth_to_linear_depth(float depth,vec2 screen_uv, mat4 inv_projection_matrix){
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

float height(vec2 pos){
	return texture(noise1, (pos + vec2(0., TIME*time_scale))/map_scale).x * height_scale;
}

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void vertex() {
	tex_position = VERTEX.xz / 2.0 + 0.5 ;
	//world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz / 2.;  
	VERTEX.y += height(tex_position) + sin(TIME + tex_position.x*2.) * time_height_scale;
	/*TANGENT = normalize(vec3(0.0, height(tex_position + vec2(0., epsilon)) - height(tex_position - vec2(0., epsilon)), epsilon*2.));
	BINORMAL = normalize(vec3(epsilon*2., height(tex_position + vec2(epsilon, 0.)) - height(tex_position - vec2(epsilon, 0.)), 0.0));
	NORMAL = mix(cross(TANGENT, BINORMAL), NORMAL, normal_scale);*/
}

void fragment() {
	float d = cos(TIME + tex_position.x*2.);
	float frag_depth = depth_to_linear_depth(FRAGCOORD.z, SCREEN_UV, INV_PROJECTION_MATRIX);
	float global_depth = depth_to_linear_depth(textureLod(depth_texture, SCREEN_UV, 10.).x, SCREEN_UV, INV_PROJECTION_MATRIX);
	float x = clamp((global_depth-frag_depth)/depth_max_vision, 0., 1.);
	NORMAL = normalize(vec3(d, 1, 0));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.9 ;
	ALBEDO = vec3(0.01, 0.03, 0.05) * (0.5 + 0.5 * x);
	//ALPHA = pow(4., x) /4.;
	ALPHA = x*0.5 + 0.5;
	//ALBEDO = vec3((global_depth-frag_depth)/depth_max_vision);
	//ALBEDO = normalize(vec3(-d, 1, 0));
}
