shader_type spatial;

//render_mode cull_disabled;
//render_mode diffuse_toon;

uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform sampler2D wind_noize;
uniform vec2 wind_direction;
uniform vec2 direction;
uniform vec2 position;
uniform float time_scale = 1.;
uniform float noise_time_scale = 1.;
uniform float wind_force : hint_range(0.0, 1.0);

uniform float curbature_force: hint_range(0.0, 1.0, 0.1) = 0.1;
uniform sampler2D player_on_floor;

varying float curbature;
varying float debug_var;
varying vec3 debug_var_2;

void vertex() {
	//float wind_unoriented_force = wind_force * texture(wind_noize, (INSTANCE_CUSTOM.xy + normalize(wind_direction) * TIME) * time_scale).x;
	float wind_unoriented_force = wind_force * ((sin(INSTANCE_CUSTOM.x*0.5 + TIME * time_scale)*0.5 + 0.5) + texture(wind_noize ,(INSTANCE_CUSTOM.xy*0.5 + vec2(TIME,0.) * time_scale * noise_time_scale)).x * 0.5);
	debug_var = wind_unoriented_force;
	//float wind_oriented_force = dot(normalize(wind_direction),normalize(INSTANCE_CUSTOM.zw)) * wind_unoriented_force;
	float wind_oriented_force = wind_unoriented_force;
	
	float player_curbature = 1. - texture(player_on_floor,INSTANCE_CUSTOM.xy/10. + 0.5).x;
	float wind_curbature = (wind_oriented_force + curbature_force) * (1.-UV.y);
	
	curbature = min(player_curbature + wind_curbature, 3.); //no overflow
	
	VERTEX.y = VERTEX.x * (sin(curbature * PI /2.));
	VERTEX.x = VERTEX.x * (cos(curbature * PI /2.));
	//NORMAL = mix(vec3(-(cos(curbature * PI /2.)),-(sin(curbature * PI /2.)),0),vec3(0.,1.,0.), 1.);
	debug_var = player_curbature;
	debug_var_2 = texture(player_on_floor,UV).xyz;
}

void fragment() {
	ALBEDO  = mix(albedo,albedo2, UV.y);
	NORMAL = vec3(0.,1.,0.);
	NORMAL_MAP = vec3(0.,1.,0.);
	ALBEDO = debug_var_2;
	if (debug_var<0. || debug_var >1.){
		ALBEDO = vec3(1.,1.,1.);
	}
	ALBEDO = texture(player_on_floor,UV).rgb;
	// Place fragment code here.
}
