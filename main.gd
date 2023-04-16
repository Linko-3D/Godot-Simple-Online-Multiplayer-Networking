extends Node

@export var player : PackedScene
@export var map : PackedScene

var PORT = 9999
var spawned = false

# Port mapping for online multiplayer
func _ready():
	%Menu.show()
	%Lobby.hide()
	
	var upnp = UPNP.new()
	upnp.discover()
	var result = upnp.add_port_mapping(PORT)
	if result == OK:
		print("Port mapping successfully added. Public IP: " + upnp.query_external_address())
	else:
		print("Failed to add port mapping. Error:", result)
	%DisplayPublicIP.text = " " + upnp.query_external_address()

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if not %Menu.visible and spawned:
			%Lobby.visible = !%Lobby.visible


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
	%MapInstance.add_child(map.instantiate())
	if not multiplayer.is_server():
		%Lobby.show()

func _on_enter_game_button_pressed(): # Lobby button
	add_player.rpc_id(1, multiplayer.get_unique_id())
	spawned = true
	%Lobby.hide()

@rpc("any_peer")
func add_player(id):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	%SpawnPosition.add_child(player_instance)

@rpc("any_peer")
func remove_player(id):
	if %SpawnPosition.get_node(str(id)): # If the player is in the scene removes it
		%SpawnPosition.get_node(str(id)).queue_free()

func server_offline():
	%Menu.show()

func _on_to_text_submitted(new_text):
	_on_join_button_pressed()

func _on_disconnect_button_pressed():
	remove_player.rpc_id(1, multiplayer.get_unique_id())
	%MapInstance.get_child(0).queue_free()
	spawned = false
	%Lobby.hide()
	%Menu.show()

func _on_quit_button_pressed():
	get_tree().quit()
