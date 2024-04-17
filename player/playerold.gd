extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	set_multiplayer_authority(name.to_int())
	%Camera3D.current = is_multiplayer_authority()
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($CSGSphere3D, "scale", Vector3.ZERO, 0)
	tween.tween_property($CSGSphere3D, "scale", Vector3.ONE, 0.5)


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_DRAG)
		
	
	%DisplayUsername.text = GLOBAL.username

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
