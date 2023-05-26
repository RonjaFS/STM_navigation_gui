@tool
extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var color = Color(0.3,0.3,0.8) : set = update_color
@export var type = 0 : set = update_type
var muSize = Vector2(10,10)
var index = ""
var onMap = false : set = update_onMap

func _ready():
	resized.connect(on_resize)
	$FlakeIcon.modulate = color

func update_type(new):
	type = new
	$FlakeIcon.texture = MarkerStore.getTextureForMarkerType(type)

func update_onMap(new):
	onMap = new
	update_color(color)
	on_resize()
func on_resize():
	var minSize = min(get_rect().size.x, get_rect().size.y)
	$FlakeIcon.position = get_rect().size/2
	if onMap and type == 1:
		$FlakeIcon.position.y = 0.05#get_rect().size.y
	var spriteScale =Vector2(minSize/$FlakeIcon.texture.get_size().x, minSize/$FlakeIcon.texture.get_size().y)
	$FlakeIcon.scale = spriteScale

func update_color(new):
	color = new
	$FlakeIcon.modulate = color
	if(onMap):
		color.a = 0.8
		$FlakeIcon.modulate = color

