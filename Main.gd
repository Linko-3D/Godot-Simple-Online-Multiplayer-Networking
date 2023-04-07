extends Node

var player = preload("res://player.tscn")
var map = preload("res://map.tscn")

var PORT = 9999
var upnp = UPNP.new()

# Create port mapping to allow online multiplayer with public IP
func _ready():
	upnp.discover()
	var result = upnp.add_port_mapping(PORT)
	if result == OK:
		print("Port mapping successfully added. Public IP: " + upnp.query_external_address())
	else:
		print("Failed to add port mapping. Error:", result)
	%DisplayPublicIP.text = upnp.query_external_address()

# Server
func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	load_game()

# Client
func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(%To.text, PORT)
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
	
	var result = upnp.delete_port_mapping(PORT, "UDP")
	if result == OK:
		print("Port mapping successfully removed.")
	else:
		print("Failed to remove port mapping. Error:", result)
