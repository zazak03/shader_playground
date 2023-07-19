extends Node2D

var offset = -2
var active = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if event.is_action_pressed("press"):
		active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if offset < 1 and active == true:
		offset += delta *1.5
	$Image1.material.set_shader_parameter("offset", offset)
	
