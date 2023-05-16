extends VBoxContainer

func set_marked_index(marker, index):
#	@export var highlightId = 1 : set = highlightId_set
#	@export var hightlightMarker = false : set = hightlightMarker_set
#	$scrollBox/Control.highlightId = index
#	$scrollBox/Control.hightlightMarker = marker
	$scrollBox/Control.highlight_index(index, marker)

func add_marker(index, marker):
	$scrollBox/Control.add_marker_by_index(index,marker,0)

func scroll_to(index, marker):
	$scrollBox.scroll_to_index(index, marker)

func save_image():
	$scrollBox/Control.save_image()
func remove_all_marker():
	$scrollBox/Control.remove_highlights()
