extends FileDialog

var selectCallback = func(): pass
# Called when the node enters the scene tree for the first time.
func _ready():
	var onShow = func(fileFilters, showInSavingMode, fileSelectCallback):
		self.visible = true
		self.filters = fileFilters
		if(showInSavingMode):
			self.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		else:
			self.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		selectCallback = fileSelectCallback
	
	Signals.show_file_dialog.connect(onShow)

func _on_file_selected(path):
	if(selectCallback):
		selectCallback.call(path)
#		Signals.export_image_pressed.emit(path)
