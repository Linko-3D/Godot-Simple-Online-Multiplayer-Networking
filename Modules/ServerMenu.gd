extends Control

func _process(delta):
	var spawn_node = get_tree().get_root().find_node("Spawn", true, false)
	
	for child in $ConnectedList.get_children():
		child.queue_free()

	for child in spawn_node.get_children():
		display_player(child.player_name)

func display_player(player_name):
	var player_connected = Label.new()
	player_connected.text = "- " + player_name
	$ConnectedList.add_child(player_connected)
