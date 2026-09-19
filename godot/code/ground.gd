extends StaticBody3D
class_name MyGround

@onready var ground_mesh: MeshInstance3D = %ground_mesh
@export var target: Node3D

func _physics_process(_delta: float) -> void:
	var shader_material: ShaderMaterial = ground_mesh.material_override as ShaderMaterial
	if shader_material and target:
		shader_material.set_shader_parameter('hole_world_position', target.global_position)
