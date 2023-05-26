extends VBoxContainer
var MarkerEntry = preload("res://MarkerMenu/MarkerEntry.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.marker_changed.connect(update_list)

func update_list():
	if MarkerStore.markers.size() > get_child_count():
		while MarkerStore.markers.size() > get_child_count():
			var markerEntry = MarkerEntry.instantiate()
			add_child(markerEntry)
	if MarkerStore.markers.size() < get_child_count():
		while MarkerStore.markers.size() < get_child_count():
			remove_child(get_child(0))
	var i = 0
	for mKey in MarkerStore.markers:
		var m = MarkerStore.markers[mKey]
		get_child(i).get_node("HBoxContainer").set_marker(m)
		i += 1
