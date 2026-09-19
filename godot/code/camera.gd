extends Camera3D
class_name MyCamera

@export var target: Node3D:
	set(value):
		target = value
		offset = global_position - target.global_position

@export var offset: Vector3 = Vector3(0, 2, 5)

func _process(_delta):
	if target:
		global_position = target.global_position + offset
		look_at(target.global_position)
