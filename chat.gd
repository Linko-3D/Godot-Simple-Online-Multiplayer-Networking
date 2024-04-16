extends CanvasLayer

var enter_key_pressed = false

func _ready():
	%InputBox.hide()
	%Messages.hide()

	%InputBox.position.y = (get_viewport().size.y / 4) * 3

func _input(event):
	if not visible:
		return

	if Input.is_key_pressed(KEY_ESCAPE):
		%InputBox.hide()
		%InputText.text = ""
		%Timer.start()
	
	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER):
		if not enter_key_pressed:
			%InputBox.visible = !%InputBox.visible
			%Timer.stop()

			if %InputBox.visible == false:
				_on_say_button_pressed()
			else:
				%Messages.show()

			enter_key_pressed = true
	else:
		enter_key_pressed = false

func _on_input_text_text_submitted(new_text):
	_on_say_button_pressed()

func _on_say_button_pressed():
	%InputBox.hide()
	%Timer.start()
	if %InputText.text != "":
		send_message.rpc(%InputText.text, GLOBAL.username)
		%InputText.text = ""

@rpc("call_local", "any_peer")
func send_message(message, username):
	var label = Label.new()
	label.text = username + ": " + message
	%DisplayedMessages.add_child(label)

	if %DisplayedMessages.get_child_count() > 7:
		%DisplayedMessages.get_child(0).queue_free()

	%Timer.start()
	%Messages.show()

func _on_timer_timeout():
	%Messages.hide()
