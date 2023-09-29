extends Node

func _on_say_button_pressed():
	send_message()

func send_message():
	var label = Label.new()
	var label_instance = label.instantiate()
	label.text = "a"
	%DisplayedMessage.add_child(label)
