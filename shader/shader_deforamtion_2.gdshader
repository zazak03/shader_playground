shader_type canvas_item;

uniform sampler2D my_noize1;
uniform sampler2D my_noize2;
uniform float noise_zoom: hint_range(0.0001, 1.0) = 0.5;
uniform float deformation_scale: hint_range(0.0, 1.0) = 0.1;
uniform float time_speed1 : hint_range(0.0, 0.1) = 0.05;
uniform float time_speed2 : hint_range(0.0, 0.1) = 0.05;

vec2 timing1_vec(){
	return vec2(TIME, 0.) * time_speed1;
}
vec2 timing2_vec(){
	return vec2(0., TIME) * time_speed2;
}


void fragment() {
	float offset_1 = texture(my_noize1, mod(UV*noise_zoom + timing1_vec(), 1.0)).r* deformation_scale;
	float offset_2 = texture(my_noize2, mod(UV*noise_zoom + timing2_vec(), 1.0)).r* deformation_scale*0.2;
	vec4 new_color = texture(TEXTURE, UV + offset_1 + offset_2 - 0.01); 
	COLOR = new_color;	// Place fragment code here.
}
