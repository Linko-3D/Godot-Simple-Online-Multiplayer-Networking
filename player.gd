extends CharacterBody2D

func _ready():
	set_multiplayer_authority(name.to_int())
	$Authority.visible = is_multiplayer_authority()

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if Data.can_control:
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 500
	move_and_slide()
	
	$Username.text = Data.username
