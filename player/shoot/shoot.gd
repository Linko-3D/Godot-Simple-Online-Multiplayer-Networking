extends Node3D

@export var impact : PackedScene

var has_authority = false

var weapon_sway_amount = 5
var mouse_relative_x = 0
var mouse_relative_y = 0

func _input(event):
	if not has_authority: return

#	Getting the mouse movement for the weapon sway in the physics process
	if event is InputEventMouseMotion:
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_authority: return

	%Sway.rotation_degrees.z = lerp(%Sway.rotation_degrees.z, -mouse_relative_x / 10.0, weapon_sway_amount * delta)
	%Sway.rotation_degrees.y = lerp(%Sway.rotation_degrees.y, -mouse_relative_x / 20.0, weapon_sway_amount * delta)
	%Sway.rotation_degrees.x = lerp(%Sway.rotation_degrees.x, -mouse_relative_y / 10.0, weapon_sway_amount * delta)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.5:
		if %FireRateTimer.is_stopped():
			shoot.rpc()
			%FireRateTimer.start()
			

@rpc("call_local")
func shoot():
	if not %RayCast3D.is_colliding(): return
	var a = impact.instantiate()
	get_tree().get_root().add_child(a)
	a.position = %RayCast3D.get_collision_point()
	#%MapInstance.add_child(map.instantiate())
	
	#var impact_instance = impact.instance()
	#get_tree().get_root().add_child(impact_instance)
