extends Node

@export var player : PackedScene
@export var map : PackedScene

var upnp = UPNP.new()

var banned_ips = []

func _process(delta):
	%NumberConnected.text = str(multiplayer.get_peers().size())

func _ready():
	%Lobby.hide()
	%Admin.hide()
	upnp_setup()

# Server
func _on_host_button_pressed():
	%Admin.show()

	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)

	load_game()

#  Client - Call this in the `ready()` function and set the public IP address of your server for automatic joining
func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(%To.text, 9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(load_game) # Loads only if connected to a server
	multiplayer.server_disconnected.connect(server_offline)

func load_game():
	%Chat.show()
	%Menu.hide()
	print()
	%MapInstance.add_child(map.instantiate())

	if not multiplayer.is_server():
		%Lobby.show()

func _on_enter_button_pressed():
	%Lobby.hide()
	if not multiplayer.is_server():
		add_player.rpc_id(1, multiplayer.get_unique_id(), upnp.query_external_address())

@rpc("any_peer") # Add "call_local" if you also want to spawn a player from the server
func add_player(id, ip):
	var player_ip = ip
	
	if player_ip in banned_ips:
		print("Connection from " + player_ip + " rejected (banned).")
		return
		
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	%SpawnPosition.add_child(player_instance)

func remove_player(id):
	if %SpawnPosition.get_node(str(id)):
		%SpawnPosition.get_node(str(id)).queue_free()

func server_offline():
	%Menu.show()
	%Chat.hide()
	if %MapInstance.get_child(0):
		%MapInstance.get_child(0).queue_free()

# Set up port mapping for online multiplayer functionality
func upnp_setup():
	upnp.discover()
	upnp.add_port_mapping(9999)
	%DisplayPublicIP.text = "Server IP: " + upnp.query_external_address()

func _on_quit_button_pressed():
	get_tree().quit()
