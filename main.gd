extends Node

@export var player : PackedScene
@export var map : PackedScene

# Port mapping for online multiplayer
func _ready():
	var upnp = UPNP.new()
	upnp.discover()
	var result = upnp.add_port_mapping(9999)
	%DisplayPublicIP.text = " " + upnp.query_external_address()

# Server
func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)

	load_game()

# Client
func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(%To.text, 9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(load_game)
	multiplayer.server_disconnected.connect(server_offline)

func load_game():
	%Menu.hide()
	%MapInstance.add_child(map.instantiate())
	add_player.rpc_id(1, multiplayer.get_unique_id())

@rpc("any_peer") # Add "call_local" to spawn a player from the server
func add_player(id):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	%SpawnPosition.add_child(player_instance)

@rpc("any_peer")
func remove_player(id):
	if %SpawnPosition.get_node(str(id)):
		%SpawnPosition.get_node(str(id)).queue_free()

func server_offline():
	%Menu.show()
	if %MapInstance.get_child(0):
		%MapInstance.get_child(0).queue_free()
