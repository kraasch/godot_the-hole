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

func _on_area_3d_2_body_exited(_body: Node3D) -> void:
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
	var pillar_depth: float = 6.0
	var pillar_dimension: float = 0.5
	var radius: float = cylinder_shape.radius
	var inner_radius: float = radius
	radius += pillar_dimension
	var half_depth: float = pillar_depth * 0.5
	var faces: PackedVector3Array = PackedVector3Array()
	for i in range(shape_count):
		var angle0: float = TAU * float(i) / float(shape_count)
		var angle1: float = TAU * float(i + 1) / float(shape_count)
		var cos0: float = cos(angle0)
		var sin0: float = sin(angle0)
		var cos1: float = cos(angle1)
		var sin1: float = sin(angle1)
		var outer_bottom0: Vector3 = Vector3(
			cos0 * radius,
			-half_depth,
			sin0 * radius
		)
		var outer_bottom1: Vector3 = Vector3(
			cos1 * radius,
			-half_depth,
			sin1 * radius
		)
		var outer_top0: Vector3 = Vector3(
			cos0 * radius,
			half_depth,
			sin0 * radius
		)
		var outer_top1: Vector3 = Vector3(
			cos1 * radius,
			half_depth,
			sin1 * radius
		)
		var inner_bottom0: Vector3 = Vector3(
			cos0 * inner_radius,
			-half_depth,
			sin0 * inner_radius
		)
		var inner_bottom1: Vector3 = Vector3(
			cos1 * inner_radius,
			-half_depth,
			sin1 * inner_radius
		)
		var inner_top0: Vector3 = Vector3(
			cos0 * inner_radius,
			half_depth,
			sin0 * inner_radius
		)
		var inner_top1: Vector3 = Vector3(
			cos1 * inner_radius,
			half_depth,
			sin1 * inner_radius
		)
		# Top surface.
		faces.append_array([
			outer_top0,
			outer_top1,
			inner_top1,
			outer_top0,
			inner_top1,
			inner_top0,
		])
		# Bottom surface.
		faces.append_array([
			outer_bottom0,
			inner_bottom1,
			outer_bottom1,
			outer_bottom0,
			inner_bottom0,
			inner_bottom1,
		])
		# Outer wall.
		faces.append_array([
			outer_bottom0,
			outer_top1,
			outer_bottom1,
			outer_bottom0,
			outer_top0,
			outer_top1,
		])
		# Inner wall.
		faces.append_array([
			inner_bottom0,
			inner_bottom1,
			inner_top1,
			inner_bottom0,
			inner_top1,
			inner_top0,
		])
	var shape: ConcavePolygonShape3D = ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	collision_shape.shape = shape
	parent.add_child(collision_shape)
	collision_shape.global_position.y = -pillar_depth / 2.0
