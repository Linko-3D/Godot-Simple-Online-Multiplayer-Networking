extends Node

var player = preload("res://player.tscn")
var map = preload("res://map.tscn")

var peer = ENetMultiplayerPeer.new()

var enter_key_pressed = false

func _ready():
	%SendMessage.position.y = get_viewport().size.y - (get_viewport().size.y / 6)
	%ChatBox.position.y = get_viewport().size.y - (get_viewport().size.y / 3) - 15
	%SendMessage.hide()
	%ChatBox.hide()
	%Scoreboard.hide()

# Hold the Tab key to display connected players and press Enter to send a message

func _input(event):
	if %Menu.visible: return # If the starting menu is not visible it means we are in the game

	if Input.is_key_pressed(KEY_TAB):
		display_players_connected()
		%Scoreboard.show()
	else:
		%Scoreboard.hide()

	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER):
		if not enter_key_pressed:
			enter_key_pressed = true
			%SendMessage.visible = !%SendMessage.visible

			if not %SendMessage.visible:
				if %TypedMessage.text != "":
					send_message.rpc(%Username.text, %TypedMessage.text, multiplayer.is_server())
					%TypedMessage.text = ""
				%ChatBoxDisapearsTimer.start()
			else:
				%ChatBox.show()
				%ChatBoxDisapearsTimer.stop()
	else:
		enter_key_pressed = false

	if Input.is_action_just_pressed("ui_cancel"):
		%SendMessage.hide()
		%TypedMessage.text = ""
		%ChatBoxDisapearsTimer.start()

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
	%ChatBoxDisapearsTimer.start()

# Function to display players connected, it refreshes each time it is called

func display_players_connected():
	# Clear the previous list
	for label in %PlayersConnectedList.get_children():
		label.queue_free()

	# Create the list of connected players
	for peer in %SpawnPosition.get_children():
		var HBox = HBoxContainer.new()
		%PlayersConnectedList.add_child(HBox)

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
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	load_game()

# Client

func _on_join_button_pressed():
	peer.create_client("localhost", 9999)
	multiplayer.multiplayer_peer = peer

	if %Username.text == "":
		%Username.text = "Player"

	multiplayer.server_disconnected.connect(server_offline)

	load_game()

func add_player(id):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	%SpawnPosition.add_child(player_instance)

	send_message.rpc(str(id), " has joined the game", false)

func load_game():
	%Menu.hide()
	var map_instance = map.instantiate()
	%MapInstance.add_child(map_instance)

func remove_player(id):
	var player = %SpawnPosition.get_node_or_null(str(id))
	player.queue_free()

	send_message.rpc(str(id), " left the game", false)

func server_offline():
	%Menu.show()
	%MapInstance.get_child(0).queue_free()

func _on_username_text_submitted(new_text):
	_on_join_button_pressed()

func _on_chat_box_disapears_timer_timeout():
	%ChatBox.hide()
