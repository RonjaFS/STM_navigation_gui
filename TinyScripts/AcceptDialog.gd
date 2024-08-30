extends Window
var command

#convert into gds file for lithography
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
