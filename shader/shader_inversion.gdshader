shader_type canvas_item;

void fragment() {
	COLOR = vec4( 1. - COLOR.r, 1. - COLOR.g, 1. - COLOR.b, 1);
	// Place fragment code here.
}
