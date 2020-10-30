extends Control

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		$Message.visible = !$Message.visible
		if not $Message.visible:
			$Message/TypedMessage.clear()
