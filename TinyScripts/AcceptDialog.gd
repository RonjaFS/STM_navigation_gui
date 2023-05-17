extends Window
var command
# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.show_path_to_convert_gds_dialog.connect(func(path):
		visible = true
		command = path
		$Box/CodeEdit.text = path
)

func _on_copy_button_pressed():
	DisplayServer.clipboard_set(command)
	visible = false


func _on_close_requested():
	visible = false
