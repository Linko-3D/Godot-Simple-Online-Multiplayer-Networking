extends Node

const SERVER_PORT = 9000

var player = preload("res://player.tscn")
var map = preload("res://map.tscn")

var enter_key_pressed = false

func _process(delta):
	display_players_connected(%LobbyConnectedPlayers)

func _ready():
	$Control/Menu.show()
	%SendMessage.position.y = get_viewport().size.y - (get_viewport().size.y / 6)
	%ChatBox.position.y = get_viewport().size.y - (get_viewport().size.y / 3) - 15
	%SendMessage.hide()
	%ChatBox.hide()
	%Scoreboard.hide()
	$Control/Lobby.hide()
	$Control/QuitConfirmation.hide()

# Hold the Tab key to display connected players and press Enter to send a message

func _input(event):
	if %Menu.visible: return # If the starting menu is not visible it means we are in the game

	if Input.is_key_pressed(KEY_TAB):
		display_players_connected(%PlayersConnectedList)
		%Scoreboard.show()
	else:
		%Scoreboard.hide()

	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER):
		if not enter_key_pressed:
			enter_key_pressed = true
			%SendMessage.visible = !%SendMessage.visible

			if not %SendMessage.visible:
				if %MessageInput.text != "":
					send_message.rpc(%Username.text, %MessageInput.text, multiplayer.is_server())
					%MessageInput.text = ""
				%ChatBoxDisappearsTimer.start()
			else:
				%ChatBox.show()
				%ChatBoxDisappearsTimer.stop()
	else:
		enter_key_pressed = false

	if Input.is_action_just_pressed("ui_cancel"):
		%SendMessage.hide()
		%MessageInput.text = ""
		%ChatBoxDisappearsTimer.start()

# Function to send a message

@rpc("call_local", "any_peer")
func send_message(player_name, message, is_server):
	var HBox = HBoxContainer.new()

	%DisplayedMessage.add_child(HBox)

	# Display the name of the player sending the message in red
	var label_player_name = Label.new()
	if is_server:
		player_name = "ADMIN"
	label_player_name.text = player_name
	label_player_name.modulate = Color.RED

	# Send the message
	var label_message = Label.new()
	label_message.text = ": " + message

	HBox.add_child(label_player_name)
	HBox.add_child(label_message)

	# Remove the oldest message received if there are more than 7 displayed
	if %DisplayedMessage.get_child_count() > 7:
		%DisplayedMessage.get_child(0). queue_free()

	%ChatBox.show()
	%ChatBoxDisappearsTimer.start()

# Function to display players connected, it refreshes each time it is called

func display_players_connected(node):
	# Clear the previous list
	for label in node.get_children():
		label.queue_free()

	# Create the list of connected players
	for peer in %SpawnPosition.get_children():
		var HBox = HBoxContainer.new()
		node.add_child(HBox)

		if multiplayer.is_server():
			var button = Button.new()
			button.text = "KICK"
			HBox.add_child(button)

		var player = Label.new()
		player.text = str(peer.name)
		HBox.add_child(player)

# Networking system

# Server

func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)

	load_game()

# Client

func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", SERVER_PORT)
	multiplayer.multiplayer_peer = peer

	if %Username.text == "":
		%Username.text = "Player"

	multiplayer.server_disconnected.connect(server_offline)

	load_game()

@rpc("any_peer")
func add_player(id, displayed_name):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	%SpawnPosition.add_child(player_instance)

	send_message.rpc(str(id), " has joined the game", false)

func load_game():
	%Menu.hide()
	var map_instance = map.instantiate()
	%MapInstance.add_child(map_instance)
	
	$Control/Lobby.visible = !multiplayer.is_server()

func remove_player(id):
	var player = %SpawnPosition.get_node_or_null(str(id))
	if player != null:
		player.queue_free()

		send_message.rpc(str(id), " left the game", false)

func server_offline():
	quit_game()

func _on_username_text_submitted(new_text):
	_on_join_button_pressed()

func _on_chat_box_disappears_timer_timeout():
	%ChatBox.hide()

func _on_quit_button_button_down():
	$Control/QuitConfirmation.show()

func _on_yes_button_pressed():
	get_tree().quit()

func _on_no_button_pressed():
	$Control/QuitConfirmation.hide()

func quit_game():
	multiplayer.multiplayer_peer = null
	%Lobby.hide()
	%Menu.show()
	%ChatBox.hide()
	%SendMessage.hide()
	%MessageInput.text = ""
	%MapInstance.get_child(0).queue_free()

func _on_enter_game_button_pressed():
	add_player.rpc_id(1, multiplayer.get_unique_id(), %Username.text)
	$Control/Lobby.hide()

func _on_disconnect_button_pressed():
	quit_game()
