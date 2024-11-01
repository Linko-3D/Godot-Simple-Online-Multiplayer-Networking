extends CharacterBody3D


var speed = 5.5
var jump_velocity = 7


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

	%Camera3D.current = is_multiplayer_authority()
	%Crosshair.visible = is_multiplayer_authority()


func _input(event):
	if not is_multiplayer_authority(): return

	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x / 2000)

		%Camera3D.rotate_x(-event.relative.y / 2000)
		%Camera3D.rotation.x = clamp( %Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90) )


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity

		$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.85, 0.1)

		if Input.is_action_pressed("crouch"):
			speed = 1.8
			$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.38, 0.1)
		elif Input.is_action_pressed("walk"):
			speed = 3
		else:
			speed = 5.5

		$MeshInstance3D.mesh.height = $CollisionShape3D.shape.height
		crouch.rpc($CollisionShape3D.shape.height)

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		velocity.x = 0
		velocity.z = 0

	%Line1.position.y = lerp(%Line1.position.y, -velocity.length() * 22.9, 20 * delta)
	%Line1.position.y = clamp(%Line1.position.y, -126, 0)

	%Line2.position.x = lerp(%Line2.position.x, velocity.length() * 22.9, 20 * delta)
	%Line2.position.x = clamp(%Line2.position.x, 0, 126)

	%Line3.position.y = lerp(%Line3.position.y, velocity.length() * 22.9, 20 * delta)
	%Line3.position.y = clamp(%Line3.position.y, 0, 126)

	%Line4.position.x = lerp(%Line4.position.x, -velocity.length() * 22.9, 20 * delta)
	%Line4.position.x = clamp(%Line4.position.x, -126, 0)

	move_and_slide()

	if Input.is_action_just_pressed("flashlight"):
		%Flashlight.visible = !%Flashlight.visible

	flashlight.rpc(%Flashlight.visible)


@rpc("any_peer")
func crouch(value):
	$CollisionShape3D.shape.height = value
	$MeshInstance3D.mesh.height = value


@rpc("any_peer")
func flashlight(state):
	%Flashlight.visible = state
