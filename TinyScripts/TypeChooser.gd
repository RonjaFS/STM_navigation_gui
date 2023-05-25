extends HBoxContainer
var marker
# Called when the node enters the scene tree for the first time.
func _ready():
	for type in MarkerStore.MarkerType.values():
		var b = Button.new()
		b.custom_minimum_size = Vector2(45,45)
		b.toggle_mode = true
		b.pressed.connect(func(): changeMarkerTo(type))
		var con = MarginContainer.new()
		var margin_value = 5
		con.add_theme_constant_override("margin_top", margin_value)
		con.add_theme_constant_override("margin_left", margin_value)
		con.add_theme_constant_override("margin_bottom", margin_value)
		con.add_theme_constant_override("margin_right", margin_value)
		var tex = TextureRect.new()
		tex.texture = MarkerStore.getTextureForMarkerType(type)
		tex.size = Vector2(10,10)
		tex.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
		con.add_child(tex)
		con.set_anchors_and_offsets_preset(LayoutPreset.PRESET_FULL_RECT)
		b.add_child(con)
		add_child(b)

func set_markerSelector(type):
	var i = 0
	for c in get_children():
		c.button_pressed = type == i
		i += 1

func changeMarkerTo(type):
	set_markerSelector(type)
	marker.type = type
	MarkerStore.update_marker(marker)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
