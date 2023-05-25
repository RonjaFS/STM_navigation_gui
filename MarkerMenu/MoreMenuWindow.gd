extends Window
#{
#	"id":id,
#	"label": create_label(),
#	"pos": pos,
#	"size": Vector2(15,15),
#	"type": type,
#	"description": "",
#	"visible": true,
#	"color": Color(rng.randf_range(0,1),rng.randf_range(0,1), rng.randf_range(0,1))
#}
var currentMarker
# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.markerMoreButtonPressed.connect(showWindowWithMarker)
	$MarginContainer/VBoxContainer/TextEditNotes.text_changed.connect(on_TextEditNotesChanged)
	$MarginContainer/VBoxContainer/HBoxContainerColor/ColorPickerButton.color_changed.connect(on_ColorPickerButtonChanged)
	$MarginContainer/VBoxContainer/HBoxContainerSize/WidthEntry.value_changed.connect(on_WidthEntryChange)
	$MarginContainer/VBoxContainer/HBoxContainerPos/XEntry.value_changed.connect(on_XEntryChange)
	$MarginContainer/VBoxContainer/HBoxContainerPos/YEntry.value_changed.connect(on_YEntryChange)
	$MarginContainer/VBoxContainer/HBoxContainer/Button.pressed.connect(on_GotoPressed)

func showWindowWithMarker(marker):
	currentMarker = marker
	self.title = marker.label
	self.visible = true
	$MarginContainer/VBoxContainer/TextEditNotes.text = marker.description
	
	$MarginContainer/VBoxContainer/HBoxContainerColor/ColorPickerButton.color = marker.color
	
	$MarginContainer/VBoxContainer/HBoxContainerSize/WidthEntry.value = marker.size.x
	
	$MarginContainer/VBoxContainer/HBoxContainerPos/XEntry.value = marker.pos.x
	
	$MarginContainer/VBoxContainer/HBoxContainerPos/YEntry.value = marker.pos.y
	
	$MarginContainer/VBoxContainer/TypeChooser.set_markerSelector(marker.type)
	$MarginContainer/VBoxContainer/TypeChooser.marker = currentMarker
func on_TextEditNotesChanged():
	var text = $MarginContainer/VBoxContainer/TextEditNotes.text
	currentMarker.description = text
	MarkerStore.update_marker(currentMarker)
func on_ColorPickerButtonChanged(val):
	currentMarker.color = val
	MarkerStore.update_marker(currentMarker)
func on_WidthEntryChange(val):
	currentMarker.size = Vector2(val,val)
	MarkerStore.update_marker(currentMarker)

func on_XEntryChange(val):
	currentMarker.pos.x = val
	MarkerStore.update_marker(currentMarker)
func on_YEntryChange(val):
	currentMarker.pos.y = val
	MarkerStore.update_marker(currentMarker)

func _on_close_requested():
	self.visible = false
func on_GotoPressed():
	Signals.scroll_to_pos.emit(currentMarker.pos)
