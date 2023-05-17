extends FileDialog

var selectCallback = func(): pass
# Called when the node enters the scene tree for the first time.
func _ready():
	var onShow = func(fileFilters, fileSelectCallback):
		self.visible = true
		self.filters = fileFilters
		selectCallback = fileSelectCallback
	
	Signals.show_file_dialog.connect(onShow)

func _on_file_selected(path):
	if(selectCallback):
		selectCallback.call(path)
#		Signals.export_image_pressed.emit(path)
