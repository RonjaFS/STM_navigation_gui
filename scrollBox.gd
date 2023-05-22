extends Control

var zoom = 1
@onready var child = get_child(0)
@onready var hbar = $HScrollBar
@onready var vbar = $VScrollBar
@export var GOTO_ZOOM = 5
@export var MaxZoom = 20
@export var MinZoom = 0.2
var tween
func _ready():
	vbar.connect("value_changed",Callable(self,"_on_vbar"))
	hbar.connect("value_changed",Callable(self,"_on_hbar"))
	Signals.scroll_to_index.connect(scroll_to_index)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# ZOOM
			var zoom_dir = 0
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_dir = +1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_dir = -1
			if zoom_dir != 0:
				var zoom_factor = (1 + zoom_dir * 0.05)
				var zoom_pos = get_local_mouse_position()
				scale_at_pivot(zoom_pos, zoom_factor)

			if event.button_index == MOUSE_BUTTON_RIGHT:
				Signals.add_marker.emit(child.get_local_mouse_position(), 0)
#				child.add_marker(child.get_local_mouse_position(), 0)
				# DRAG
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			child.position+=event.relative

func scale_at_pivot(p, factor):
	var old_scale = child.scale
	child.scale *= factor
	# cap rect scale:
	child.scale = Vector2(min(child.scale.x, MaxZoom), min(child.scale.y, MaxZoom))
	child.scale = Vector2(max(child.scale.x, MinZoom), max(child.scale.y, MinZoom))
	var actually_scaled_factor = child.scale.x/old_scale.x
	if old_scale != child.scale:
		child.position -= (p-child.position)*(actually_scaled_factor-1)

func _on_vbar(new_val):
	child.position.y = new_val
	
func _on_hbar(new_val):
	child.position.x = new_val

func scroll_to_index(index, marker):
	var pos = child.nav_generator.getPositionsForIndex(index, marker)[0]
	if pos == Vector2(-10,-10):
		return
	var scale = child.scale
	if(child.scale.x < GOTO_ZOOM):
		scale = Vector2(GOTO_ZOOM, GOTO_ZOOM)
	var newPos = -(pos*scale) + size/2
	var duration = (child.position - newPos).length()/20000
	if tween:
		tween.kill() # Abort the previous animation.
	tween = get_tree().create_tween()
	tween.tween_property(child, "scale", scale, duration)
	tween.parallel().tween_property(child, "position", newPos, duration)

func _on_in_Button_pressed():
	scale_at_pivot(self.size/2, 1.1)

func _on_out_Button_pressed():
	scale_at_pivot(self.size/2, 0.9)
