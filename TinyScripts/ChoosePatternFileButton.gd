extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.project_changed.connect(update_button)
	update_button()

func update_button():
	self.visible = ProjectStore.patternFilePath == null and ProjectStore.projectName != null
