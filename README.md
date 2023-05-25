# Gui Application to support a STM navigation system
 - The gui is build with the Godot engine to achieve high performance rendering of the navigation pattern.

![](./screenshots/3x3Ui_version0_0.png)

## Features
 - [x] render the navigation pattern exactly how they look on the sample.
 - [x] higlight the current location
 - [x] animate the preview window (left) to the current location
 - [x] add markers for points of interest
 - [ ] draw arrows and convert the arrows to steps for the xy-table
 - [ ] sophisticated marker system with adding/removing markers. Also notes for each marker should be supported

## The navigation system
It is based on a binary pattern that can be scanned and identified with the stm and is drawn onto a silicon sample using Electron beam lithography. \
This gui is supposed to help moving the tip to the right position by showing the current location and the calibrated xy input necessary to reach the target location.

## Get started
The most simple way to get started with the project is to install the [Godot engine](https://godotengine.org/download) and then selecting the project in the cloned folder.
Alternatively the app can be bundled und distributed as a standalone executable.
# The Klayout gsd Generation script
The second part of this repository is a Klayout python script. This script has some configurable parameters:
```py
BASE_PATH = "/$somePath/ElectronBeamLithographyFiles/"
PIXEL_SIZE = 200
# the gap between the squares/pixels that build the navpatch
GAP_PIXELS = 0
# the gap (in pixels) between two navpatches
GAP_NAVPATCHES = 1
NAVPATCHSIZE = 4
BOXSTYLE = "Lshape2" # "Lshape", "box", "grid", "Lshape"
```

This script can be used in Klayout (using the code editor behind the F5 shortcut) to generate a gds file that can be imported most of the electron beam lithography systems.


### Icons
<a href="https://www.flaticon.com/free-icons/location" title="location icons">Location icons created by kmg design - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/delete" title="delete icons">Delete icons created by Kiranshastry - Flaticon</a>