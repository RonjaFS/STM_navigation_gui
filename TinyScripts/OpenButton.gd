extends Button

func _ready():
	Signals.project_changed.connect(update_button)
	update_button()

func update_button():
	self.visible = ProjectStore.projectName == null
