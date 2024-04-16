extends CharacterBody2D

func _ready():
	set_multiplayer_authority(name.to_int())
	$DisplayAuthority.visible = is_multiplayer_authority()
	$AudioListener2D.current = is_multiplayer_authority()

	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, 0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

func _physics_process(delta):
	if not is_multiplayer_authority(): return

	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 500
	move_and_slide()
