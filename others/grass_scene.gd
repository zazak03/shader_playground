extends Node3D

@export var my_height:float = 1.

func set_viewport_to_shader(viewport:SubViewport, node:MultiMeshInstance3D):
	var my_mat : ShaderMaterial = node.multimesh.mesh.surface_get_material(0)
	my_mat.set_shader_parameter("player_on_floor",viewport.get_texture())
	node.multimesh.mesh.surface_set_material(0,my_mat)


# Called when the node enters the scene tree for the first time.
func _ready():
	var multimesh: MultiMesh = $grass.multimesh
	multimesh.set_instance_count(20_000)
	for i in range(multimesh.instance_count):
		var position = Transform3D()
		#scale
		position = position.scaled(Vector3(0.2,0.15,0.15)) #mise à la bone taille
		position = position.scaled(Vector3(1,1,1) * (randf()*0.5+0.7))
		#rotate
		position = position.rotated(Vector3(0,0,-1),PI/2) #mise à la verticale
		var new_orientation = 2 * PI * randf()
		position = position.rotated(Vector3(0,1,0),new_orientation) #orientation aléatoire
		#translate
		var new_position = Vector3(randf() * 10 - 5,0,randf() * 10 - 5)
		position = position.translated(new_position) #position aléatoire
		multimesh.set_instance_transform(i, position)
		multimesh.set_instance_custom_data(i,Color(new_position.x,new_position.z,cos(new_orientation),sin(new_orientation)))
	set_viewport_to_shader($SubViewport, $grass)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("hey")
	var point_gradient: GradientTexture2D = $SubViewport/point.texture
	var c = Color(($player.position.y-1)/my_height,($player.position.y-1)/my_height,($player.position.y-1)/my_height)
	point_gradient.gradient.set_color(0,c)
	print(c)
	$SubViewport/point.position = Vector2(
		($player.position.x / $dirt.mesh.size.x + 0.5) * $SubViewport.size.x,
		($player.position.z / $dirt.mesh.size.y + 0.5) * $SubViewport.size.y
	)
	#$grass.set_instance_shader_parameter("player_on_floor",$SubViewport/point)
