extends Node

var player = "res://Player.tscn"
var map = "res://Map.tscn"

func _ready():
		get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
		get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")

func create_server():
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(4242, 32)
		get_tree().set_network_peer(peer)

		load_game()

func join_server():
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client("127.0.0.1", 4242)
		get_tree().set_network_peer(peer)

		load_game()

func load_game():
		get_tree().change_scene(map)
		if not get_tree().is_network_server():
			yield(get_tree(), "idle_frame") # To have the time to load the Spawn node we wait one frame
			spawn_player(get_tree().get_network_unique_id())

func spawn_player(id):
		var player_instance = load(player).instance()
		var spawn = get_tree().get_root().find_node("Spawn", true, false)
		spawn.add_child(player_instance)
		player_instance.name = str(id)
		player_instance.set_network_master(id)

func _on_network_peer_connected(id):
	if id != 1: # 1 is the server, we don't want to spawn a player from it
		spawn_player(id)

func _on_network_peer_disconnected(id):
		get_tree().get_root().find_node(str(id), true, false).queue_free()

