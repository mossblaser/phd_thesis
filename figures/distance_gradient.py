#!/usr/bin/env python
"""
Generate a heatmap showing the way distances develop in a 2D/hex mesh/torus.
"""

################################################################################
# Parse arguments
################################################################################

from argparse import ArgumentParser

def hex_colour(hex_colour):
    assert len(hex_colour) == 7
    assert hex_colour[0] == "#"
    r = int(hex_colour[1:3], 16)
    g = int(hex_colour[3:5], 16)
    b = int(hex_colour[5:7], 16)
    return (r, g, b)

parser = ArgumentParser()
parser.add_argument("output",
                    help="output filename")

parser.add_argument("--resolution", type=float, default=500.0,
                    help="pixels per unit")

parser.add_argument("--dimensions", "-d", type=float, nargs=2,
                    default=(1.0, 1.0),
                    help="dimensions of the topology to draw")
parser.add_argument("--origin", "-o", type=float, nargs=2,
                    default=(0.5, 0.5),
                    help="origin from which distances should be measured")

parser.add_argument("--near-colour", type=hex_colour,
                    default=hex_colour("#f7fbff"),
                    help="colour near the origin")
parser.add_argument("--far-colour", type=hex_colour,
                    default=hex_colour("#083675"),
                    help="colour furthest from the origin")

axis_type = parser.add_mutually_exclusive_group(required=True)
axis_type.add_argument("--2D", "-2", dest="axis", action="store_const",
                       const="2d", help="use 2D coordinates")
axis_type.add_argument("--hex", "-H", dest="axis", action="store_const",
                       const="hex", help="use hexagonal coordinates")

topology_type = parser.add_mutually_exclusive_group(required=True)
topology_type.add_argument("--mesh", "-m", dest="topology", action="store_const",
                           const="mesh", help="mesh topology")
topology_type.add_argument("--torus", "-t", dest="topology", action="store_const",
                           const="torus", help="torus topology")

args = parser.parse_args()


################################################################################
# Generate the distance map
################################################################################

# Dimensions in samples/pixels
width = int(args.dimensions[0] * args.resolution)
height = int(args.dimensions[1] * args.resolution)

def minimise_xyz(x, y, z):
    median = sorted((x, y, z))[1]
    return (x - median, y - median, z - median)

def dist_2d_mesh(x1, y1, x2, y2, w, h):
    dx = x2 - x1
    dy = y2 - y1
    return sum(map(abs, (dx, dy)))

def dist_hex_mesh(x1, y1, x2, y2, w, h):
    dx = x2 - x1
    dy = y2 - y1
    return sum(map(abs, minimise_xyz(dx, dy, 0)))

def dist_2d_torus(x1, y1, x2, y2, w, h):
    mx = w/2.0
    my = h/2.0
    
    # Translate such that x1 is in the middle
    x2 += mx - x1
    y2 += my - y1
    
    # Wrap around
    x2 %= w
    y2 %= h
    
    dx = x2 - mx
    dy = y2 - my
    
    return sum(map(abs, (dx, dy)))

def dist_hex_torus(x1, y1, x2, y2, w, h):
    # Map such that we start from bottom left and never wrap
    dx = (x2 - x1) % w
    dy = (y2 - y1) % h
    
    return min([max(dx, dy),
                w-dx+dy,
                dx+h-dy,
                max(w-dx, h-dy)])

# Select the appropriate distance function
dist_fn = globals()["dist_{}_{}".format(args.axis, args.topology)]

# Find distances to all points
distances = {}
x1, y1 = args.origin
w, h = args.dimensions
for px in range(width):
    for py in range(height):
        x2 = px / args.resolution
        y2 = py / args.resolution
        d = dist_fn(x1, y1, x2, y2, w, h)
        distances[(px, py)] = d

# Normalise distances to range 0.0-1.0
max_dist = max(distances.values())
distances = {pxy: d / max_dist for pxy, d in distances.items()}

################################################################################
# Generate the picture
################################################################################

from PIL import Image
from math import sin, cos, tan, pi, ceil

im = Image.new("RGBA", (width, height), (0, 0, 0, 0))
pix = im.load()

nr, ng, nb = args.near_colour
fr, fg, fb = args.far_colour
dr, dg, db = fr - nr, fg - ng, fb - nb

for (x, y), distance in distances.items():
    r = int(nr + (distance * dr))
    g = int(ng + (distance * dg))
    b = int(nb + (distance * db))
    a = 255
    pix[x, height-y-1] = (r, g, b, a)

# Shear if a hexagonal topology
if args.axis == "hex":
    m = tan(pi/180 * 30)  # Shear gradient
    s = cos(pi/180 * 30)  # Y scaling factor
    height = int(height * s)
    width = int(ceil(width + (height * m)))
    im = im.transform((width, height), Image.AFFINE,
                      (1, -m, 0,
                       0, 1.0/s, 0),
                      Image.BILINEAR)

im.save(args.output)
