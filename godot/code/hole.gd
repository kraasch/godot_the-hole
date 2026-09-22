@tool
extends MeshInstance3D
class_name MyHole

const GROWTH_INCREMENT: float = 1.0 / 16.0

signal grows_in_radius(new_radius: float)

@export var speed: float = 5.0
@onready var ring: CollisionShape3D = %ring
@onready var static_body: StaticBody3D = %static_body

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

func _on_area_3d_2_body_exited(body: Node3D) -> void:
	_grow_hole()

func _ready() -> void:
	_grow_hole()
	
func _grow_hole() -> void:
	#body.owner.queue_free() # TODO: remove the fruits.
	print('+1UP')
	var shape: CylinderShape3D = ring.shape
	shape.radius += GROWTH_INCREMENT
	var cylinder_mesh: CylinderMesh = mesh as CylinderMesh
	cylinder_mesh.top_radius = shape.radius
	cylinder_mesh.bottom_radius = shape.radius
	grows_in_radius.emit(shape.radius)
	_update_pilars()

func _update_pilars() -> void:
	var cylinder: CylinderShape3D = ring.shape
	create_collision_ring(static_body, cylinder, 30)

func create_collision_ring(
	parent: Node3D,
	cylinder_shape: CylinderShape3D,
	shape_count: int,
) -> void:
	for child: Node in parent.get_children():
		child.queue_free()
	var pilar_depth: float = 6.0
	var pilar_dimension: float = 0.5
	var radius: float = cylinder_shape.radius
	for i in range(shape_count):
		var angle: float = TAU * float(i) / float(shape_count)
		var collision: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = Vector3(pilar_dimension, pilar_depth, pilar_dimension)
		collision.shape = shape
		var pos_x: float = cos(angle) * radius
		var pos_z: float = sin(angle) * radius
		collision.position = Vector3(pos_x, -pilar_depth/2.0, pos_z)
		collision.rotation.y = PI - angle
		parent.add_child(collision)
