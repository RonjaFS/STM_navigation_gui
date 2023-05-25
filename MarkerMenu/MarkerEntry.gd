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
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
