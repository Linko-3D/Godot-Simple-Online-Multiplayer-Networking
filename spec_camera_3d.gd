extends Camera3D

func _ready() -> void:
	position = get_tree().get_nodes_in_group("spawn_point")[0].position
