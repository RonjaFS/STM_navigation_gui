extends Panel

func _ready():
	visible = false
	Signals.show_notification.connect(show_notification)
func show_notification(text, duration = 3):
	var t = Timer.new()
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_color", Color.BLACK)
#	l.add_color_override("font_color", Color(1,0,0,1))
	add_child(t)
	$Labels.add_child(l)
	call_deferred("update_visibility")
	t.timeout.connect(
		func(): 
			$Labels.remove_child(l)
			remove_child(t)
			call_deferred("update_visibility")
	)
	t.start(duration)

func update_visibility():
	if $Labels.get_child_count() > 0:
		print("$Labels size:", $Labels.size)
		print($Labels.get_child_count())
		offset_bottom = -20
		offset_top = -$Labels.get_children()[0].size.y * $Labels.get_child_count() - 10 - 20
		visible = true
	else:
		visible = false
