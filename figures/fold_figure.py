#!/usr/bin/env python2

import sys

################################################################################
# Arguments
################################################################################

# Size of system in three-boards
width, height = map(int, sys.argv[1:3])

# "hexagon", "sheared", "sliced" or "slicedSmall"
style = sys.argv[3]

# Folds
folds = None
if len(sys.argv) > 4:
	folds = tuple(map(int, sys.argv[4:6]))


################################################################################
# Model generation
################################################################################

from spinner.board import create_torus, Board
from spinner.topology import *
from spinner.transforms import *
from spinner.diagram import Diagram

boards = create_torus(width, height)

if style == "hexagon":
	boards = hex_to_cartesian(boards)
elif style == "sheared":
	boards = hex_to_skewed_cartesian(boards)
elif style == "sliced" or style == "slicedSmall":
	rhombus_boards = hex_to_cartesian(boards)
	boards = rhombus_to_rect(rhombus_boards)
else:
	raise Exception("Unrecognised style {}".format(style))

if folds is not None:
	boards = space_folds(boards, folds, (2,2) if style=="sheared" else (1,2))

d = Diagram()
for b,p in boards:
	if style == "hexagon":
		d.add_board_hexagon(b,p, ["thick"])
	elif style == "sliced" or style == "slicedSmall":
		if p in (p for (b,p) in rhombus_boards) or folds is not None:
			# Boards which haven't been moved
			d.add_board_hexagon(b,p, ["thick" if style == "sliced" else "thin"])
		else:
			# Boards which have been moved onto the right-hand-side
			d.add_board_hexagon(b,p, ["ultra thick" if style == "sliced" else "thick"])
	elif style == "sheared":
		d.add_board_skewed_hexagon(b,p, ["thick"])
	else:
		raise Exception("Unrecognised style {}".format(style))
	
	if folds is None:
		d.add_wire(b, NORTH,      ["help lines"])
		d.add_wire(b, WEST,       ["help lines"])
		d.add_wire(b, SOUTH_WEST, ["help lines"])

# Draw boards which were sliced off
if style in ("sliced", "slicedSmall") and folds is None:
	# Mapping from a board to its sliced-off version
	sliced_board_map = {}
	for b,p in rhombus_boards:
		if p[0] < 0:
			sliced_board_map[b] = Board()
			d.add_board_hexagon(
				sliced_board_map[b],
				p,
				["help lines"] if style == "sliced" else ["help lines", "dotted"]
			)


# Produce the diagram
print(d.get_tikz())

if style in ("sliced","slicedSmall") and folds is None:
	# Add dashed line along the slice
	top_hex = d.get_tikz_ref( max( boards
	                             , key=( lambda bp:
	                                     bp[1][1]
	                                     if bp[1][0] == 0
	                                     else -1
	                                   )
	                             )[0]
	                        , WEST
	                        )
	btm_hex = d.get_tikz_ref( min( boards
	                             , key=( lambda bp:
	                                     bp[1][1]
	                                     if bp[1][0] == 0
	                                     else 999
	                                   )
	                             )[0]
	                        , SOUTH_WEST
	                        )
	
	print(r"""\draw [dashed,{}]
	                ([shift={{(0,-0.6)}}]{})
	             -- ([shift={{(0, 1.2)}}]{});
	      """.format("thick" if style == "sliced" else "help lines", btm_hex, top_hex))
	
	
	# Add an arrow indicating the move from one half to another
	max_y = max(y for (b, (x,y)) in rhombus_boards)
	top_left_boards = list(sorted(
		((b,(x,y)) for (b, (x,y)) in rhombus_boards if x < 0 and y == max_y),
		key = (lambda bp: bp[1][0]),
		reverse = True
	))
	top_mid_board = top_left_boards[len(top_left_boards)//2][0]
	
	top_left  = d.get_tikz_ref(sliced_board_map[top_mid_board], NORTH)
	top_right = d.get_tikz_ref(top_mid_board, NORTH)
	
	print(r"""\draw [->,{},rounded corners]
	                ([shift={{(0,0.2)}}]{})
	             -- ++(0,0.7)
	             -| ([shift={{(0,0.2)}}]{});
	      """.format("thick" if style == "sliced" else "help lines",top_left, top_right))
