def iq_method(src, dst, w, h):
    """Get a shortest path vector from src to dst in a
    hexagonal torus with dimensions w and h. For example::

        >>> iq_method((1,2,0), (5,6,1), 10, 10)
        (0, 0, -3)
    """
    # Break-apart position vectors
    sx, sy, sz = src
    dx, dy, dz = dst

    # Convert to 2D mesh coordinates
    sx, sy, sz = sx-sz, sy-sz, 0
    dx, dy, dz = dx-dz, dy-dz, 0

    # Get the 2D vector from source to destination using
    # only positive coordinates.
    dx = (dx - sx) % w
    dy = (dy - sy) % h

    # Consider each irregular quadrant
    #            Distance          Non-minimised Vector
    quadrants = [(max(dx, dy),     (dx, dy)),
                 ((w-dx)+dy,       (-(w-dx), dy)),
                 (dx+(h-dy),       (dx, -(h-dy))),
                 (max(w-dx, h-dy), (-(w-dx), -(h-dy)))]

    # Select the quadrant with the shortest path (ties
    # broken arbitrarily)
    distance, (dx, dy) = min(quadrants)

    # Return a minimised hexagonal vector
    median = sorted((dx, dy, 0))[1]
    return (dx-median, dy-median, 0-median)
