extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	MarkerStore.connect("markers_updated",Callable(self,"update_list"))

func update_list():
	while get_child_count()>0:
		remove_child(get_children()[0])
	for m in MarkerStore.markers:
		var l = Label.new()
		l.text = JSON.stringify(m)
		add_child(l)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
