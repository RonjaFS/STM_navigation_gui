extends Control
#tool

var nav_generator
var NavGenerator = preload("res://navGenerator.gd")

@export var fieldSize = 3
@export var pixelSize = 200
@export var markerBits = 1

@export var highColor = Color(255,255,255) 
@export var lowColor =  Color(100,100,100) 
@export var highlightColor = Color(200,100,0)
@export var highlightId = 1
@export var hightlightMarker = false
@export var update = false : set = update_set

var markers = []
var highlights = []
var arrows = []
var hash_of_file = ""
var navigationStructure
#var Arrow = preload("res://Arrow.tscn")
var Marker = preload("res://FlakeMarker.tscn")
var texture

func update_set(u):
	update_pattern()

func create_texture_with_pattern(obj, navGenCallbackName, forcePatternRebuild):
	nav_generator.load_patternFile()
	var totalSize = nav_generator.get_totalSize()
	var totalSizeX = totalSize[0]
	var totalSizeY = totalSize[1]
	var imageT: Image = Image.create(totalSizeX, totalSizeY , false, Image.FORMAT_RGB8)
	var xOffset = 0
	var yOffset = 0
	nav_generator.createNavigation(imageT, highColor, highlightColor, -1, false, fieldSize, Vector2(totalSizeX, totalSizeY), obj, navGenCallbackName, forcePatternRebuild)

func navGenCallback(image, done):
	texture = ImageTexture.create_from_image(image)
	$mapTex.texture = texture
	if done:
		save_navigation_cache()

func update_pattern(forcePatternRebuild = false):
	nav_generator = NavGenerator.new()
	add_child(nav_generator)
	if(self.is_inside_tree()):
		create_texture_with_pattern(self, "navGenCallback", forcePatternRebuild)

func _ready():
	print(MarkerStore.markers)

#	load_patternFile()
	update_pattern()

func zoom(factor):
#	print(factor)
	$mapTex.scale = $mapTex.scale * factor

func add_marker(pos: Vector2, type: int):
	var marker = Marker.instantiate()
	marker.color = Color(1, 0, 0)
	marker.type = type
	marker.position = pos - marker.size/2
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
		#var im_texture = ImageTexture.new()
		var im_texture = ImageTexture.create_from_image(nav_generator.getSingleNavpatchTexture(posIndex, marker, fieldSize)) #,Texture2D.FLAG_MIPMAPS
		var texNode = TextureRect.new()
		texNode.texture = im_texture
		texNode.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texNode.position = pos - Vector2(0,im_texture.get_size().y) + Vector2(-2, 2)
		highlights.append(texNode)
		add_child(texNode)

func remove_highlights():
	for h in highlights:
		remove_child(h)

func add_arrow(from_pos: Vector2, to_pos: Vector2, type: int, color: Color):
	var arrow = Marker.instantiate();
	arrow.color = color
	arrow.type = type
	arrow.from_pos = from_pos
	arrow.to_pos = to_pos
	arrows.append(arrow)
	add_child(arrow)
	return arrow

func save_navigation_cache():
	var img = $mapTex.texture.get_image()
	img.save_png("~/navigationImage2.png")
	img.save_png("~/navigation_"+str(nav_generator.hash_of_file)+".png")
	img.save_png("user://navigation_"+str(nav_generator.hash_of_file)+".png")
	var file = FileAccess.open("user://navigation_positionCache_"+str(nav_generator.hash_of_file)+".json", FileAccess.WRITE)
	file.store_var(nav_generator.positionCache)
	print(DirAccess.open("user://").get_files())

#func load_projectFile():
#	var file = FileAccess.open("/home/timo/Documents/Uni/9.Masterarbeit_Semester/NavigationHelper/navigationGenerator/exampleProject.json", FileAccess.READ)
#	var content = file.get_as_text()
#	hash_of_file = content.hash()
#	file.close()
#	var json = JSON.new()
#	var parseResultError = json.parse(content)
#	var patternData = json.data
#	if(parseResultError != Error.OK):
#		printerr("json Parse error:", parseResultError)
#	print("set field size from: ", fieldSize, " to: ", patternData.generalData.fieldSize)
#	fieldSize = int(patternData.generalData.fieldSize)
#	pixelSize = int(patternData.generalData.pixelSize)
#	self.markerBits = int(patternData.generalData.markerBits)
#	self.navigationStructure = patternData.navigation
