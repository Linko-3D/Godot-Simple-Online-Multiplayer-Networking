extends CharacterBody3D


var speed = 5.5 * 4


func _ready() -> void:
	position = get_tree().get_nodes_in_group("spawn_point")[0].position


func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x / 2000)

		%Camera3D.rotate_x(-event.relative.y / 2000)
		%Camera3D.rotation.x = clamp( %Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90) )


func _process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	velocity.y = Input.get_axis("down", "up") * speed

	move_and_slide()
