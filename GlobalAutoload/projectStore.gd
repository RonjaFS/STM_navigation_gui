extends Node

var patternFilePath = null
var projectName = null
var projectFilePath = null

var lastProjectPath = null
var PATH_TO_LAST_PROJECT = "user://LastProjectPath.var"

func _ready():
	Signals.new_project_pressed.connect(new_project)
	var f = FileAccess.open(PATH_TO_LAST_PROJECT, FileAccess.READ)
	if f:
		lastProjectPath = f.get_var()

func new_project():
	projectName = "New Project"
	Signals.project_changed.emit()

func save_project_to_file(customPath = ""):
	var path = "user://last_project_save.dat"
	var project = {
		"patternFile": patternFilePath,
		"markers": MarkerStore.markers,
		"selected_marker": MarkerStore._selected_marker_id,
		"target_marker": MarkerStore._target_marker_id,
		"projectName": projectName
	}
	if customPath != "":
		path = customPath
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(project)
	file.close()
	print("saved project: ", project)
	Signals.show_notification.emit("Project stored to file")


func load_project_from_file(customPath = ""):
	var path = "user://last_project_save.dat"
	if customPath != "":
		path = customPath
	self.projectFilePath = path
	var file = FileAccess.open(path, FileAccess.READ)
	var project = file.get_var()
	file.close()
	MarkerStore.markers = project.markers
	self.patternFilePath = project.patternFile
	self.projectName = project.projectName
	MarkerStore._selected_marker_id = project.selected_marker
	MarkerStore._target_marker_id = project.target_marker
	Signals.project_changed.emit()
	Signals.marker_changed.emit()
	Signals.show_notification.emit("Project loaded from file")

func set_project_name(name):
	self.projectName = name
	Signals.project_changed.emit()

func set_pattern_file(path):
	self.patternFilePath = path
	Signals.project_changed.emit()

func has_last_project():
	return lastProjectPath != null
	
func load_last_project():
	if has_last_project():
		load_project_from_file(lastProjectPath)
	else:
		Signals.show_notification.emit("Cannot load last project")
func _exit_tree():
	FileAccess.open(PATH_TO_LAST_PROJECT, FileAccess.WRITE).store_var(projectFilePath)
