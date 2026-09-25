extends Camera3D
class_name MyCamera

@export var target: Node3D:
	set(value):
		target = value
		offset = global_position - target.global_position

@export var offset: Vector3 = Vector3(0, 2, 5)

func _process(delta):
	#if target:
		#global_position = target.global_position + offset
		#look_at(target.global_position)
	var input_direction: Vector3 = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		input_direction -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		input_direction += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		input_direction -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		input_direction += transform.basis.x
	if Input.is_key_pressed(KEY_Q):
		input_direction -= transform.basis.y
	if Input.is_key_pressed(KEY_E):
		input_direction += transform.basis.y
	if input_direction != Vector3.ZERO:
		input_direction = input_direction.normalized()
	var speed: float = MOVEMENT_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= SPRINT_MULTIPLIER
	global_position += input_direction * speed * delta


const MOVEMENT_SPEED: float = 10.0
const SPRINT_MULTIPLIER: float = 5.0
const MOUSE_SENSITIVITY: float = 0.002

var yaw: float = 0.0
var pitch: float = 0.0

func _ready() -> void:
	yaw = rotation.y
	pitch = rotation.x
	initial_perspective = _get_current_perspective()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, deg_to_rad(-89.0), deg_to_rad(89.0))
		rotation = Vector3(pitch, yaw, 0.0)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.ctrl_pressed:
			match event.keycode:
				KEY_1:
					_save_perspective_to_buffer(1)
				KEY_2:
					_save_perspective_to_buffer(2)
				KEY_3:
					_save_perspective_to_buffer(3)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_reset_perspective_to_buffer(1)
			KEY_2:
				_reset_perspective_to_buffer(2)
			KEY_3:
				_reset_perspective_to_buffer(3)

enum PERSPECTIVE_INFO {YAW, PIT, POS, ROT}

var initial_perspective: Dictionary = {}
var saved_perspectives: Dictionary = {}

func _on_reset_perspective_button_pressed() -> void:
	_set_perspective(initial_perspective)

func _save_perspective_to_buffer(buffer_id : int) -> void:
	var perspective: Dictionary = _get_current_perspective()
	saved_perspectives[buffer_id] = perspective

func _reset_perspective_to_buffer(buffer_id : int) -> void:
	if not saved_perspectives.has(buffer_id):
		return
	var perspective: Dictionary = saved_perspectives[buffer_id]
	_set_perspective(perspective)

func _set_perspective(perspective : Dictionary) -> void:
	yaw = perspective[PERSPECTIVE_INFO.YAW]
	pitch = perspective[PERSPECTIVE_INFO.PIT]
	global_position = perspective[PERSPECTIVE_INFO.POS]
	rotation = perspective[PERSPECTIVE_INFO.ROT]

func _get_current_perspective() -> Dictionary:
	return {
		PERSPECTIVE_INFO.YAW: yaw,
		PERSPECTIVE_INFO.PIT: pitch,
		PERSPECTIVE_INFO.POS: global_position,
		PERSPECTIVE_INFO.ROT: rotation
	}
