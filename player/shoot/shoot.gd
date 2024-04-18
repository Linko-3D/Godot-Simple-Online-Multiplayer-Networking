extends Node3D

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
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_authority: return

	print(mouse_relative_x)
	%Sway.rotation_degrees.z = lerp(%Sway.rotation_degrees.z, -mouse_relative_x / 10.0, weapon_sway_amount * delta)
	%Sway.rotation_degrees.y = lerp(%Sway.rotation_degrees.y, -mouse_relative_x / 20.0, weapon_sway_amount * delta)
	%Sway.rotation_degrees.x = lerp(%Sway.rotation_degrees.x, -mouse_relative_y / 10.0, weapon_sway_amount * delta)


#	Weapon sway
	#$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.z = lerp($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.z, -mouse_relative_x / 10, weapon_sway_amount * delta)
	#$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.y = lerp($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.y, mouse_relative_x / 20, weapon_sway_amount * delta)
	#$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.x = lerp($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.x, -mouse_relative_y / 10, weapon_sway_amount * delta)
