extends Node

var FlakeMarkerPacked = preload("res://MarkerMenu/FlakeMarker.tscn")
var markers = {}
var _target_marker_id = ""
var _selected_marker_id = ""

enum MarkerType {
	Flake = 0,
	PositionPin = 1,
	Waypoint = 2
}
func getTextureForMarkerType(t):
	match t:
		MarkerType.PositionPin: return load("res://MarkerMenu/pin.png")
		MarkerType.Flake: return load("res://MarkerMenu/flakeIcon.png")
		MarkerType.Waypoint: return load("res://MarkerMenu/Waypoint.png")

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

#func remove_last():
#	markers.erase(markers.keys().back())
#	Signals.marker_changed.emit()

var rng = RandomNumberGenerator.new()

func add_marker(pos, type):
	# function to add marker at position with specified type
	var id = create_id(pos)
	markers[id] = {
		"id":id,
		"label": create_label(),
		"pos": pos,
		"size": Vector2(10,10),
		"type": type,
		"description": "",
		"visible": true,
		"color": Color(rng.randf_range(0,1),rng.randf_range(0,1), rng.randf_range(0,1))
	}
	self._selected_marker_id = id
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

func is_selected(m):
	return self._selected_marker_id == m.id

func is_target(m):
	return self._target_marker_id == m.id

func set_target_marker(m):
	self._target_marker_id = m.id
	Signals.marker_changed.emit()
func get_target_marker():
	if self._target_marker_id != "" and markers.has(self._target_marker_id):
		return markers[self._target_marker_id]

func set_selected_marker(m):
	self._selected_marker_id = m.id
	Signals.marker_changed.emit()
func get_selected_marker():
	if self._selected_marker_id != "" and markers.has(self._selected_marker_id):
		return markers[self._selected_marker_id]
