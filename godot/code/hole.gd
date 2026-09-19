extends MeshInstance3D
class_name MyHole

@export var speed: float = 5.0

func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed('ui_left'):
		direction.x -= 1
	if Input.is_action_pressed('ui_right'):
		direction.x += 1
	if Input.is_action_pressed('ui_up'):
		direction.z -= 1
	if Input.is_action_pressed('ui_down'):
		direction.z += 1
	position += direction * speed * delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is MyFruit:
		print('hi fruit')
		body.sleeping = false
		body.set_meta('over_hole', true)
		body.set_collision_mask_value(1, false)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is MyFruit:
		print('bye fruit')
		body.set_collision_mask_value(1, true)
		body.set_meta('over_hole', false)
