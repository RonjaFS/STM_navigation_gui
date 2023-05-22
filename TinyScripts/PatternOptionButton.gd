extends MenuButton

func _ready():
	var on_pattern_menu_select = func(id): 
		if id == 0:
			Signals.rebuild_pattern_pressed.emit()
		if id == 1:
			choose_pattern_file()
		else:
			print("unknown id on popup menu from pattern button")
	self.get_popup().id_pressed.connect(on_pattern_menu_select)


func choose_pattern_file():
	Signals.show_file_dialog.emit(["*.json"], false, func(path):
		ProjectStore.set_pattern_file(path)
		)
func _on_choose_pattern_button_pressed():
	choose_pattern_file()
