extends Node2D

### this algorith is take frome this paper : https://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf
### find with this website https://www.jasondavies.com/poisson-disc/
###
### :)

class Background_space_grid: 
	var grid:Array
	var square_size:float
	var left_bound:float
	var right_bound:float
	var top_bound:float
	var bottom_bound:float
	var id_counter:int = 0
	
	func _init(_left:float,_right:float,_down:float,_up:float,_square_size):
		left_bound = _left
		right_bound = _right
		top_bound = _up
		bottom_bound = _down
		square_size = _square_size
		grid = []
		var intermidiate_grid
		for i in range(float(right_bound - left_bound)/square_size + 1):
			intermidiate_grid = []
			for j in range(float(top_bound - bottom_bound)/square_size + 1):
				intermidiate_grid.append([])
			grid.append(intermidiate_grid)
	
	func get_point_id(point:Vector2):
		for p in get_square(point):
			if p[1] == point:
				return p[0]
	
	func update_grid_bound(left_new:float,right_new:float,bottom_new:float,top_new:float):
		var intermidiate_grid
		#on top & bottom
		for collumn in grid:
			#bottom
			for i in range(bottom_new/square_size, bottom_bound/square_size):
				collumn.push_front([])
			for i in range(top_bound/square_size, top_new/square_size):
				collumn.push_back([])
		
		# on left
		for i in range(left_new/square_size, left_bound/square_size):
			intermidiate_grid = []
			for j in range(min(left_new, left_bound)/square_size, max(right_new, right_bound)/square_size):
				intermidiate_grid.append([])
			grid.push_front(intermidiate_grid)
		
		#on right
		for i in range(right_bound/square_size, right_new/square_size):
			intermidiate_grid = []
			for j in range(min(left_new, left_bound)/square_size, max(right_new, right_bound)/square_size):
				intermidiate_grid.append([])
			grid.push_back(intermidiate_grid)
			
		#update bound
		left_bound = left_new
		right_bound = right_new
		bottom_bound = bottom_new
		top_bound = top_new
		
	
	func is_point_in_bound(point:Vector2):
		return (left_bound <= point.x && point.x <= right_bound ) && (bottom_bound <= point.y && point.y <= top_bound)
	
	func append_point(point:Vector2):
		if not is_point_in_bound(point):
			return
		grid[(point.x - left_bound)/square_size][(point.y - bottom_bound)/square_size].append([id_counter, point])
		id_counter+=1
	
	func square_in_bound(point_in_square:Vector2):
		if len(grid) < (point_in_square.x - left_bound)/square_size || 0 > (point_in_square.x - left_bound)/square_size:
			return false
		if len(grid[0]) < (point_in_square.y - bottom_bound)/square_size || 0 > (point_in_square.y - bottom_bound)/square_size:
			return false
		return true
	
	func get_square(point_in_square:Vector2):
		if not square_in_bound(point_in_square):
			return []
		return grid[int((point_in_square.x - left_bound)/square_size)][int((point_in_square.y - bottom_bound)/square_size)]
	
	func column_len():#return the size of a column the number of square in a vertical column
		return float(top_bound - bottom_bound)/square_size + 1
	func line_len():#return the size of a line the number of square in a horizontal line
		return float(right_bound - left_bound)/square_size + 1
	

### end of class


func generate_point_around_point(origine_point, min_radius, max_radius):
	var radius = (randf() * (max_radius - min_radius)) + min_radius #generate a radius between min_radius and max_radius
	var angle = randf() * TAU # generate a random angle
	var direction = Vector2(0,1).rotated(angle) #give a normalized vector with an random direction
	return origine_point + direction * radius

func is_enought_far_away(point:Vector2, radius:float, space_grid: Background_space_grid):
	# find if my_point is at least radius away from each point in space_grid
	var square_size = space_grid.square_size
	var i = point.x - radius - square_size
	while (i < point.x + radius + square_size): #for range loop but with float
		i += square_size
		
		
		var j = point.y - radius - square_size
		while (j < point.y + radius +square_size):
			j += square_size
			
			for point_to_compare in space_grid.get_square(Vector2(i,j)):
				if point.distance_to(point_to_compare[1]) < radius:
					return false
			
	return true

func add_to_space_list(space_grid:Background_space_grid, point:Vector2):
	space_grid.append_point(point)

func poisson_disk_algorism (radius, left, right, down, up, initial_value:Vector2 = Vector2(0,0), square_size = 1, space_grid = 1 ): #dimension = 2
	
	if typeof(space_grid) == TYPE_INT:
		space_grid = Background_space_grid.new(left, right, down, up, square_size)
	else:
		pass
		#space_grid.update_grid_bound(left, right, down, up)
	
	if not space_grid.is_point_in_bound(initial_value):
		return [space_grid,[]]
	
	var k = 3
	var active_list = [initial_value]
	var just_the_array_of_points = []
	
	add_to_space_list(space_grid, initial_value)
	while (! active_list.is_empty()):
		var choosen_index = randi_range(0, len(active_list)-1)
		var choosen_point = active_list[choosen_index]
		var new_point_found = false
		var my_point:Vector2
		for i in range(k):
			my_point = generate_point_around_point(choosen_point, radius, 2*radius)
			if not space_grid.is_point_in_bound(my_point):
				continue
			if is_enought_far_away(my_point, radius, space_grid):
				new_point_found = true
				active_list.append(my_point)
				just_the_array_of_points.append([space_grid.id_counter, my_point])
				add_to_space_list(space_grid, my_point)# has to after just_the_array_of_points because 
				break
		# end of the loop
		if new_point_found:
			pass
		else:
			active_list.pop_at(choosen_index)
	return [space_grid,just_the_array_of_points]


func poisson_disk_algorism_with_radius (visibility_center:Vector2, visibility_range:float, radius, left, right, down, up, initial_value:Vector2 = Vector2(0,0), square_size = 1, space_grid = 1 ): #dimension = 2
	
	if typeof(space_grid) == TYPE_INT:
		space_grid = Background_space_grid.new(left, right, down, up, square_size)
	else:
		pass
		#space_grid.update_grid_bound(left, right, down, up)
	
	if not space_grid.is_point_in_bound(initial_value) || initial_value.distance_to(visibility_center)>visibility_range || not is_enought_far_away(initial_value, radius, space_grid):
		return [space_grid,[]]
	
	var k = 3
	var active_list = [initial_value]
	var just_the_array_of_points = []
	
	just_the_array_of_points.append([space_grid.id_counter, initial_value])
	add_to_space_list(space_grid, initial_value)
	while (! active_list.is_empty()):
		var choosen_index = randi_range(0, len(active_list)-1)
		var choosen_point = active_list[choosen_index]
		var new_point_found = false
		var my_point:Vector2
		for i in range(k):
			my_point = generate_point_around_point(choosen_point, radius, 2*radius)
			if not space_grid.is_point_in_bound(my_point) || my_point.distance_to(visibility_center)>visibility_range:
				continue
			if is_enought_far_away(my_point, radius, space_grid):
				new_point_found = true
				active_list.append(my_point)
				just_the_array_of_points.append([space_grid.id_counter, my_point])
				add_to_space_list(space_grid, my_point)# has to after just_the_array_of_points because 
				break
		# end of the loop
		if new_point_found:
			pass
		else:
			active_list.pop_at(choosen_index)
	return [space_grid,just_the_array_of_points]




# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
