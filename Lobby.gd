extends Control

func _ready():
	$Menu/ShowIP.text = "My IP: " + IP.get_local_addresses()[3]

func _on_Host_pressed():
	NETWORK.create_server()

func _on_Join_pressed():
	NETWORK.join_server($Menu/Connect/IP.text, $Menu/Name/NameSet.text)

func _text_entered(new_text):
	_on_Join_pressed()
