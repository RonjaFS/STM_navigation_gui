extends Node


var markers = []

func _ready():
	print(markers)
	add_user_signal("markers_updated")

func load_markers_from_file():
	var file = FileAccess.open("user://marker_save.dat", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var test_json_conv = JSON.new()
	test_json_conv.parse(content)
	markers = test_json_conv.get_data()

func save_markers_to_file():
	var content = JSON.stringify(markers)
	var file = FileAccess.open("user://marker_save.dat", FileAccess.WRITE)
	print("saved: ", markers, content)
	file.store_string(content)
	file.close()

func remove_last():
	pass
#	markers.pop_back()
#	emit_signal("markers_updated")

func add_store_marker(pos, type):
	pass
#	markers.append([pos, type])
#	emit_signal("markers_updated")
