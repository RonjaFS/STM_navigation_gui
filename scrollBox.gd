extends Control

var zoom = 1
onready var child = get_child(0)
onready var hbar = $HScrollBar
onready var vbar = $VScrollBar
export var GOTO_ZOOM = 5
func _ready():
	vbar.connect("value_changed", self, "_on_vbar")
	hbar.connect("value_changed", self, "_on_hbar")

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# ZOOM
			var zoom_dir = 0
			if event.button_index == BUTTON_WHEEL_UP:
				zoom_dir = +1
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoom_dir = -1
			if zoom_dir != 0:
				var zoom_factor = (1 + zoom_dir * 0.05)
				print(zoom_factor)
				var zoom_pos = get_local_mouse_position()
				scale_at_pivot(zoom_pos, zoom_factor)
			
			if event.button_index == BUTTON_RIGHT:
				child.add_marker(child.get_local_mouse_position(),0)
			# DRAG
	if event is InputEventMouseMotion:
		if event.button_mask == BUTTON_LEFT:
			child.rect_position+=event.relative

func scale_at_pivot(p, factor):
	var old_scale = child.rect_scale
	child.rect_scale *= factor
	# cap rect scale:
	child.rect_scale = Vector2(min(child.rect_scale.x, 20), min(child.rect_scale.y, 20))
	child.rect_scale = Vector2(max(child.rect_scale.x, 0.2), max(child.rect_scale.y, 0.2))
	var actually_scaled_factor = child.rect_scale.x/old_scale.x
	if old_scale != child.rect_scale:
		print("updatePos")
		child.rect_position -= (p-child.rect_position)*(actually_scaled_factor-1)

func _on_vbar(new_val):
	child.rect_position.y = new_val
	
func _on_hbar(new_val):
	child.rect_position.x = new_val

func scroll_to_by_index(index, marker):
	var pos = child.nav_generator.getPositionsForIndex(index, marker)[0]
	if pos == Vector2(-10,-10):
		return
	var scale = child.rect_scale
	if(child.rect_scale.x < GOTO_ZOOM):
		scale = Vector2(GOTO_ZOOM, GOTO_ZOOM)
	var newPos = -(pos*scale) + rect_size/2
	var duration = (child.rect_position - newPos).length()/1400
	$Tween.interpolate_property(child, "rect_scale", child.rect_scale, scale, duration)
	$Tween.interpolate_property(child, "rect_position", child.rect_position, newPos, duration)
	$Tween.start()

func _on_in_Button_pressed():
	scale_at_pivot(self.rect_size/2, 1.1)

func _on_out_Button_pressed():
	scale_at_pivot(self.rect_size/2, 0.9)
