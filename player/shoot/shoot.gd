extends Node3D

@export var impact : PackedScene

@export var rifle_shoot_sound : Resource

#export (Resource) var rifle_model
#export (Resource) var pistol_model
#export (Resource) var knife_model
#
#export (PackedScene) var impact
#export (PackedScene) var shell
#export (PackedScene) var magazine
#
#export (Resource) var rifle_shoot_sound
#export (Resource) var pistol_shoot_sound
#export (Resource) var reload_sound
#export (Resource) var empty_sound

var has_authority = false

var weapon_sway_amount = 5
var mouse_relative_x = 0.0
var mouse_relative_y = 0.0

var reload_tween

func _input(event):
	if not has_authority: return

#	Getting the mouse movement for the weapon sway in the physics process
	if event is InputEventMouseMotion:
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_authority: return

	#%Sway.rotation_degrees.z = lerp(%Sway.rotation_degrees.z, -mouse_relative_x / 10.0, weapon_sway_amount * delta)
	#%Sway.rotation_degrees.y = lerp(%Sway.rotation_degrees.y, -mouse_relative_x / 20.0, weapon_sway_amount * delta)
	#%Sway.rotation_degrees.x = lerp(%Sway.rotation_degrees.x, -mouse_relative_y / 10.0, weapon_sway_amount * delta)

	%Sway.position.x = lerp(%Sway.position.x, -mouse_relative_x / 15000.0, 20 * delta)
	%Sway.position.y = lerp(%Sway.position.y, mouse_relative_y / 20000.0, 20 * delta)


	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.5:
		if %FireRateTimer.is_stopped():
			shoot.rpc()
			%FireRateTimer.start()

	if Input.is_key_pressed(KEY_R) or Input.is_joy_button_pressed(0, JOY_BUTTON_Y):
		if reload_tween:
			return
			
		reload_tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		reload_tween.tween_property(%Reload, "rotation_degrees:x", 0, 0)
		reload_tween.tween_property(%Reload, "rotation_degrees:x", 360, 1)
		reload_tween = null

@rpc("call_local")
func shoot():
	shoot_animation()
	play_sound(rifle_shoot_sound)
	
	if not %RayCast3D.is_colliding(): return
	var impact_instance = impact.instantiate()
	get_tree().get_root().add_child(impact_instance)
	impact_instance.position = %RayCast3D.get_collision_point()
	impact_instance.look_at(%RayCast3D.get_collision_point() - %RayCast3D.get_collision_normal(), Vector3.UP)

#impact_instance.global_transform.origin = $BulletSpread/RayCast.get_collision_point()
#impact_instance.look_at($BulletSpread/RayCast.get_collision_point() - $BulletSpread/RayCast.get_collision_normal(), Vector3.UP)
	

func play_sound(sound):
	var audio_node = AudioStreamPlayer.new()
	get_tree().get_root().add_child(audio_node)
	audio_node.stream = rifle_shoot_sound
	audio_node.pitch_scale = randf_range(0.95, 1.05)
	audio_node.play()

func shoot_animation():
	var muzzle_flash_tween = get_tree().create_tween()
	muzzle_flash_tween.tween_property(%MuzzleFlash, "light_energy", randf_range(0.8, 1), 0)
	muzzle_flash_tween.tween_property(%MuzzleFlash, "light_energy", 0, 0.02)
	
	var weapon_animation_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	weapon_animation_tween.tween_property(%Weapon, "position:z", randf_range(0.035, 0.045), 0.1)
	weapon_animation_tween.tween_property(%Weapon, "position:z", 0, 0.15)
	

#func shoot_animation():
	#randomize()
	#var value = rand_range(0.8, 1)
	#$ShootTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight, "light_energy", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	#$ShootTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight, "light_energy", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	#
	#value = rand_range(0.035, 0.045)
	#$ShootTween.interpolate_property(weapon, "translation:z", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	#$ShootTween.interpolate_property(weapon, "translation:z", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	#
	#value = rand_range(-0.005, 0.005)
	#$ShootTween.interpolate_property(weapon, "translation:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	#$ShootTween.interpolate_property(weapon, "translation:x",value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	#
	#value = rand_range(0.005, 0.015)
	#$ShootTween.interpolate_property(weapon, "translation:y", 0, value, 0.075, Tween.TRANS_SINE, Tween.EASE_OUT)
	#$ShootTween.interpolate_property(weapon, "translation:y", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.075)
	#
	#value = rand_range(-1.5, -0.5)
	#$ShootTween.interpolate_property(weapon, "rotation_degrees:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	#$ShootTween.interpolate_property(weapon, "rotation_degrees:x", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	#
	#value = rand_range(-1, 1)
	#$ShootTween.interpolate_property(weapon, "rotation_degrees:z", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	#$ShootTween.interpolate_property(weapon, "rotation_degrees:z", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	#$ShootTween.interpolate_property(weapon, "rotation_degrees:z", 0, -value, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	#$ShootTween.interpolate_property(weapon, "rotation_degrees:z", -value, 0, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.175)
	#
	#value = rand_range(0.5, 1.5)
	#$ShootTween.interpolate_property(camera, "rotation_degrees:x", 0, 1, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	#$ShootTween.interpolate_property(camera, "rotation_degrees:x", 1, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	#value = rand_range(-1, 1)
	#$ShootTween.interpolate_property(camera, "rotation_degrees:y", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	#$ShootTween.interpolate_property(camera, "rotation_degrees:y", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	#$ShootTween.start()
