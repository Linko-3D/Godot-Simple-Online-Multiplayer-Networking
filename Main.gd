extends Node

@export var player : PackedScene
@export var map : PackedScene
@export var SpawnPosition : NodePath

var PORT = 9999

# Port mapping for online multiplayer
func _ready():
	%Lobby.hide()
	
	var upnp = UPNP.new()
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

	multiplayer.peer_disconnected.connect(remove_player)

	load_game()

func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(%To.text, PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(load_game)
	multiplayer.server_disconnected.connect(server_offline)

func load_game():
	%Menu.hide()
	if not multiplayer.is_server():
		%Lobby.show()

@rpc("any_peer")
func add_player(id):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	%SpawnPosition.add_child(player_instance)

func remove_player(id):
	%SpawnPosition.get_node_or_null(str(id)).queue_free()

func server_offline():
	%Menu.show()

func _on_to_text_submitted(new_text):
	_on_join_button_pressed()

func _on_enter_game_button_pressed():
	add_player.rpc_id(1, multiplayer.get_unique_id())
	%Lobby.hide()
