extends Control

func _on_Host_pressed():
	NETWORK.create_server()

func _on_Join_pressed():
	NETWORK.join_server()
