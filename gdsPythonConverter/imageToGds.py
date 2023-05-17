#!/usr/bin/python

import klayout.db as db
from PIL import Image
import math
import sys

# Default params
PIXEL_SIZE = 200
BASE_PATH = "/home/user/Documents/patternFiles/"
FILE_NAME = "patternImage"
IMAGE_PATH = BASE_PATH+FILE_NAME+".png"
OUT_PATH = BASE_PATH+FILE_NAME+".gds"

# usage: python imageToGds.py path/to/image.png path/to/output.gds <PixelSize>


def printPercent(p):
    print(str(int(p*100))+"%")

print("")
for i, arg in enumerate(sys.argv):
    match i:
        case 1:
            IMAGE_PATH = arg
            print("Loading Image From:   ", IMAGE_PATH)
        case 2:
            OUT_PATH = arg
            print("Target File Location: ", OUT_PATH)

        case 3:
            PIXEL_SIZE = int(arg)
            print("Pixel Size:           ", PIXEL_SIZE, "\n")

# create a new gdsii layout
ly = db.Layout()

# sets the database unit to 1 nm
ly.dbu = 0.001

# adds a single top cell
top_cell = ly.create_cell("NAVIGATION_STRUCTURE")

layer1 = ly.layer(3, 0)
envelope = top_cell.dbbox().enlarged(1.0, 1.0)
top_cell.shapes(layer1).insert(envelope)

# load image
im = Image.open(IMAGE_PATH)
data = im.getdata()
pos = (0, 0)
index = 0
size = (PIXEL_SIZE*im.width, PIXEL_SIZE*im.height)
pixelRect = db.DBox(0, 0, 200, 200)
for d in data:
    pos = (index % im.width, math.floor(index/im.width))
    if (pos[0] == 0 and pos[1] % 30 == 0):
        printPercent(pos[1]/im.height)
    if d != (0, 0, 0):
        top_cell.shapes(layer1).insert(pixelRect.moved(
            pos[0]*PIXEL_SIZE, size[1] - pos[1]*PIXEL_SIZE))
    index += 1
printPercent(1.0)
print("")
# writes the layout to GDS
ly.write(OUT_PATH)

print("Export Successful, you can find the file here:\n\n"+OUT_PATH+"\n")
