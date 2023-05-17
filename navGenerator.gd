extends Node
var THREADED = true

# the gap (in pixels) between two navpatches
var GAP_NAVPATCHES = 1
var NAVPATCHSIZE = 4
var BOXSTYLE = "Lshape2" #"Lshape", "box", "grid", "Lshape"
var image
var highColor
var highlightColor
var highlightId
var highlightMarker
var imageSize
var navFileData

var navigationStructure
var hash_of_file
var markerBits

var positionCache = {}

var thread
var mutex
var textureUpdateTime = 0
var posCacheLocked = false

func _init():
	print("nav gen got initilaized")

func int2bin(value, digitcount):
	var out = ""
	while (value > 0):
		out = str(value & 1) + out
		value = (value >> 1)
	var zerosCount = digitcount - len(out)
	for _i in range(zerosCount):
		out = "0"+out
	return out
	
func navpatchDigitCount():
	return pow(NAVPATCHSIZE, 2) - 1

func addRectPixelCoord(x, y, offsetX, offsetY, col, im):
	var _x = offsetX+x
	var _y = imageSize.y - (offsetY + y)
	if(_x >= 0 and _x < imageSize.x and _y >= 0 and _y < imageSize.y):
		im.set_pixel(_x,_y, col)

func addRectLinePixelCoord(fromX,fromY,toX,toY, offsetX, offsetY, col, im):
	#s = PIXEL_SIZE + GAP_PIXELS
	var dir = Vector2((toX-fromX),(toY-fromY))
	var start = Vector2(fromX,fromY)
	for i in range(max(abs(dir.x+1),abs(dir.y+1))):
		var px = offsetX + start.x + i * dir.normalized().x - 1
		var py = offsetY + start.y + i * dir.normalized().y - 1
		var _x = px
		var _y = imageSize.y - py
		if(_x >= 0 and _x < imageSize.x and _y >= 0 and _y < imageSize.y):
			im.set_pixel(_x,_y, col)
	#top.shapes(layer).insert(pya.Box(offsetX + (fromX * s) - PIXEL_SIZE, offsetY + fromY * s - PIXEL_SIZE, offsetX + (toX * s), offsetY + (toY * s)))

func addNavpatch(x, y, id, isChunkMarker, offsetX, offsetY, img):
	# check for no pattern area
	var xAbs = x+offsetX
	var yAbs = y+offsetY
	for area in self.navFileData.noPatternAreas:
		var xMin = area.pos[0]
		var yMin = area.pos[1]
		var xMax = area.size[0]+area.pos[0]
		var yMax = area.size[1]+area.pos[1]
		if xMin <= xAbs and yMin <= yAbs and xMax >= xAbs and yMax >= yAbs:
			print("skip navPatch at:", x,", ",y)
			return

	# add to poscache:
	var posCacheId = id
	if(isChunkMarker):
		var chunkMarkerExtra = pow(2, NAVPATCHSIZE * NAVPATCHSIZE - 1)
		posCacheId += chunkMarkerExtra
	if not positionCache.keys().has(posCacheId):
		positionCache[posCacheId] = []
	var posToAdd = Vector2(x + offsetX, imageSize.y - y - offsetY)
	if positionCache[posCacheId].find(posToAdd) == -1:
		positionCache[posCacheId].append(posToAdd)

	var col = highColor
	if(id == highlightId and highlightMarker == isChunkMarker):
		col = highlightColor
	var size = NAVPATCHSIZE + 2
	# A navpatch is 5x5 on 1\mu m x 1\mu m (bigger would be better but maybe not possible with the STM)
	# There are two boxStyles box/grid. The grid style should produces simpler and smaller files and might be easier to read with the stm
	if BOXSTYLE == "box":
		for i in range(0,size):
			addRectPixelCoord(x + i, y, offsetX, offsetY,col, img)
		for i in range(0,size-1):
			addRectPixelCoord(x + size - 1, y + i, offsetX, offsetY,col, img)
		for i in range(0,size):
			addRectPixelCoord(x + i, y + size - 1, offsetX, offsetY,col, img)
		for i in range(0,size-1):
			addRectPixelCoord(x, y + i, offsetX, offsetY, col, img)

	if BOXSTYLE == "Lshape":
		addRectLinePixelCoord(x-1,y,x+floor(size/2.0),y,offsetX, offsetY, col, img)
		addRectLinePixelCoord(x,y+1,x,y+floor(size/2.0),offsetX, offsetY, col, img)
		addRectPixelCoord(x-1, y-2, offsetX, offsetY, col, img)
		
	if BOXSTYLE == "Lshape2":
		addRectLinePixelCoord(x-1,y,x+floor(size/2.0),y,offsetX, offsetY, col, img)
		addRectLinePixelCoord(x,y+1,x,y+floor(size/2.0)+1,offsetX, offsetY, col, img)

	if (isChunkMarker):
		addRectPixelCoord(x + 1, y + 1, offsetX, offsetY,Color(255,0,0), img)
	var stringNumber = int2bin(int(id), navpatchDigitCount())
#	print("string number ", stringNumber)
	var i = 0
	for c in stringNumber:
		if c == '1':
			var idOffsetMarker = i + 1
			var borderOffset = 1
			var xCoordInPatch = idOffsetMarker % NAVPATCHSIZE
			var yCoordInPatch = floor(idOffsetMarker / NAVPATCHSIZE)
			var pixelX = borderOffset + x + xCoordInPatch
			var pixelY = borderOffset + y + yCoordInPatch

			addRectPixelCoord(pixelX, pixelY, offsetX, offsetY, col, img)
		i+=1
#chunkProps
#{
#	"borderType": "Lshape",
#	"size": [256,256],
#	"markerIndex": 0,
#	"markerBits": 0,
#	"markerBitVal": 0,
#	"markerFilled": false,
#	"fieldSize": [3,3],
#	"pos": {x:10, y:10}
#}

func createNavigationChunkWithProps(chunkProps, obj, callback, cutoffX=-1, cutoffY=-1, im=null):
	var img
	var x = chunkProps.pos.x
	var y = chunkProps.pos.y
	var m_id = chunkProps.chunkIndex
	var filled = chunkProps.markerFilled
#	var fieldSize = int(navFileData.generalData.fieldSize)
	if(im == null):
		img = image
	else:
		img = im
	var numberOfIndicators = pow(2, navpatchDigitCount())
	var max_NavpatchChunkWidth = navFileData.navigation.chunkSize#floor(sqrt(numberOfIndicators + 1))
	var maxX = max_NavpatchChunkWidth if cutoffX == -1 else cutoffX
	var maxY = max_NavpatchChunkWidth if cutoffY == -1 else cutoffY
	var navpatchDistance = NAVPATCHSIZE + 2 + GAP_NAVPATCHES

	if navFileData.navigation.borderType == "grid":
		for i in range(maxX):
			addRectLinePixelCoord(i*navpatchDistance, 0, i*navpatchDistance, maxY*navpatchDistance, x, y, highColor, img)
			print("grid vertical: ", i, " of ", maxX)
		for j in range(maxY):
			addRectLinePixelCoord(0, j*navpatchDistance, maxX*navpatchDistance, j*navpatchDistance, x, y, highColor, img)
			print("grid horizontal: ", j, " of ", maxX)
	print('after grid creating before navpatch')
	for j in range(maxY):
#		print('chunk Progress ',i/maxX * 100,'% (',i,'/', maxX,")")
		#false # img.unlock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
		if( Time.get_ticks_msec() - textureUpdateTime > 300 ):
			print("time refresh stuff:", Time.get_ticks_msec(), ", ",textureUpdateTime)
			textureUpdateTime = Time.get_ticks_msec()
			obj.call_deferred(callback, img, false)
		#false # img.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
		for i in range(maxX):
			if (j == 0 and i == 0) or filled:
				addNavpatch(i * navpatchDistance, j * navpatchDistance, m_id, true, x, y, img)
			else:
				var navPatchId =  j * max_NavpatchChunkWidth + i - 1;
#				print("add navpatch with ID: ", navPatchId)
				addNavpatch(i * navpatchDistance, j * navpatchDistance, navPatchId, false, x, y, img)


func createNavigationChunk(x, y, id, obj, callback, cutoffX=-1, cutoffY=-1, im=null):
	var img
	if(im == null):
		img = image
	else:
		img = im
	var numberOfIndicators = pow(2, navpatchDigitCount())
	var max_NavpatchChunkWidth = floor(sqrt(numberOfIndicators + 1))
	var maxX = max_NavpatchChunkWidth if cutoffX == -1 else cutoffX
	var maxY = max_NavpatchChunkWidth if cutoffY == -1 else cutoffY
	var navpatchDistance = NAVPATCHSIZE + 2 + GAP_NAVPATCHES

	if BOXSTYLE == "grid":
		for i in range(maxX):
			addRectLinePixelCoord(i*navpatchDistance, 0, i*navpatchDistance, maxY*navpatchDistance, x, y,highColor, img)
			print("grid vertical: ", i, " of ", maxX)
		for j in range(maxY):
			addRectLinePixelCoord(0, j*navpatchDistance, maxX*navpatchDistance, j*navpatchDistance, x, y,highColor, img)
			print("grid horizontal: ", j, " of ", maxX)
	print('after grid creating before navpatch')
	for j in range(maxY):
#		print('chunk Progress ',i/maxX * 100,'% (',i,'/', maxX,")")
		#false # img.unlock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
		if( Time.get_ticks_msec() - textureUpdateTime > 300 ):
			print("time refresh stuff:", Time.get_ticks_msec(), ", ",textureUpdateTime)
			textureUpdateTime = Time.get_ticks_msec()
			obj.call_deferred(callback, img)
		#false # img.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
		for i in range(maxX):
			if (j == 0 and i == 0):
				addNavpatch(0, 0, id, true, x, y, img)
			else:
				var navPatchId =  j * max_NavpatchChunkWidth + i - 1;
#				print("add navpatch with ID: ", navPatchId)
				addNavpatch(i * navpatchDistance, j * navpatchDistance, navPatchId, false, x, y, img)

func navigationChunkPixelSize():
	var numberOfIndicators = pow(2, navpatchDigitCount())
	var max_NavpatchChunkWidth = floor(sqrt(numberOfIndicators + 1))
	var navpatchDistance = NAVPATCHSIZE + 2 + GAP_NAVPATCHES
	return max_NavpatchChunkWidth * navpatchDistance
 
func createNavigation(pimage, phighColor, phighlightColor, phighlightId, phighlightMarker, patternSize, maxSize, obj, callback, forcePatternRebuild):
	highColor = phighColor
	highlightColor = phighlightColor
	highlightId = phighlightId
	highlightMarker = phighlightMarker
	image = pimage
	NAVPATCHSIZE = patternSize
	imageSize = maxSize
	var patchCount = 3
	
	print(DirAccess.get_files_at("user://"))
	if not forcePatternRebuild:
		var cacheImagePath = "user://navigation_"+str(hash_of_file)+".png"
		var cachePositionCachePath = "user://navigation_positionCache_"+str(hash_of_file)+".json"
		
		if FileAccess.file_exists(cacheImagePath) and FileAccess.file_exists(cachePositionCachePath):
			image = Image.load_from_file(cacheImagePath)
			positionCache = FileAccess.open(cachePositionCachePath, FileAccess.READ).get_var()
			obj.call(callback, image, true)
			posCacheLocked = false
			Signals.show_notification.emit("Navigation loaded from disk.")
			return
	if (THREADED):
		thread = Thread.new()
		thread.start(Callable(self, "_thread_createNavitation_file").bind([patchCount, maxSize, obj, callback]), Thread.PRIORITY_NORMAL)
	else:
		_thread_createNavitation_file([patchCount, maxSize, obj, callback])

#func _thread_createNavitation(params):
#	posCacheLocked = true
#	textureUpdateTime = Time.get_ticks_msec()
#	var patchCount = params[0]
#	var maxSize = params[1]
#	var obj = params[2]
#	var callback = params[3]
#	print("hello form thread")
#	var s = navigationChunkPixelSize()
#	for chunkX in range(patchCount):
#		print(chunkX)
#		if maxSize.x != -1:
#			if s*(chunkX) > maxSize.x:
#					continue
#		for chunkY in range(patchCount):
#			var cutoffX = -1
#			var cutoffY = -1
#			print('chunkY:', chunkY)
#			if maxSize.x != -1:
#				if s*(chunkY) > maxSize.y:
#					continue
#				if s*(chunkX+1) > maxSize.x:
#					cutoffX = floor((maxSize.x - s*chunkX) / ((NAVPATCHSIZE + 2 + GAP_NAVPATCHES)))
#				if s*(chunkY+1) > maxSize.y:
#					cutoffY = floor((maxSize.x - s*chunkY) / ((NAVPATCHSIZE + 2 + GAP_NAVPATCHES)))
#			createNavigationChunk(s*chunkX, s*chunkY, chunkY*patchCount+chunkX, obj, callback, cutoffX, cutoffY)
#	obj.call_deferred(callback, image)
#
#	posCacheLocked = false
#	return
func _thread_createNavitation_file(params):
	
#	navigationStructure.borderType
#	navigationStructure.navSize
#	navigationStructure.markerIndex
#	self.navFileData.markerBits
#	self.navFileData.markerBitVal
#	self.navFileData.markerFilled
	Signals.show_notification.emit("Start generating pattern.")
	var fieldSize = int(self.navFileData.generalData.fieldSize)
	posCacheLocked = true
	textureUpdateTime = Time.get_ticks_msec()
	var maxSize = params[1]
	var obj = params[2]
	var patchCount = params[0]
	var callback = params[3]
	print("hello form thread")
	var navpatchSize = NAVPATCHSIZE + 2 + GAP_NAVPATCHES
	var s = navFileData.navigation.chunkSize * navpatchSize
#	var s = navigationChunkPixelSize()
	for chunkY in range(self.navFileData.navigation.chunks.size()):
		if maxSize.x != -1:
			if s*(chunkY) > maxSize.y:
					continue
		for chunkX in self.navFileData.navigation.chunks[chunkY].size():
			var cutoffX = -1
			var cutoffY = -1
			print("XChunk nr: ", chunkX)
			if maxSize.x != -1:
				if s*(chunkX) > maxSize.x:
					continue
				if s*(chunkX+1) > maxSize.x:
					cutoffX = floor((maxSize.x - s*chunkX) / ((NAVPATCHSIZE + 2 + GAP_NAVPATCHES)))
				if s*(chunkY+1) > maxSize.y:
					cutoffY = floor((maxSize.y - s*chunkY) / ((NAVPATCHSIZE + 2 + GAP_NAVPATCHES)))
			var chunkProps = self.navFileData.navigation.chunks[chunkY][chunkX]
			chunkProps.pos = {"x": s * chunkX,"y": s * chunkY}
			createNavigationChunkWithProps(chunkProps, obj, callback, cutoffX, cutoffY)
	obj.call_deferred(callback, image, true)
	Signals.show_notification.emit("Navigation pattern was generated.")
	posCacheLocked = false
	return

func getSingleNavpatchTexture(pId, pMarker, patternSize):
	highlightId = pId
	highlightMarker = pMarker
	NAVPATCHSIZE = patternSize
	imageSize = Vector2(patternSize+3,patternSize+3)
	var img = Image.create(imageSize.x, imageSize.y, false, Image.FORMAT_RGB8)
	addNavpatch(0, 0, pId, pMarker,2,2, img)
	return img

func getPositionsForIndex(id, marker):
	if posCacheLocked:
		printerr("The position cache cannot be accessed while generating the pattern")
		return [Vector2(-10, -10)]
	var posCacheId = id
	if marker:
		var chunkMarkerExtra = pow(2, NAVPATCHSIZE*NAVPATCHSIZE - 1)
		posCacheId += chunkMarkerExtra
	if positionCache.has(posCacheId):
		return positionCache[posCacheId]
	else:
		printerr("The index: "+str(posCacheId)+" is not part of the showed pattern")
		return [Vector2(-10, -10)]
		
func get_totalSize():
	var chunkS = int(navFileData.navigation.chunkSize)
	var navpatchSize = NAVPATCHSIZE + 2 + GAP_NAVPATCHES
	var chunkXCount = 0
	var chunkYCount = navFileData.navigation.chunks.size()
	for chunks in navFileData.navigation.chunks:
		chunkXCount = max(chunkXCount, chunks.size())
	return [chunkS * navpatchSize * chunkXCount, chunkS * navpatchSize * chunkYCount]
# Thread must be disposed (or "joined"), for portability.

func load_patternFile():
	var file = FileAccess.open("/home/timo/Documents/Uni/9.Masterarbeit_Semester/NavigationHelper/navigationGenerator/examplePatternFile.json", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parseResultError = json.parse(content)
	self.navFileData = json.data
	hash_of_file = JSON.stringify(self.navFileData).hash()
	if(parseResultError != Error.OK):
		printerr("json Parse error:", parseResultError)
	print("set field size from: ", self.navFileData.generalData.fieldSize, " to: ", self.navFileData.generalData.fieldSize)
#	fieldSize = int(self.navFileData.generalData.fieldSize)
#	pixelSize = int(self.navFileData.generalData.pixelSize)
	markerBits = int(self.navFileData.generalData.markerBits)
	navigationStructure = self.navFileData.navigation
	self.NAVPATCHSIZE = self.navFileData.generalData.fieldSize
	#self.navFileData.noPatternAreas

func _exit_tree():
	thread.wait_to_finish()
