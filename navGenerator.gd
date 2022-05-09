extends Object
# the gap (in pixels) between two navpatches
var GAP_NAVPATCHES = 1
var NAVPATCHSIZE = 3
var BOXSTYLE = "Lshape2" #"Lshape", "box", "grid", "Lshape"
var image
var highColor
var highlightColor
var highlightId
var highlightMarker
var imageSize
var positionCache = {}
func _init():
	print("nav gen got initilaized")

func int2bin(value, digitcount):
	var out = ""
	while (value > 0):
		out = str(value & 1) + out
		value = (value >> 1)
	var zerosCount = digitcount - len(out)
	for i in range(zerosCount):
		out = "0"+out
	return out
	
func navpatchDigitCount():
	return pow(NAVPATCHSIZE,2) - 1

func addRectPixelCoord(x,y, offsetX, offsetY, col):
	image.set_pixel(offsetX+x,imageSize-(offsetY+y), col)

func addRectLinePixelCoord(fromX,fromY,toX,toY, offsetX, offsetY, col):
	#s = PIXEL_SIZE + GAP_PIXELS
	var dir = Vector2((toX-fromX),(toY-fromY))
	var start = Vector2(fromX,fromY)
	for i in range(max(abs(dir.x+1),abs(dir.y+1))):
		var px = offsetX + start.x + i * dir.normalized().x - 1
		var py = offsetY + start.y + i * dir.normalized().y - 1
		image.set_pixel(px, imageSize-py, col)
		
	#top.shapes(layer).insert(pya.Box(offsetX + (fromX * s) - PIXEL_SIZE, offsetY + fromY * s - PIXEL_SIZE, offsetX + (toX * s), offsetY + (toY * s)))

func addNavpatch(x, y, id, isChunkMarker, offsetX, offsetY):
	# add to poscache:
	var posCacheId = id
	if(isChunkMarker):
		var chunkMarkerExtra = pow(2,NAVPATCHSIZE*NAVPATCHSIZE-1)
		posCacheId += chunkMarkerExtra
	if not positionCache.keys().has(posCacheId):
		positionCache[posCacheId] = []
	else:
		print("already had this key")
	var posToAdd = Vector2(x + offsetX, imageSize - y - offsetY)
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
		  addRectPixelCoord(x + i, y, offsetX, offsetY,col)
	  for i in range(0,size-1):
		  addRectPixelCoord(x + size - 1, y + i, offsetX, offsetY,col)
	  for i in range(0,size):
		  addRectPixelCoord(x + i, y + size - 1, offsetX, offsetY,col)
	  for i in range(0,size-1):
		  addRectPixelCoord(x, y + i, offsetX, offsetY,col)

	if BOXSTYLE == "Lshape":
		addRectLinePixelCoord(x-1,y,x+floor(size/2.0),y,offsetX, offsetY, col)
		addRectLinePixelCoord(x,y+1,x,y+floor(size/2.0),offsetX, offsetY, col)
		addRectPixelCoord(x-1, y-2, offsetX, offsetY, col)
		
	if BOXSTYLE == "Lshape2":
		addRectLinePixelCoord(x-1,y,x+floor(size/2.0),y,offsetX, offsetY, col)
		addRectLinePixelCoord(x,y+1,x,y+floor(size/2.0)+1,offsetX, offsetY, col)

	if (isChunkMarker):
		addRectPixelCoord(x + 1, y + 1, offsetX, offsetY,Color(255,0,0))

	var stringNumber = int2bin(int(id), navpatchDigitCount())
	var i = 0
	for c in stringNumber:
		if c == '1':
			var idOffsetOne = i + 1
			addRectPixelCoord(1 + x + idOffsetOne % NAVPATCHSIZE, y + 1 + floor(idOffsetOne / NAVPATCHSIZE), offsetX, offsetY, col)
		i+=1


func createNavigationChunk(x, y, id, cutoffX=-1, cutoffY=-1):
	var numberOfIndicators = pow(2, navpatchDigitCount())
	var max_NavpatchChunkWidth = floor(sqrt(numberOfIndicators + 1))
	var maxX = max_NavpatchChunkWidth if cutoffX == -1 else cutoffX
	var maxY = max_NavpatchChunkWidth if cutoffY == -1 else cutoffY
	var navpatchDistance = NAVPATCHSIZE + 2 + GAP_NAVPATCHES

	if BOXSTYLE == "grid":
		for i in range(maxX):
			addRectLinePixelCoord(i*navpatchDistance, 0, i*navpatchDistance, maxY*navpatchDistance, x, y,highColor)
			print("grid vertical: ", i, " of ", maxX)
		for j in range(maxY):
			addRectLinePixelCoord(0, j*navpatchDistance, maxX*navpatchDistance, j*navpatchDistance, x, y,highColor)
			print("grid horizontal: ", j, " of ", maxX)

	for i in range(maxX):
		for j in range(maxY):
			if (j == 0 and i == 0):
				addNavpatch(0, 0, id, true, x, y)
			else:
				addNavpatch(i * navpatchDistance, j* navpatchDistance, j * max_NavpatchChunkWidth + i - 1, false, x, y)

func navigationChunkPixelSize():
	var numberOfIndicators = pow(2, navpatchDigitCount())
	var max_NavpatchChunkWidth = floor(sqrt(numberOfIndicators + 1))
	var navpatchDistance = NAVPATCHSIZE + 2 + GAP_NAVPATCHES
	return max_NavpatchChunkWidth * navpatchDistance



func createNavigation(pimage, patchCount, phighColor, phighlightColor, phighlightId, phighlightMarker, patternSize, maxSize):
	highColor = phighColor
	highlightColor = phighlightColor
	highlightId = phighlightId
	highlightMarker = phighlightMarker
	image = pimage
	NAVPATCHSIZE = patternSize
	imageSize = maxSize
	var s = navigationChunkPixelSize()
	for i in range(patchCount):
		if maxSize != -1:
			if s*(i) > maxSize:
					continue
		for j in range(patchCount):
			var cutoffX = -1
			var cutoffY = -1
			if maxSize != -1:
				if s*(j) > maxSize:
					continue
				if s*(i+1) > maxSize:
					cutoffX = floor((maxSize - s*i) / ((NAVPATCHSIZE + 2 + GAP_NAVPATCHES)))
				if s*(j+1) > maxSize:
					cutoffY = floor((maxSize - s*j) / ((NAVPATCHSIZE + 2 + GAP_NAVPATCHES)))
			createNavigationChunk(s*i, s*j, j*patchCount+i,cutoffX,cutoffY)

func getSingleNavpatchTexture(pId, pMarker, patternSize):
	highlightId = pId
	highlightMarker = pMarker
	NAVPATCHSIZE = patternSize
	imageSize = patternSize+3
	image = Image.new()
	image.create(imageSize, imageSize, false, Image.FORMAT_RGB8)
	image.lock()
	addNavpatch(0, 0, pId, pMarker,2,2)
	image.unlock()
	return image

func getPositionsForIndex(id, marker):
	var posCacheId = id
	if marker:
		var chunkMarkerExtra = pow(2,NAVPATCHSIZE*NAVPATCHSIZE-1)
		posCacheId += chunkMarkerExtra
	if positionCache.keys().has(posCacheId):
		return positionCache[posCacheId]
	else:
		printerr("The index: "+str(posCacheId)+" is not part of the showed pattern")
		return [Vector2(-10, -10)]
