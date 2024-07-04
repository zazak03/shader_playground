extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var grids_1 = $poisson_disk_generator.poisson_disk_algorism(1,0,10,0,5, Vector2(0,0), 1)
	print("a")
	for l1 in grids_1[0].grid:
		for l2 in l1:
			for coord in l2:
				await get_tree().create_timer(0.1).timeout
				$SubViewport/point.position = coord*10
	await get_tree().create_timer(1).timeout
	
	var grids_2 = $poisson_disk_generator.poisson_disk_algorism(1,0,10,0,10, Vector2(10,10), 1, grids_1[0])
	for coord in grids_2[1]:
		await get_tree().create_timer(0.1).timeout
		$SubViewport/point.position = coord*10
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
