extends Node3D

var lookSensitivity : float = 40.0
var minLookAngle : float = -20.0
var maxLookAngle : float = 75.0

var mouseDelta : Vector2 = Vector2()

@onready var player = get_parent()

func _input(event):			# Lorsque la souris du joueur bouge
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rot = Vector3(mouseDelta.y, mouseDelta.x, 0) * lookSensitivity * delta
	
	rotation_degrees.x += rot.x
	rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)
	
	player.rotation_degrees.y -= rot.y
	
	mouseDelta = Vector2()
