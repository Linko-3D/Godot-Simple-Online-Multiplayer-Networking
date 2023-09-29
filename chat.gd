extends Node

func _on_say_button_pressed():
	send_message.rpc(%InputText.text)
	%InputText.text = ""
	

@rpc("call_local", "any_peer")
func send_message(message):
	var label = Label.new()
	label.text = message
	%DisplayedMessages.add_child(label)
