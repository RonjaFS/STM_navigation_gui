extends HBoxContainer
var marker
func set_marker(m):
	marker = m
	for c in $IconContainer.get_children():
		$IconContainer.remove_child(c)
	var markerNode = MarkerStore.createNodeForMarker(marker)
#	while $TextureRect.get_child_count() > 0:
#		$TextureRect.remove_child(get_child(0))
	$Label.text = marker.label
	$IconContainer.add_child(markerNode)
	$VisibleBox.button_pressed = m.visible
	markerNode.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	$TargetButtton.button_pressed = MarkerStore.is_target(marker)
	$"..".color = Color(0,0,0,0) if MarkerStore.is_selected(marker) else Color(0.1,0.1,0.1,0.1)
# Called when the node enters the scene tree for the first time.

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if not MarkerStore.is_selected(marker):
					var rect = $IconContainer.get_global_rect()
					var mouse_position = get_global_mouse_position()
					if rect.has_point(mouse_position):
						MarkerStore.set_selected_marker(marker)

func _ready():
	
	pass # Replace with function body.

func _on_delete_button_pressed():
	MarkerStore.remove_marker(marker.id)


func _on_visible_box_pressed():
	marker.visible = !marker.visible
	MarkerStore.update_marker(marker)


func _on_label_text_submitted(new_text):
	marker.label = new_text
	MarkerStore.update_marker(marker)


func _on_label_text_changed(new_text):
	pass


func _on_label_focus_exited():
	marker.label = $Label.text
	MarkerStore.update_marker(marker)


func _on_button_pressed():
	Signals.markerMoreButtonPressed.emit(marker)


func _on_go_to_button_pressed():
	Signals.scroll_to_pos.emit(marker.pos)

func _on_target_buttton_pressed():
	MarkerStore.set_target_marker(marker)
