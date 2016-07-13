#!/usr/bin/env python
"""
Generate distortions for various space filling curves mapping a 1D space to a
2D space.
"""

from math import ceil, log, sqrt

def _hilbert(level, angle=1, s=None):
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
    for s.x, s.y in _hilbert(level - 1, -angle, s):
        yield s.x, s.y

    # Move forward
    s.x, s.y = s.x + s.dx, s.y + s.dy
    yield s.x, s.y

    # Turn right
    s.dx, s.dy = s.dy*angle, s.dx*-angle

    # Recurse positive
    for s.x, s.y in _hilbert(level - 1, angle, s):
        yield s.x, s.y

    # Move forward
    s.x, s.y = s.x + s.dx, s.y + s.dy
    yield s.x, s.y

    # Recurse positive
    for s.x, s.y in _hilbert(level - 1, angle, s):
        yield s.x, s.y

    # Turn right
    s.dx, s.dy = s.dy*angle, s.dx*-angle

    # Move forward
    s.x, s.y = s.x + s.dx, s.y + s.dy
    yield s.x, s.y

    # Recurse negative
    for s.x, s.y in _hilbert(level - 1, -angle, s):
        yield s.x, s.y

    # Turn left
    s.dx, s.dy = s.dy*-angle, s.dx*angle


def hilbert(width):
    hilbert_levels = int(ceil(log(width, 2.0))) if width >= 1 else 0
    return _hilbert(hilbert_levels)


def row_order(width):
    for y in range(width):
        for x in range(width):
            yield (x, y)

def alternating(width):
    for y in range(width):
        for x in reversed(range(width)) if y%2 else range(width):
            yield (x, y)


def get_cost(ordering):
    ordering = list(ordering)
    for distance in range(1, len(ordering)):
        costs = []
        for a in range(len(ordering) - distance):
            b = a + distance
            if b < len(ordering):
                ## Hex mesh distance
                #x = ordering[a][0] - ordering[b][0]
                #y = ordering[a][1] - ordering[b][1]
                #z = 0
                #costs.append(max(x, y, z) - min(x, y, z))
                
                # 2D mesh distance
                costs.append(abs(ordering[a][0] - ordering[b][0]) +
                             abs(ordering[a][1] - ordering[b][1]))
                
                ## 2D euclidian distance
                #costs.append(sqrt((ordering[a][0] - ordering[b][0])**2 +
                #                  (ordering[a][1] - ordering[b][1])**2))
        yield sum(costs) / float(len(costs))

if __name__ == "__main__":
    import sys
    
    with open(sys.argv[1], "w") as f:
        width = 32
        f.write("ordering,distance,cost\n")
        for fn in [hilbert, row_order, alternating]:
            for distance, cost in enumerate(get_cost(fn(width))):
                f.write("{},{},{}\n".format(fn.__name__,
                                            distance,
                                            cost))
