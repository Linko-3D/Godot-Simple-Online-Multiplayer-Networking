extends Node3D

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_DRAG)
		
		
	position += (transform.basis * Vector3(1, 0, 0)).normalized() * delta

func _input(event):
	if event is InputEventMouseMotion:
		#$AngleY.global_transform.basis.x -= event.relative / 2
		pass




#var zoom_percentage = 15
#var max_zoom = 2.5
#var max_unzoom = 0.4
#
#var drag_cursor_shape = false
#
#func _input(event):
	#if current:
		#if event is InputEventMouseMotion:
			#if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
				#position -= event.relative / zoom
				#drag_cursor_shape = true
			#else:
				#drag_cursor_shape = false
#
		#if event is InputEventMouseButton:
			#if event.is_pressed():
				#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					#zoom += Vector2.ONE * zoom_percentage / 100
					#if zoom.x > max_zoom:
						#zoom = Vector2.ONE * max_zoom
						#return
					#position += get_local_mouse_position() / 10
				#if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					#zoom -= Vector2.ONE * zoom_percentage / 100
					#if zoom.x < max_unzoom:
						#zoom = Vector2.ONE * max_unzoom
