extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var sizeX = 3
export var sizeY = 3
export var side_gap = 130
var buttons = []
onready var mapNode = get_node("../map")
# Called when the node enters the scene tree for the first time.
func _ready():

	#$GridContainer.rect_size = Vector2(this_size, this_size)
	anchor_center($GridContainer)
	$GridContainer.columns = sizeX
	for i in range(sizeX):
		for j in range(sizeY):
			var b = Button.new()
			b.size_flags_horizontal = SIZE_EXPAND_FILL
			b.size_flags_vertical = SIZE_EXPAND_FILL
			$GridContainer.add_child(b)
			b.toggle_mode = true
			if (i == sizeY-1 and j == 0):
				b.text = "marker"
	addBorderCorner(-2,-2)
	addBorderCorner(5,-2)
	addBorderCorner(-2,5)
	addBorderCorner(5,5)
func anchor_center(node):
	var this_size = min(self.rect_size.x, self.rect_size.y)
	node.margin_bottom = this_size/2 - side_gap
	node.margin_top = -this_size/2 + side_gap
	node.margin_left = -this_size/2 + side_gap
	node.margin_right = this_size/2 - side_gap
func addBorderCorner(posx, posy):
	var border_count_right = sizeX
	var border_count_top = sizeY
	for x_i in range(-1, border_count_right):
		addCR(x_i+posx,0+posy,$GridContainer.rect_size, $GridContainer.rect_position)
	for y_i in range( -border_count_top, 0):
		addCR(0+posx,y_i+posy,$GridContainer.rect_size, $GridContainer.rect_position)
	#addCR(posx,posy+1,$GridContainer.rect_size, $GridContainer.rect_position)
func addCR(x,y,grid_size, grid_position):
	var pixel_size = grid_size.x / sizeX
	var cr = ColorRect.new()
	cr.color = Color.gray
	cr.rect_position = Vector2( x*pixel_size, y*pixel_size) + grid_position
	cr.rect_size = Vector2(pixel_size+1,pixel_size+1)
	self.add_child(cr)
	self.move_child(cr,1)
	cr.set_anchors_preset(Control.PRESET_CENTER)
func getIndexAndMarker():
	var number = 0
	var marker = false
	var child_count = len($GridContainer.get_children())
	var i =  0
	
	while i < child_count:
		var btn = $GridContainer.get_children()[childIndexForNumber(i)]
		if btn.pressed == true:
			if (i == child_count - 1):
				marker = true
			else:
				number += pow(2, i)
		i+=1
	return [number,marker]

func update_marker():
	var indexAndMarker = getIndexAndMarker()
	mapNode.set_marked_index(indexAndMarker[1], indexAndMarker[0])

func childIndexForNumber(n):
	var line = floor(n/sizeX)
	return line*sizeX + ((sizeX-1)-n%sizeX)

func _on_updateButton_pressed():
	update_marker()

func _on_gotoMarker_pressed():
	var indexAndMarker = getIndexAndMarker()
	mapNode.scroll_to(indexAndMarker[0], indexAndMarker[1])


func _on_addMarker_pressed():
	var indexAndMarker = getIndexAndMarker()
	mapNode.add_marker(indexAndMarker[0], indexAndMarker[1])


func _on_SaveButton_pressed():
	MarkerStore.save_markers_to_file()


func _on_LoadButton_pressed():
	MarkerStore.load_markers_from_file()

func _on_RemoveMarkerButton_pressed():
	MarkerStore.remove_last()


func _on_saveImageButton_pressed():
	get_node("../map").save_image()
