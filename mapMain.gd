extends VBoxContainer

func set_marked_index(marker, index):
#	export var highlightId = 1 setget highlightId_set
#	export var hightlightMarker = false setget hightlightMarker_set
#	$scrollBox/Control.highlightId = index
#	$scrollBox/Control.hightlightMarker = marker
	$scrollBox/Control.highlight_index(index, marker)

func add_marker(index, marker):
	$scrollBox/Control.add_marker_by_index(index,marker,0)

func scroll_to(index, marker):
	$scrollBox.scroll_to_by_index(index, marker)
