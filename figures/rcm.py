"""Reverse-Cuthill-McKee (RCM) algorithm demonstrator
"""

import random
import sys
import math

num_vertices = int(sys.argv[1])
num_nets = int(sys.argv[2])
net_sd_range = float(sys.argv[3])
order = sys.argv[4]
seed = int(sys.argv[5])

random.seed(seed)

class Vertex(object):
	def __init__(self):
		self.edges = set()
	def dfs(self, visited=None):
		visited = visited if visited is not None else set()
		visited.add(self)
		
		yield self
		
		for neighbour in self.edges:
			if neighbour not in visited:
				for vertex in neighbour.dfs(visited):
					yield vertex

# Generate random 1D-gaussian-connected graph
vertices = {i: Vertex() for i in range(num_vertices)}
for _ in range(num_nets):
	src = random.randrange(num_vertices)
	#sink = random.randrange(num_vertices)
	sink = int(random.gauss(src, num_vertices * net_sd_range)) % num_vertices
	
	vertices[src].edges.add(vertices[sink])
	vertices[sink].edges.add(vertices[src])

## Generate a 2D torus
#width = height = int(math.sqrt(num_vertices))
#vertices = {(x, y): Vertex() for x in range(width) for y in range(height)}
#for x in range(width):
#	for y in range(height):
#		for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
#			x2 = (x + dx) % width
#			y2 = (y + dy) % height
#			vertices[(x, y)].edges.add(vertices[(x2, y2)])
#vertices = {x + (y*width): v for (x, y), v in vertices.items()}

def hilbert(level, angle=1, s=None):
    """Generator of points along a 2D Hilbert curve.
    This implements the L-system as described on
    `http://en.wikipedia.org/wiki/Hilbert_curve`.
    Parameters
    ----------
    level : int
        Number of levels of recursion to use in generating the curve. The
        resulting curve will be `(2**level)-1` wide/tall.
    angle : int
        **For internal use only.** `1` if this is the 'positive' expansion of
        the grammar and `-1` for the 'negative' expansion.
    s : HilbertState
        **For internal use only.** The current state of the system.
    """
    # An internal (mutable) state object (note: used in place of a closure with
    # nonlocal variables for Python 2 support).
    class HilbertState(object):
        def __init__(self, x=0, y=0, dx=1, dy=0):
            self.x, self.y, self.dx, self.dy = x, y, dx, dy

    # Create state object first time we're called while also yielding first
    # position
    if s is None:
        s = HilbertState()
        yield s.x, s.y

    if level <= 0:
        return

    # Turn left
    s.dx, s.dy = s.dy*-angle, s.dx*angle

    # Recurse negative
    for s.x, s.y in hilbert(level - 1, -angle, s):
        yield s.x, s.y

    # Move forward
    s.x, s.y = s.x + s.dx, s.y + s.dy
    yield s.x, s.y

    # Turn right
    s.dx, s.dy = s.dy*angle, s.dx*-angle

    # Recurse positive
    for s.x, s.y in hilbert(level - 1, angle, s):
        yield s.x, s.y

    # Move forward
    s.x, s.y = s.x + s.dx, s.y + s.dy
    yield s.x, s.y

    # Recurse positive
    for s.x, s.y in hilbert(level - 1, angle, s):
        yield s.x, s.y

    # Turn right
    s.dx, s.dy = s.dy*angle, s.dx*-angle

    # Move forward
    s.x, s.y = s.x + s.dx, s.y + s.dy
    yield s.x, s.y

    # Recurse negative
    for s.x, s.y in hilbert(level - 1, -angle, s):
        yield s.x, s.y

    # Turn left
    s.dx, s.dy = s.dy*-angle, s.dx*angle

# Generate ordering
def hilbert_order(vertices):
	width = height = int(math.sqrt(len(vertices)))
	vertices = {(i % width, i // width): v for i, v in vertices.items()}
	
	max_dimen = max(width, height)
	hilbert_levels = int(math.ceil(math.log(max_dimen, 2.0))) if max_dimen >= 1 else 0
	
	order = []
	for x, y in hilbert(hilbert_levels):
		if (x, y) in vertices:
			order.append(vertices[(x, y)])
	
	return {v: i for i, v in enumerate(order)}

def random_order(vertices):
	vertex_list = list(vertices.values())
	random.shuffle(vertex_list)
	return {v: i for i, v in enumerate(vertex_list)}

def rcm_connected(vertices):
	peripheral_vertex = min((vertex for vertex in vertices.values()),
	                        key=(lambda v: len(v.edges)))
	
	R = [peripheral_vertex]
	while len(R) < len(vertices):
		for vertex in R:
			adjacent = sorted(vertex.edges.difference(set(R)),
			                  key=(lambda v: len(v.edges)))
			R.extend(adjacent)
	
	return {v: i for i, v in enumerate(R)}

def rcm(vertices):
	remaining_vertices = set(vertices.values())
	regions = []
	while remaining_vertices:
		region = set(remaining_vertices.pop().dfs())
		regions.append(region)
		remaining_vertices.difference_update(region)
	
	vertex_order = []
	for region in regions:
		vertex_order.extend(v for v, i in sorted(rcm_connected({i: v for i, v in enumerate(region)}).items(),
		                                         key=(lambda vi: vi[1])))
	
	return {v: i for i, v in enumerate(reversed(vertex_order))}

if order == "original":
	vertex_order = {v: i for i, v in vertices.items()}
elif order == "hilbert":
	vertex_order = hilbert_order(vertices)
elif order == "random":
	vertex_order = random_order(vertices)
elif order == "rcm":
	vertex_order = rcm(vertices)

## Render as image
#from PIL import Image
#im = Image.new("L", (num_vertices, num_vertices), "white")
#pix = im.load()
#for srcv, srci in vertex_order.items():
#	for dstv in srcv.edges:
#		dsti = vertex_order[dstv]
#		pix[srci, dsti] = 0
#im.save("out.png")

# Output as TikZ drawing commands
for srcv, srci in vertex_order.items():
	for dstv in srcv.edges:
		dsti = vertex_order[dstv]
		print(r"\pixel{{{}}}{{{}}}".format(srci, dsti))
