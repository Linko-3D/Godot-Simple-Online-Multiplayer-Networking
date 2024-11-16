extends Camera3D


var speed = 5.5 * 2


func _ready() -> void:
	position = get_tree().get_nodes_in_group("spawn_point")[0].position


func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x / 2000)

		rotate_x(-event.relative.y / 2000)
		rotation.x = clamp( rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		rotation.z = 0


func _process(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return

	if Input.is_action_pressed("walk"):
		speed = 5.5 * 5
	else:
		speed = 5.5 * 2

	var direction = Vector3()
	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("right"):
		direction += transform.basis.x

	direction = direction.normalized()
	
	position += direction * speed * delta
