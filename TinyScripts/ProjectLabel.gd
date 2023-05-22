extends LineEdit

func _ready():
	Signals.project_changed.connect(update_label)
	update_label()

func update_label():
	if(ProjectStore.projectName != null):
		var projectName = ProjectStore.projectName
		if(ProjectStore.patternFilePath):
			var fileName = ProjectStore.patternFilePath.get_file().get_slice(".",0)
			$"../PatternFileName".text = fileName
			$"../PatternFileName".remove_theme_color_override("font_color")
		self.text = projectName
		self.editable = true
	else:
		self.editable = false
		self.text = ""
		$"../PatternFileName".text = "No Project Pattern Selected"
		$"../PatternFileName".add_theme_color_override("font_color", Color(0.7,0.7,0.7))


func _on_focus_exited():
	ProjectStore.set_project_name(self.text)
	Signals.show_notification.emit("Project name changed")


func _on_text_submitted(new_text):
	ProjectStore.set_project_name(self.text)
	Signals.show_notification.emit("Project name changed")
