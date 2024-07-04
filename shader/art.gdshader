shader_type canvas_item;

void fragment() {
	// Place fragment code here.
	
	// centerize
	vec2 center_UV = (UV*2.) - 1.;
	
	float center_distance = distance(vec2(0,0), center_UV);
	
	COLOR = vec4(center_distance, 0, 0, 1);
}
