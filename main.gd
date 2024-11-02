extends Node


@export var player : PackedScene
@export var map : PackedScene

var spawned = false


func _ready() -> void:
	%Lobby.hide()
	%Server.hide()
	
	var upnp = UPNP.new()
	upnp.discover()
	upnp.add_port_mapping(9999)
	%PublicIP.text = upnp.query_external_address()


func _process(delta: float) -> void:
	if %Menu.visible or %Lobby.visible or multiplayer.is_server():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and not multiplayer.is_server():
		%Lobby.visible = !%Lobby.visible
		%EnterButton.visible = !spawned
		%ResumeButton.visible = spawned


func _on_host_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)

	%Server.show()

	load_game()


func _on_join_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(%To.text, 9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(load_game)
	multiplayer.server_disconnected.connect(connection_lost)


func _on_to_text_submitted(new_text: String) -> void:
	_on_join_button_pressed() 


func load_game():
	%Menu.hide()
	%MapInstance.add_child(map.instantiate())


	if not multiplayer.is_server():
		%Lobby.show()
	
	%EnterButton.visible = !spawned
	%ResumeButton.visible = spawned


func connection_lost():
	%Menu.show()

	if %MapInstance.get_child(0):
		%MapInstance.get_child(0).queue_free()


@rpc("any_peer")
func add_player(id):
	var player_instance = player.instantiate()
	player_instance.name = str(id)

	%Players.add_child(player_instance)


@rpc("any_peer")
func remove_player(id):
	if %Players.get_node(str(id)):
		%Players.get_node(str(id)).queue_free()


func _on_enter_button_pressed() -> void:
	add_player.rpc_id(1, multiplayer.get_unique_id())
	%Lobby.hide()
	spawned = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_resume_button_pressed() -> void:
	%Lobby.hide()


func _on_spectate_button_pressed() -> void:
	remove_player.rpc_id(1, multiplayer.get_unique_id())
	spawned = false
	%Lobby.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
