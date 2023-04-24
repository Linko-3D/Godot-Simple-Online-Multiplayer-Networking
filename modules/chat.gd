extends Control

var enter_key_pressed = false

func _ready():
	%SendMessage.hide()
	%ChatBox.hide()
	%SendMessage.position.y = get_viewport().size.y - (get_viewport().size.y / 6)

func _input(event):
	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER):
		if not enter_key_pressed:
			enter_key_pressed = true
			%SendMessage.visible = !%SendMessage.visible
			if not %SendMessage.visible:
				if not %TypedMessage.text == "":
					send_message.rpc(%TypedMessage.text)
				%TypedMessage.text = ""
				%ChatBoxDisapearsTimer.start()
			else:
				%ChatBox.show()
				%ChatBoxDisapearsTimer.stop()
	else:
		enter_key_pressed = false
	
	if Input.is_action_just_pressed("ui_cancel"):
		%SendMessage.hide()
		%TypedMessage.text = ""
		%ChatBoxDisapearsTimer.start()

@rpc("call_local", "any_peer")
func send_message(message):
	%ChatBox.show()
	var label_message = Label.new()
	label_message.text = " " + message
	%DisplayedMessage.add_child(label_message)

	if %DisplayedMessage.get_child_count() > 7:
		%DisplayedMessage.get_child(0).queue_free()

	%ChatBoxDisapearsTimer.start()

func _on_chat_box_disapears_timer_timeout():
	%ChatBox.hide()
