extends Node3D

func _ready() -> void:
	position = get_tree().get_nodes_in_group("spawn_point")[0].position


func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x / 2000)

		%Camera3D.rotate_x(-event.relative.y / 2000)
		%Camera3D.rotation.x = clamp( %Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
