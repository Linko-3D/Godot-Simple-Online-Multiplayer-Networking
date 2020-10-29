extends KinematicBody2D

var direction = Vector2()
var player_name = ""

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")

	yield(get_tree(), "idle_frame") # Wait one frame before checking if we are the master of this node

	set_physics_process(is_network_master())
	$Controlled.visible = is_network_master()
	if is_network_master():
		rpc("share_name", NETWORK.player_name)

func _physics_process(delta):
	direction.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	direction.y = -Input.get_action_strength("ui_up") + Input.get_action_strength("ui_down")
	direction = direction.normalized()
	move_and_slide(direction * 500)
	
	if direction != Vector2(): # If we are moving the character sends rpc call
		rpc_unreliable("transform_data", transform)
	
	if Input.is_action_just_pressed("ui_accept"):
		rpc("visibility", !$Sprite.visible)

remote func transform_data(data):
	transform = data

remotesync func visibility(data):
	$Sprite.visible = data

remotesync func share_name(data):
	$Name.text = data
	player_name = data

func _on_network_peer_connected(id):
	if is_network_master():
		rpc("transform_data", transform)
		rpc("visibility", $Sprite.visible)
		rpc("share_name", NETWORK.player_name)
