extends SpotLight3D

var has_authority = false
var can_use = true

func _ready():
	hide()

func _input(event):
	if not has_authority: return
	
	if Input.is_key_pressed(KEY_F):
		if can_use:
			visible = !visible
			$FlashlightToggleSound.pitch_scale = randf_range(0.95, 1.05)
			$FlashlightToggleSound.play()
			can_use = false
	else:
		can_use = true
