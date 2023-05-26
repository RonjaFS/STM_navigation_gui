extends VBoxContainer

var muProStepX = 0.2
var muProStepY = 0.2
# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.marker_changed.connect(update_labels)
	update_labels()
func update_labels():
	var ms = MarkerStore.get_selected_marker()
	var mt = MarkerStore.get_target_marker()
	if(ms and mt):
		var xDiff = mt.pos.x - ms.pos.x
		var yDiff = -(mt.pos.y - ms.pos.y)
		$Xnav.text = "Navigation X "+ str(int(xDiff*100)/100) +"mu ("+str(int(xDiff/muProStepX))+" steps)"
		$Ynav.text = "Navigation Y "+ str(int(yDiff*100)/100) +"mu ("+str(int(yDiff/muProStepY))+" steps)"
	else:
		$Xnav.text = "select current and target node"
		$Ynav.text = ""
