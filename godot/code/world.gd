extends Node3D
class_name MyWorld

@onready var hole: MyHole = %hole
@onready var cam: MyCamera = %cam
@onready var ground: MyGround = %ground

func _input(event: InputEvent) -> void:
	if event.is_action('ui_cancel'):
		get_tree().quit()

func _ready() -> void:
	cam.target = hole
	ground.target = hole
	hole.grows_in_radius.connect(ground.update_radius)
