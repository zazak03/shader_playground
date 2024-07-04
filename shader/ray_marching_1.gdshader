shader_type canvas_item;

//sphere array : vec3(x, y, z, radius)
const vec4[] spheres = { vec4(0., 0., 0., 0.2), vec4(0., 0., 9.2, 0.6) };
const vec4[] spheres_modifications = { vec4(0., 0., 0., 0.), vec4(0., 0.5, 0., 0.) };
const vec3[] spheres_color = { vec3(0., 1., 0.), vec3(1., 1., 0.) };
const float[] sphere_repetition = {1., 0.};
const float max_distance = 100.;
const float min_distance = 0.001;
const vec3 iter_color = vec3(0.985);
const vec3 far_color = vec3(0., 0., 1.);



float op_smoothUnion( float d1, float d2){
	float smoothness = 0.9;
    float h = max( smoothness-abs(d1-d2), 0.0 )/smoothness;
    return min( d1, d2 ) - h*h*smoothness*(1.0/4.0);
}
float op_Union( float d1, float d2){
    return min( d1, d2 );
}

float sphere_distance(vec3 ray_position,vec3 sphere_position,float sphere_radius){
	return length(ray_position - sphere_position) - sphere_radius;
}

vec3 get_sphere_position(int i){
	return spheres[i].xyz + sin(TIME) * spheres_modifications[i].xyz;
}

float get_sphere_radius(int i){
	return spheres[i].w + sin(TIME) * spheres_modifications[i].w;
}

vec2 map_spheres_smooth(vec3 ray_position, float dist){
	int i_sphere = 0;
	vec3 ray;
	for (int i = 0; i < spheres.length(); i++){
		if (sphere_repetition[i] > 0.1){
			ray = fract(ray_position) - 0.5;
		}else{
			ray = ray_position;
		}
		float min_dist = op_smoothUnion(dist, sphere_distance(ray, get_sphere_position(i), get_sphere_radius(i)));
		if (min_dist < dist){
			dist = min_dist;
			i_sphere = i;
		}
	}
	return vec2(dist, float(i_sphere));
}
vec2 map_spheres(vec3 ray_position, float dist){
	int i_sphere = 0;
	vec3 ray;
	for (int i = 0; i < spheres.length(); i++){
		if (sphere_repetition[i] > 0.1){
			ray = fract(ray_position) - 0.5;
		}else{
			ray = ray_position;
		}
		float min_dist = op_Union(dist, sphere_distance(ray, get_sphere_position(i), get_sphere_radius(i)));
		if (min_dist < dist){
			dist = min_dist;
			i_sphere = i;
		}
	}
	return vec2(dist, float(i_sphere));
}


vec3 color_mix(vec3 ray_position){
	vec3 color = vec3(0,0,0);
	float total_wheight = 0. ;
	for (int i = 0; i < spheres.length(); i++){
		float dist = sphere_distance(ray_position, get_sphere_position(i), get_sphere_radius(i));
		color += spheres_color[i] * (1. / dist);
		total_wheight += 1. / dist;
	}
	return color / total_wheight;
}



vec2 map_smooth(vec3 ray_position){
	vec2 info = map_spheres_smooth(ray_position, 1000.);
	return info;
}

vec2 map(vec3 ray_position){
	vec2 info = map_spheres(ray_position, 1000.);
	return info;
}

void fragment() {
	// Place fragment code here.
	
	// initialisation
	vec2 uv = (UV*2.) - 1.; // centerize
	
	vec3 ray_origin = vec3(0, 0, -3);
	vec3 ray_direction = normalize(vec3(uv, 1));
	
	float travel_distance = 0.;
	
	vec3 col = vec3(0.8);
	
	//raymarching
	int i = 0;
	int hit_shere;
	vec3 ray_position;
	while(i < 80){
		ray_position = ray_origin + ray_direction * travel_distance;
		
		vec2 distance_and_object = map_smooth(ray_position);
		float dist_to_object = distance_and_object.x;
		hit_shere = int(distance_and_object.y);
		travel_distance += dist_to_object;
		
		if(dist_to_object < min_distance){
			//int closest_sphere = int(map(ray_position).y);
			//col = spheres_color[closest_sphere];
			break;
		}
		if (dist_to_object > max_distance){
			break;
		}
		i++;
	}
	col = color_mix(ray_position);
	col = col * pow(iter_color, vec3(float(i)));
	col *= 1. / travel_distance * 10.;
	COLOR = vec4(col, 1);
}
