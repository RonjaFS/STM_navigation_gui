extends Control
#tool

var nav_generator

export var fieldSize = 3
export var totalSizeX = 500
export var totalSizeY = 500
export var pixelSize = 200
export var markerBits = 1

export var highColor = Color(255,255,255) 
export var lowColor =  Color(100,100,100) 
export var highlightColor = Color(200,100,0)
export var highlightId = 1
export var hightlightMarker = false
export var update = false setget update_set

var markers = []
var highlights = []
var arrows = []

#var Arrow = preload("res://Arrow.tscn")
var Marker = preload("res://FlakeMarker.tscn")
var texture
func update_set(u):
	update_pattern()

func create_texture_with_pattern(obj, navGenCallbackName):
	var image = Image.new()
	
	image.create(totalSizeX, totalSizeY, false, Image.FORMAT_RGB8)
	var xOffset = 0
	var yOffset = 0	
	nav_generator.createNavigation(image, 10, highColor, highlightColor, -1, false, fieldSize, min(totalSizeX,totalSizeY), obj, navGenCallbackName)
	return image
func navGenCallback(image):
		texture.create_from_image(image, Texture.FLAG_MIPMAPS)

func update_pattern():
	nav_generator = load("res://navGenerator.gd").new()
	add_child(nav_generator)
	if(self.is_inside_tree()):
		texture = ImageTexture.new()
		create_texture_with_pattern(self, "navGenCallback")
#		texture.create_from_image(create_texture_with_pattern(), Texture.FLAG_MIPMAPS)
		$mapTex.texture = texture

func _ready():
	print(MarkerStore.markers)
	load_patternFile()
	update_pattern()

func zoom(factor):
	print(factor)
	$mapTex.rect_scale = $mapTex.rect_scale * factor

func _on_Button_pressed():
	zoom(1.2)

func _on_ButtonMinus_pressed():
	zoom(0.8)

func add_marker(pos: Vector2, type: int):
	var marker = Marker.instance()
	marker.color = Color(1, 0, 0)
	marker.type = type
	marker.rect_position = pos - marker.rect_size/2
	markers.append(marker)
	add_child(marker)
	MarkerStore.add_store_marker(pos,type)
	return marker

func add_marker_by_index(posIndex,marker, type):
	var pos = nav_generator.getPositionsForIndex(posIndex, marker)[0]
	if pos == Vector2(-10,-10):
		return
	add_marker(pos, type)

func highlight_index(posIndex, marker):
	var positions = nav_generator.getPositionsForIndex(posIndex, marker).duplicate()
	for pos in positions:
		if pos == Vector2(-10, -10):
			continue
		var texture = ImageTexture.new()
		texture.create_from_image(nav_generator.getSingleNavpatchTexture(posIndex, marker, patternSizeX), Texture.FLAG_MIPMAPS)
		
		var texNode = TextureRect.new()
		texNode.texture = texture
		texNode.rect_position = pos - Vector2(0,texture.get_size().y) + Vector2(-2, 2)
		highlights.append(texNode)
		add_child(texNode)

func add_arrow(from_pos: Vector2, to_pos: Vector2, type: int, color: Color):
	var arrow = Marker.instance();
	arrow.color = color
	arrow.type = type
	arrow.from_pos = from_pos
	arrow.to_pos = to_pos
	arrows.append(arrow)
	add_child(arrow)
	return arrow

func save_image():
	var img = $mapTex.texture.get_data()
	img.save_png("user://navigationImage.png")

func load_patternFile():
	var file = File.new()
	file.open("/home/timo/Documents/Uni/9.Masterarbeit_Semester/NavigationHelper/navigationGenerator/examplePatternFile.json", File.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.parse(content)
	var patternData = json.result
	if(json.error):
		print("json Parse error:", json.error)
	self.fieldSize = patternData.generalData.fieldSize
	self.pixelSize = patternData.generalData.pixelSize
	self.markerBits = patternData.generalData.markerBits

