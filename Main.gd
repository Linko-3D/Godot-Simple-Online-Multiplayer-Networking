extends Node

var player = preload("res://player.tscn")
var map = preload("res://map.tscn")

# Server

func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	load_game()

# Client

func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", 9999)
	multiplayer.multiplayer_peer = peer
		
	multiplayer.connected_to_server.connect(load_game)
	multiplayer.server_disconnected.connect(server_offline)

func add_player(id):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	%SpawnPosition.add_child(player_instance)

func load_game():
	if %Username.text == "":
		%Username.text = "Player"
	
	%Menu.hide()
	var map_instance = map.instantiate()
	%MapInstance.add_child(map_instance)

func remove_player(id):
	%SpawnPosition.get_node_or_null(str(id)).queue_free()

func server_offline():
	%Menu.show()
	%MapInstance.get_child(0).queue_free()

func _on_username_text_submitted(new_text):
	_on_join_button_pressed()

func _on_chat_box_disapears_timer_timeout():
	%ChatBox.hide()
