shader_type canvas_item;

uniform float scale : hint_range(0.1, 10) = 1.; 
uniform float offset : hint_range(-2, 2) = 0.; 

void fragment() {
	vec2 distorted_UV = UV;
	distorted_UV.x += offset; //offset bouge avec le temps pour annimer le tout (dans le .gd)
	if (distorted_UV.x < 0.){ //jolie fonction de transition qui va de 0 à 1 de façon smooth
		distorted_UV.y += (1. - exp(distorted_UV.x*scale)) * 0.5 +0.5;
	}else{
		distorted_UV.y += (-1. + exp(-distorted_UV.x*scale)) * 0.5 +0.5;
	}
	distorted_UV.x = UV.x; // seul y doit bouger, pas x
	vec4 pixel_color = texture(TEXTURE, distorted_UV);
	
	COLOR = pixel_color;
	// Place fragment code here.
}
