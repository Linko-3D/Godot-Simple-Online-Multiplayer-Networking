extends Node

func _on_say_button_pressed():
	send_message()

func send_message():
	var label = Label.new()
	label.text = "a"
	print(label)
	%DisplayedMessage.add_child(label.instanciate())
