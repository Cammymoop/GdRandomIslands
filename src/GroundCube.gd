extends Spatial


func _ready():
	var mat = SpatialMaterial.new()
	$GroundCube.material_override = mat
	
func set_mat(material : Material) -> void:
	call_deferred("_set_mat", material)

func _set_mat(material : Material) -> void:
	$GroundCube.material_override = material

func set_color(color : Color) -> void:
	call_deferred("_set_color", color)

func _set_color(color : Color) -> void:
	$GroundCube.material_override.albedo_color = color
