extends Node

export (NodePath) var island_parent
export (PackedScene) var ground_object

export (Material) var sand_mat
export (Material) var grass_mat

var generated_parent : Node

var noise : OpenSimplexNoise

func _ready() -> void:
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 40.0
	noise.persistence = 0.8
	
	call_deferred("setup_generation")

func setup_generation() -> void:
	var island_node: Node = get_node(island_parent)
	
	generated_parent = Node.new()
	generated_parent.set_name("Ground")
	island_node.add_child(generated_parent)
	
	generate()

func _process(_delta) -> void:
	if Input.is_action_just_pressed("generate"):
		clean()
		generate()

func clean() -> void:
	for child in generated_parent.get_children():
		child.queue_free()
	
	noise.seed = randi()

func generate() -> void:
	var x_width: int = 35 + pos_int_rand(20)
	var z_width: int = 35 + pos_int_rand(20)
	
	var ground_parent: Node = Node.new()
	ground_parent.set_name("Ground")
	generated_parent.add_child(ground_parent)
	
	var gcount: = 0
	for j in range(z_width):
		for i in range(x_width):
			gcount += 1
			var g : Spatial = ground_object.instance()
			
			var ground_height_x : float = 0
			var ground_height_z : float = 0
			
			var ghs : float = 4.1
			
			ground_height_x += four_stage_quadratic((i/(x_width - 1.0)), 0, 1) * 4.1
			ground_height_z += four_stage_quadratic((j/(z_width - 1.0)), 0, 1) * 4.1
			#var ground_height: = sqrt(ground_height_x * ground_height_z)
			#var ground_height : = (ground_height_x + ground_height_z)/(ghs*2)
			var ground_height : = min(ground_height_x, ground_height_z)
			
			var noise_height = noise.get_noise_2d(i, j) * 4.0
			
			var final_height : float = sqrt(ground_height * noise_height)
			
			var water_point : float = 0.2
			final_height = final_height - water_point
			
#			if gcount == 10:
#				print([ground_height_x, i, i/(x_width - 1.0), four_stage_quadratic(1, 0, 1)])

			if is_nan(final_height):
				final_height = 0
			var ground_color : Color = Color("ede7a4")
			ground_color = ground_color.linear_interpolate(Color(0, 1, 0), final_height/2.1)
			
			#g.set_color(ground_color)
			g.set_mat(grass_mat if final_height > 0.3 else sand_mat)
			
			g.translate(Vector3(i, final_height, j))
			
			ground_parent.add_child(g)
			
			

# int in range 0 -> high - 1
func pos_int_rand(high : int) -> int:
	return int_rand(0, high)

# int in range low -> high - 1
func int_rand(low : int, high : int) -> int:
	return int(rand_range(low, high))

func four_stage_quadratic (delta : float, start : float, max_val : float) -> float:
	delta *= 4
	if (delta < 1):
		 return (max_val/2)*delta*delta + start
	delta -= 1
	if (delta < 1):
		return -max_val/2 * (delta*(delta-2) - 1) + start;
	delta -= 1
	if (delta < 1):
		var d = 1 - delta
		return -max_val/2 * (d*(d-2) - 1) + start;
	delta -= 1
	var d = 1 - delta
	return (max_val/2)*d*d + start
