extends Node

var FlakeMarkerPacked = preload("res://MarkerMenu/FlakeMarker.tscn")
var markers = {}

enum MarkerType {
	Flake = 0,
	PositionPin = 1
}
func getTextureForMarkerType(t):
	match t:
		MarkerType.PositionPin: return load("res://MarkerMenu/pin.png")
		MarkerType.Flake: return load("res://MarkerMenu/flakeIcon.png")

func _ready():
	print(markers)
	add_user_signal("markers_updated")
	Signals.add_marker.connect(add_marker)

func createNodeForMarker(marker, onMap = false):
	var markerNode = FlakeMarkerPacked.instantiate()
	markerNode.type = marker.type
	markerNode.color = marker.color
	markerNode.onMap = onMap
	return markerNode

func update_marker(marker):
	markers[marker.id] = marker
	Signals.marker_changed.emit()
	
func remove_marker(id):
	markers.erase(id)
	Signals.marker_changed.emit()

func remove_last():
	markers.erase(markers.keys().back())
	Signals.marker_changed.emit()

var rng = RandomNumberGenerator.new()

func add_marker(pos, type):
	var id = create_id(pos)
	markers[id] = {
		"id":id,
		"label": create_label(),
		"pos": pos,
		"size": Vector2(15,15),
		"type": type,
		"description": "",
		"visible": true,
		"color": Color(rng.randf_range(0,1),rng.randf_range(0,1), rng.randf_range(0,1))
	}
	Signals.marker_changed.emit()
	Signals.show_notification.emit("marker added at: X:"+str(pos.x)+", y:"+str(pos.y))

func create_id(pos):
	var count_existing = 0
	var id_extension = ""
	for mKey in markers:
		var m = markers[mKey]
		if m.pos == pos:
			count_existing += 1
	if count_existing > 0:
		id_extension = "-"+str(count_existing)
	return str(pos.x)+"-"+str(pos.y)+id_extension

func create_label():
	var num = str(markers.size())
	var BASENAME = "marker "
	return BASENAME+num
