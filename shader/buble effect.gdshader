shader_type spatial;

render_mode cull_disabled, unshaded ;

uniform vec3 base_color: source_color = vec3(0, 0.549, 0.745);
uniform float transparency: hint_range(0.0, 1.0, 0.1) = 0.1;
uniform sampler2D depth_texture: hint_depth_texture;
uniform float outline_power: hint_range(0.5, 5., 0.25) = 2.;
uniform float outline_mult: hint_range(0., 1., 0.05) = 0.8;
uniform float colision_power: hint_range(0.5, 10., 0.25) = 4.;
uniform float colision_mult: hint_range(0., 1., 0.05) = 0.9;


float fresnel(vec3 pix_to_camera, vec3 normal){
	return 1. - abs(dot(pix_to_camera, normal));
}

float depth_to_linear_depth(float depth,vec2 screen_uv, mat4 inv_projection_matrix){
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
	}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// outline
	float fresnel_outline = pow(fresnel(VIEW, NORMAL) * outline_mult, outline_power);
	
	// colision
	float frag_depth = depth_to_linear_depth(FRAGCOORD.z, SCREEN_UV, INV_PROJECTION_MATRIX);
	float global_depth = depth_to_linear_depth(textureLod(depth_texture, SCREEN_UV, 10.).x, SCREEN_UV, INV_PROJECTION_MATRIX);
	float depth_diff = frag_depth - global_depth;
	float colision_outline = pow(clamp(1.+depth_diff, 0., 1.) * colision_mult, colision_power);
	//assignation
	ALBEDO = base_color;
	//ALPHA = max(colision_outline*(float(FRONT_FACING)*0.5+0.5), fresnel_outline*float(FRONT_FACING));
	ALPHA = max(colision_outline, fresnel_outline*0.5);
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
