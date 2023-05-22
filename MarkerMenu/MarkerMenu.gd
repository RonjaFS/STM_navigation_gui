extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_remove_marker_button_pressed():
	MarkerStore.remove_last()


func _on_load_button_pressed():
	MarkerStore.load_markers_from_file()


func _on_save_button_pressed():
	pass
#	MarkerStore.save_markers_to_file()
