extends CharacterBody3D

var speed = 5.3
const jump_velocity = 7.5
var crouch_height

var has_landed = false
var landing_velocity

var jump_key_pressed = false

# For footstep sounds
var distance_walked = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

func _ready():
	set_multiplayer_authority(name.to_int())
	%Camera3D.current = is_multiplayer_authority()
	%Crosshair.visible = is_multiplayer_authority()
	%AudioListener3D.current = is_multiplayer_authority()
	$LandingAnimation/Camera3D/Flashlight.has_authority = is_multiplayer_authority()
	$LandingAnimation/Camera3D/Shoot.has_authority = is_multiplayer_authority()

func _input(event):
	if not is_multiplayer_authority(): return

	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x / 2000)

		%Camera3D.rotate_x(-event.relative.y / 2000)
		%Camera3D.rotation.x = clamp( %Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90) )

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	%Username.text = GLOBAL.username
	
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		has_landed = false
		landing_velocity = -velocity.y
	else:
		if not has_landed:
			print("Landing velocity: ", landing_velocity)
			
			if landing_velocity > 0:
				#$LandSound.volume_db = clamp(-20 + landing_velocity * 1.5, -25, -5)
				$LandSound.play()
				$LandSound.pitch_scale = randf_range(0.9, 1.1)
			else:
				$FootstepSound.volume_db = -35 + (get_real_velocity().length() * 3)
				$FootstepSound.pitch_scale = randf_range(0.9, 1.1)
				$FootstepSound.play()
			
			var amplitude = clamp(0.8 - landing_velocity / 100, 0.0, 0.8)
			var duration = (1 - amplitude) / 3
			var tween = create_tween().set_trans(Tween.TRANS_SINE)
			
			tween.tween_property(%LandingAnimation, "position:y", 0.7, 0.15).set_ease(Tween.EASE_OUT)
			tween.tween_property(%LandingAnimation, "position:y", 0.8, 0.22-0.15)
			
			has_landed = true

	if is_on_floor():
		if Input.is_key_pressed(KEY_SPACE):
			if not jump_key_pressed:
				velocity.y = jump_velocity
				jump_key_pressed = true
		else:
			jump_key_pressed = false


	if is_on_floor():
		distance_walked += get_real_velocity().length() * delta
	else:
		distance_walked = 0
	
	if distance_walked >= 65.0/30.0:
		#$FootstepSound.volume_db = -35 + (get_real_velocity().length() * 3)
		$FootstepSound.pitch_scale = randf_range(0.9, 1.1)
		$FootstepSound.play()
		distance_walked = 0

	if Input.is_key_pressed(KEY_SHIFT):
		speed = 2.8
	else:
		speed = 5.3

	if Input.is_key_pressed(KEY_CTRL):
		$CollisionShape3d.shape.height
		crouch_height = 1.7 / 2
		speed = 1.8
	else:
		crouch_height = 1.7

	$CollisionShape3d.shape.height = lerp($CollisionShape3d.shape.height, crouch_height, delta * 10)

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
