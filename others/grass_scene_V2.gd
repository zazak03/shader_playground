extends Node3D

@export var my_height:float = 1.
@export var density:Texture2D
@export var grass_generation_distance:float = 10
var grass_matrix
var previous_player_position
var counter:float = 0
var mesh_counter = 0

func set_viewport_to_shader(viewport:SubViewport, node:MultiMeshInstance3D):
	var my_mat : ShaderMaterial = node.multimesh.mesh.surface_get_material(0)
	my_mat.set_shader_parameter("player_on_floor",viewport.get_texture())
	node.multimesh.mesh.surface_set_material(0,my_mat)

func get_position_with_density(density:Image):
	pass

func add_grass(positions:Array, multimesh:MultiMesh):
	if len(positions) == 0:
		return
	var i_offset = multimesh.instance_count
	for p in positions:
		var trasform = Transform3D()
		#scale
		trasform = trasform.scaled(Vector3(0.2,0.2,0.2)) #mise à la bone taille
		trasform = trasform.scaled(Vector3(1,1,1) * (randf()*0.5+0.7))
		#rotate
		trasform = trasform.rotated(Vector3(0,0,-1),PI/2) #mise à la verticale
		var new_orientation = 2 * PI * randf()
		trasform = trasform.rotated(Vector3(0,1,0),new_orientation) #orientation aléatoire
		#translate
		var new_position = Vector3(p[1].x,0,p[1].y)
		trasform = trasform.translated(new_position) #position aléatoire
		multimesh.set_instance_transform(p[0], trasform)
		multimesh.set_instance_custom_data(p[0],Color(new_position.x,new_position.z,cos(new_orientation),sin(new_orientation)))
		

# Called when the node enters the scene tree for the first time.
func _ready():
	var multimesh: MultiMesh = $grass.multimesh
	multimesh.set_instance_count(100000)
	var grasses_location
	var left = $player.position.x - grass_generation_distance *4
	var right = $player.position.x + grass_generation_distance*4
	var bottom = $player.position.z - grass_generation_distance*4
	var top = $player.position.z + grass_generation_distance*4
	var player_xy = Vector2($player.position.x, $player.position.z)
	previous_player_position = player_xy
	var temp = $poisson_disk_generator.poisson_disk_algorism_with_radius(player_xy, grass_generation_distance, 0.11, left, right, bottom, top, player_xy,0.1)
	grasses_location = temp[1]
	grass_matrix = temp[0]
	add_grass(grasses_location, multimesh)
	print(len(grasses_location))
	set_viewport_to_shader($SubViewport, $grass)
	$grass.multimesh.mesh.surface_get_material(0).set_shader_parameter("player_on_floor_size",$dirt.mesh.size.x)
	$SubViewport/point.scale = Vector2(1,1) * 10/$dirt.mesh.size.x
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var point_gradient: GradientTexture2D = $SubViewport/point.texture
	var c = Color(($player.position.y-1)/my_height,($player.position.y-1)/my_height,($player.position.y-1)/my_height)
	point_gradient.gradient.set_color(0,c)
	$SubViewport/point.position = Vector2(
		($player.position.x / $dirt.mesh.size.x + 0.5) * $SubViewport.size.x,
		($player.position.z / $dirt.mesh.size.y + 0.5) * $SubViewport.size.y
	)
	counter += delta
	if true:
		counter = 0
		var left = $player.position.x - grass_generation_distance 
		var right = $player.position.x + grass_generation_distance
		var bottom = $player.position.z - grass_generation_distance
		var top = $player.position.z + grass_generation_distance
		var player_xy = Vector2($player.position.x, $player.position.z)
		var new_point = player_xy + (player_xy - previous_player_position).normalized() * grass_generation_distance
		var temp = $poisson_disk_generator.poisson_disk_algorism_with_radius(player_xy, grass_generation_distance, 0.125, left, right, bottom, top, new_point,grass_matrix.square_size, grass_matrix)
		var grasses_location = temp[1]
		grass_matrix = temp[0]
		add_grass(grasses_location, $grass.multimesh)
		print(len(grasses_location))
		previous_player_position = player_xy
		#add_grass(temp[1], $grass.multimesh)
	#$grass.set_instance_shader_parameter("player_on_floor",$SubViewport/point)
