extends Node


var markers = []

func _ready():
	print(markers)
	add_user_signal("markers_updated")

func load_markers_from_file():
	var file = File.new()
	file.open("user://marker_save.dat", File.READ)
	var content = file.get_as_text()
	file.close()
	markers = parse_json(content)

func save_markers_to_file():
	var file = File.new()
	var content = to_json(markers)
	file.open("user://marker_save.dat", File.WRITE)
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
