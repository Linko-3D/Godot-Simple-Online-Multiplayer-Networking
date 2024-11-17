extends Camera3D


var speed = 5.5 * 2

var mouse_sensitivity = Vector2(0.2, 0.2)

var rotation_x = 0.0
var rotation_y = 0.0


func _ready() -> void:
	position = get_tree().get_nodes_in_group("spawn_point")[0].position


func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return

	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * mouse_sensitivity.x
		rotation_x -= event.relative.y * mouse_sensitivity.y
		rotation_x = clamp(rotation_x, -90, 90)

		rotation_degrees = Vector3(rotation_x, rotation_y, 0)

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
