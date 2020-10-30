# Singleton

extends Node

var lobby = preload("res://Lobby.tscn").instance()
var map = preload("res://Map.tscn").instance()
var servermenu = preload("res://Modules/ServerMenu.tscn").instance()
var chatmenu = preload("res://Modules/Chat.tscn").instance()

var player_name = "Server"

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(4242, 32)
	get_tree().set_network_peer(peer)

	load_game()

func join_server(ip, get_name):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, 4242)
	get_tree().set_network_peer(peer)
	player_name = get_name

	# If server found, sends the signal "_on_connected_to_server" to load the game

func load_game():
	get_tree().get_root().add_child(map)
	get_tree().get_root().get_node("Lobby").queue_free()

	if not get_tree().is_network_server(): #If not the server spawn a player, otherwise display the server menu
		spawn_player(get_tree().get_network_unique_id())
	else:
		get_tree().get_root().add_child(servermenu)
	
	get_tree().get_root().add_child(chatmenu)

func spawn_player(id):
	var player = load("res://Player.tscn").instance()
	var spawn = get_tree().get_root().find_node("Spawn", true, false)
	spawn.add_child(player)
	player.name = str(id)
	player.set_network_master(id)

func _on_network_peer_connected(id):
	if id != 1: # 1 is the server, we don't want to spawn a player from it
		spawn_player(id)

func _on_network_peer_disconnected(id):
	if id != 1:
		get_tree().get_root().find_node(str(id), true, false).queue_free()

func _on_connected_to_server():
	load_game()

func _on_server_disconnected():
	get_tree().get_root().add_child(lobby)
	get_tree().get_root().get_node("Map").queue_free()
	get_tree().set_network_peer(null)
