extends CharacterBody2D

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

	$Authority.visible = is_multiplayer_authority()

	if not is_multiplayer_authority(): return
	$PlayerName.text = get_tree().get_first_node_in_group("player_name").text

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 500
	move_and_slide()
