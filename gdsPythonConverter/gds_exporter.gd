extends Node
var currentNavigationImagePath
func exportFile(imagePath, gdsPath, pixelSize):
	var program = ProjectSettings.globalize_path("res://gdsPythonConverter/imageToGds.py")
	var command = program
	var command_with_params = command + " " + imagePath + " " + gdsPath + " " + str(pixelSize)
	Signals.show_path_to_convert_gds_dialog.emit(command_with_params)
#	print("execute: "+ command)
#	print("with paths: "+command+" "+imagePath+" "+gdsPath+" "+str(pixelSize))
#	var output = []
#	var err = OS.execute(command, [imagePath, gdsPath, pixelSize], output, true)
#	print("done with err:"+str(err) )
#	for o in output:
#		print(o)
#	var err2 = OS.execute("which python", [imagePath, gdsPath, pixelSize], output, true)
#	print("done with err:"+str(err) )
#	for o in output:
#		print(o)
