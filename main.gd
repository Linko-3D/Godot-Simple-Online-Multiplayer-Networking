extends Node

@export var player : PackedScene
@export var map : PackedScene

# Set up port mapping for online multiplayer functionality
func _ready():
	%Lobby.hide()
	%DisplayPublicIP.hide()

	var upnp = UPNP.new()
	upnp.discover()
	upnp.add_port_mapping(9999)
	%DisplayPublicIP.text = "Server IP: " + upnp.query_external_address()
	
func _input(event: InputEvent):
	if Input.is_action_just_pressed("ui_cancel"):
		if not multiplayer.is_server():
			%Lobby.show()

# Dedicated server (it does not spawn a player)
func _on_host_button_pressed():
	%DisplayPublicIP.show()
	
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
	multiplayer.server_disconnected.connect(server_offline) # Will go back to the main menu

func load_game():
	%Menu.hide()
	%MapInstance.add_child(map.instantiate())

	if not multiplayer.is_server():
		%Lobby.show()

func _on_enter_button_pressed():
	%Lobby.hide()
	if not multiplayer.is_server():
		add_player.rpc_id(1, multiplayer.get_unique_id())

func _on_spectate_button_pressed():
	%Lobby.hide()
	remove_player.rpc_id(1, multiplayer.get_unique_id())

func _on_quit_button_pressed():
	get_tree().quit()

@rpc("any_peer") # Add "call_local" if you also want to spawn a player from the server
func add_player(id):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	%SpawnPosition.add_child(player_instance)

@rpc("any_peer")
func despawn_player(id):
	if %SpawnPosition.get_node(str(id)):
		%SpawnPosition.get_node(str(id)).queue_free()
		
@rpc("any_peer")
func remove_player(id):
	if %SpawnPosition.get_node(str(id)):
		%SpawnPosition.get_node(str(id)).queue_free()

func server_offline():
	%Menu.show()
	%Lobby.hide()
	if %MapInstance.get_child(0):
		%MapInstance.get_child(0).queue_free()
