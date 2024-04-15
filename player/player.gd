extends CharacterBody2D

func _ready() -> void:
	set_multiplayer_authority(name.to_int())
	$DisplayAuthority.visible = is_multiplayer_authority()
	$AudioListener2D.current = is_multiplayer_authority()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return

	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 500
	move_and_slide()
