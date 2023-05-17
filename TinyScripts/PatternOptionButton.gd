extends MenuButton

func _ready():
	var on_pattern_menu_select = func(id): 
		if id == 0:
			Signals.rebuild_pattern_pressed.emit()
		else:
			print("unknown id on popup menu from pattern button")
	self.get_popup().id_pressed.connect(on_pattern_menu_select)
