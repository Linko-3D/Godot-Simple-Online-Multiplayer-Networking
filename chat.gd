extends Node

func _on_say_button_pressed():
	send_message.rpc(%InputText.text, str(multiplayer.get_unique_id()))
	%InputText.text = ""

@rpc("call_local", "any_peer")
func send_message(message, playerName):
	var label = Label.new()
	label.text = playerName + ": " + message
	%DisplayedMessages.add_child(label)

func _on_input_text_text_submitted(new_text):
	_on_say_button_pressed()
