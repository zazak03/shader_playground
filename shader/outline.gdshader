shader_type spatial;
uniform float x_mult:hint_range(0.9, 5) = 1.;
uniform float y_mult:hint_range(0.9, 5) = 1.;
uniform float w_mult:hint_range(0, 1.5) = 1.;
uniform float z_mult:hint_range(0, 1.5) = 1.;
uniform vec3 outline_color:source_color;

render_mode world_vertex_coords;
render_mode ambient_light_disabled, shadows_disabled, specular_disabled;


void vertex() {
	COLOR.rgb = VERTEX;
	vec4 homogenous_coords = vec4(VERTEX, 1.);
	vec4 view_vertex = MODELVIEW_MATRIX * homogenous_coords;
	vec4 clip_vertex = PROJECTION_MATRIX * view_vertex;
	vec4 backwardedd_clip_vertex = vec4(clip_vertex.x*x_mult, clip_vertex.y*y_mult, clip_vertex.z*z_mult, clip_vertex.w*w_mult);
	vec4 backwardedd_view_vertex = INV_PROJECTION_MATRIX * backwardedd_clip_vertex ;
	vec4 backwardedd_homogenous_coord =  inverse(MODELVIEW_MATRIX) * backwardedd_view_vertex;
	VERTEX = backwardedd_homogenous_coord.xyz;
	COLOR.rgb = clip_vertex.xyz * 0.1;
	//COLOR.rgb = vec3(0.2, 0.4, 0.9);
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = COLOR.rgb;
	ALBEDO = outline_color;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
