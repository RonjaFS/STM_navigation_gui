extends FileDialog

var PATH_TO_FILE_FILTER_DIC = "user://fileFilterPathDic.var"

var _selectCallback = func(): pass
var _lastFilterForFile = []
var fileFilterPathDic = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	var f = FileAccess.open(PATH_TO_FILE_FILTER_DIC, FileAccess.READ)
	if f:
		fileFilterPathDic = f.get_var()
	var onShow = func(fileFilters, showInSavingMode, fileSelectCallback):
		self.visible = true
		self.filters = fileFilters
		if(fileFilterPathDic.has(fileFilters)):
			self.current_path = fileFilterPathDic[fileFilters]
		if(showInSavingMode):
			self.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		else:
			self.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		current_file = ""
		_selectCallback = fileSelectCallback
		_lastFilterForFile = fileFilters
		
	Signals.show_file_dialog.connect(onShow)

func _on_file_selected(path):
	if(_selectCallback):
		fileFilterPathDic[_lastFilterForFile] = path
		_selectCallback.call(path)

func _exit_tree():
	FileAccess.open(PATH_TO_FILE_FILTER_DIC, FileAccess.WRITE).store_var(fileFilterPathDic)
	print("FILE DIALOG EXIT'D Tree")
