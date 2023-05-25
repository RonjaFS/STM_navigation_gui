extends MenuButton

func _ready():
	var on_file_menu_select = func(id): 
		#Export Image
		if id == 0:
			Signals.show_file_dialog.emit(["*.png"], true, func(path): 
				Signals.export_image_pressed.emit(path)
			)
#			Signals.export_image_pressed.emit()
		#Save Project
		if id == 1:
			Signals.save_project_pressed.emit()
			ProjectStore.save_project_to_file(ProjectStore.projectFilePath)
			Signals.show_notification.emit("Project file saved!")
#			Signals.show_notification.emit("save not yet implemented")
		#Open Project
		if id == 2:
			open_project()
		#Export GDSII
		if id == 3:
			if GdsExporter.currentNavigationImagePath != "":
				Signals.show_file_dialog.emit(["*.gds"], true, func(exportFilePath):
					var globalNavImPath = ProjectSettings.globalize_path(GdsExporter.currentNavigationImagePath)
					globalNavImPath = globalNavImPath.replace(" ","\\ ")
					GdsExporter.exportFile(globalNavImPath, exportFilePath, 200)
				)
		#Save Project As
		if id == 4:
			Signals.save_project_pressed.emit()
			Signals.show_file_dialog.emit(["*.nav"], true, func(exportPath):
				ProjectStore.save_project_to_file(exportPath)
				Signals.show_notification.emit("Project file saved!")
			)
		else:
			print("unknown id on popup menu from pattern button")
	self.get_popup().id_pressed.connect(on_file_menu_select)

func open_project():
	Signals.show_file_dialog.emit(["*.nav"], false, func(exportPath):
		ProjectStore.load_project_from_file(exportPath)
#				MarkerStore.load_markers_from_file(exportPath)
		Signals.show_notification.emit("Project file loaded!")
	)

func _on_new_button_pressed():
	Signals.new_project_pressed.emit()

func _on_open_project_button_pressed():
	open_project()

func _on_open_last_project_pressed():
	ProjectStore.load_last_project()
