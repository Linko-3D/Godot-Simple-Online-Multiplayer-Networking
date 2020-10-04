extends KinematicBody2D

func _ready():
		get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")

func _physics_process(delta):
		if is_network_master():
			position.x += (-Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")) * 5
			rpc_unreliable("transform_data", transform)
			if Input.is_action_just_pressed("ui_accept"):
				visible = !visible
				rpc("visibility", visible)

remote func transform_data(data):
	transform = data

remote func visibility(data):
	visible = data

func _on_network_peer_connected(id):
		if is_network_master():
			rpc("transform_data", transform)
			rpc("visibility", visible)
