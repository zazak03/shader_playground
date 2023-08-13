@tool
extends Node3D
var image

@export var noise: Texture2D :
	set (value):
		noise = value
		image = noise.get_image()
	get:
		return noise
@export var mountain_height:float = 1
@export var refresh:bool = false :
	set (value):
		_ready()
		refresh = false
	get:
		return refresh


func get_value(image, max_coord_with:int, max_coord_height:int, x:int, y:int):
	return image.get_pixel(int(float(x)/float(max_coord_with)*float(noise.get_width())), int(float(y)/float(max_coord_height)*float(noise.get_height()))).r

# Called when the node enters the scene tree for the first time.
func _ready():
	print("hello world")
	var shape:HeightMapShape3D = $StaticBody3D/CollisionShape3D.shape
	var width = shape.map_width
	var height = shape.map_depth
	
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
