extends Control

var max_messages = 5

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if $Message.visible:
			if $Message/TypedMessage.text != "":
				rpc("message", NETWORK.player_name, $Message/TypedMessage.text)
			$Message.visible = false
			$Message/TypedMessage.clear()
		else:
			$Message.visible = true
		if $ChatBox.get_child_count() > max_messages:
			$ChatBox.get_child(0).queue_free()

remotesync func message(player_name, data):
	var display_message = Label.new()
	$ChatBox.add_child(display_message)
	display_message.text = player_name + ": " + data
