extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var img = Image.create(500,500,false, Image.FORMAT_RGB8)
	img.set_pixel(0,0,Color.RED)
	for i in range(200):
		img.set_pixel(10,i,Color.DARK_GOLDENROD)
	$TextureRect.texture = ImageTexture.create_from_image(img)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
