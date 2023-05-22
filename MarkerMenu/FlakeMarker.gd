@tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var color = Color(0.3,0.3,0.8) : set = update_color
@export var type = 0 : set = update_type
var index = ""

func _ready():
	resized.connect(on_resize)
	$FlakeIcon.modulate = color
func update_type(new):
	type = new

func on_resize():
	var minSize = min(get_rect().size.x, get_rect().size.y)
	$FlakeIcon.position = get_rect().size/2
	var spriteScale =Vector2(minSize/$FlakeIcon.texture.get_size().x, minSize/$FlakeIcon.texture.get_size().y)
	$FlakeIcon.scale = spriteScale
func update_color(new):
	color = new
	$FlakeIcon.modulate = color


