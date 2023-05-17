extends MenuButton

func _ready():
	var on_file_menu_select = func(id): 
		if id == 0:
			Signals.show_file_dialog.emit(["*.png"], func(path): 
				Signals.export_image_pressed.emit(path)
			)
#			Signals.export_image_pressed.emit()
		if id == 1:
			Signals.save_project_pressed.emit()
			Signals.show_notification.emit("save not yet implemented")
		if id == 2:
			if GdsExporter.currentNavigationImagePath != "":
				Signals.show_file_dialog.emit(["*.gds"], func(exportFilePath):
					var globalNavImPath = ProjectSettings.globalize_path(GdsExporter.currentNavigationImagePath)
					globalNavImPath = globalNavImPath.replace(" ","\\ ")
					GdsExporter.exportFile(globalNavImPath, exportFilePath, 200)
				)
		else:
			print("unknown id on popup menu from pattern button")
	self.get_popup().id_pressed.connect(on_file_menu_select)
