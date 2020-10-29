extends Control

var previous_size = 0

func _process(delta):
	if previous_size != NETWORK.player_list.size():
		for child in $ConnectedList.get_children():
			child.queue_free()
		for x in NETWORK.player_list:
			display_player(x)
		previous_size = NETWORK.player_list.size()

	print(NETWORK.player_list.size())

func display_player(x):
	var player_connected = Label.new()
	player_connected.text = "- " + x
	$ConnectedList.add_child(player_connected)
