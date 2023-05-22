extends Control

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

var mapMarkerDict = {}
var highlights = []
var arrows = []
var hash_of_file = ""
var navigationStructure
#var Arrow = preload("res://Arrow.tscn")
var FlakeMarkerPacked = preload("res://MarkerMenu/FlakeMarker.tscn")
var texture

func _ready():
	print(MarkerStore.markers)
	Signals.export_image_pressed.connect(save_navigation_cache)
	Signals.remove_navpatches_pressed.connect(remove_highlights)
	Signals.rebuild_pattern_pressed.connect(func(): update_pattern(true))
	Signals.highlight_navpatches_pressed.connect(highlight_index)
	Signals.marker_changed.connect(on_marker_changed)
	Signals.project_changed.connect(update_pattern)
#	Signals.add_marker_by_index.connect(add_marker_by_index)
#	load_patternFile()
# Dont just update the pattern if no project is set
# TODO open last project on startup
#	update_pattern()


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
	if not nav_generator:
		nav_generator = NavGenerator.new()
		add_child(nav_generator)
	if(self.is_inside_tree()):
		create_texture_with_pattern(self, "navGenCallback", forcePatternRebuild)

func zoom(factor):
	$mapTex.scale = $mapTex.scale * factor

func on_marker_changed():
	for m in mapMarkerDict:
		remove_child(mapMarkerDict[m])
	mapMarkerDict.clear()
	for m in MarkerStore.markers.values():
		var markerNode = MarkerStore.createNodeForMarker(m)
		mapMarkerDict[m.id] = markerNode
		markerNode.position = m.pos - m.size/2
		markerNode.visible = m.visible
		add_child(markerNode)

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
	var arrow = FlakeMarkerPacked.instantiate();
	arrow.color = color
	arrow.type = type
	arrow.from_pos = from_pos
	arrow.to_pos = to_pos
	arrows.append(arrow)
	add_child(arrow)
	return arrow

func save_navigation_cache(customPath = null):
	var img = $mapTex.texture.get_image()
	var pathImage = "user://navigation_"+str(nav_generator.hash_of_file)+".png"
	var pathPosCache = "user://navigation_positionCache_"+str(nav_generator.hash_of_file)+".json"
	GdsExporter.currentNavigationImagePath = pathImage
	if customPath:
		img.save_png(customPath)
	else:
		img.save_png(pathImage)
		var file = FileAccess.open(pathPosCache, FileAccess.WRITE)
		file.store_var(nav_generator.positionCache)
	Signals.show_notification.emit("Navigation pattern stored on disk.")

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
