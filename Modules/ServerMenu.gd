extends Control

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")

func _on_network_peer_connected(id):
	update()

func _on_network_peer_disconnected(id):
	update()

func update():
	yield(get_tree(), "idle_frame")
	
	var spawn_node = get_tree().get_root().find_node("Spawn", true, false)

	for child in $ConnectedList.get_children():
		child.queue_free()

	for child in spawn_node.get_children():
		display_player(child.player_name)

func display_player(player_name):
	var HBox = HBoxContainer.new()
	$ConnectedList.add_child(HBox)

	var button = Button.new()
	button.text = "Kick"
	HBox.add_child(button)

	var player_connected = Label.new()
	player_connected.text = "- " + player_name
	HBox.add_child(player_connected)
