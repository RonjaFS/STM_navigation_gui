tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var color = Color(0.3,0.3,0.8) setget update_color
export var type = 0 setget update_type
func update_type(new):
	type = new
	
func update_color(new):
	color = new
	$FlakeIcon.modulate = color
# Called when the node enters the scene tree for the first time.
func _ready():
	$FlakeIcon.modulate = color
	
