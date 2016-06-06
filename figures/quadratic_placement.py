"""
A quadratic-placement demo.
"""

import sympy
from sympy.matrices import Matrix


def qp_1d(num_movable, fixed_vertices, edges):
	"""Perform quadratic placement on a graph with num_movable movable vertices
	and the supplied list of fixed_vertices with the given set of weighted edges
	between them.
	
	Parameters
	----------
	num_movable : int
		Number of movable vertices
	fixed_vertices : [x, ...]
		The location of each fixed vertex (in 1D).
	edges : [(weight, vert_num, vert_num), ...]
		The edges between vertices. Movable vertices are numbered 0 to
		len(num_movable)-1 and the fixed vertices are numbered len(num_movable) to
		(len(num_movable) + len(fixed_vertices) - 1).
	
	Returns
	-------
	[location, ...]
		The locations assigned to each movable vertex.
	"""
	
	# Create symbols for the location of each movable vertex
	symbols = list(sympy.symbols(" ".join("x{}".format(n)
	                                               for n in range(num_movable))))
	
	# Fixed vertices are just represented by their position
	symbols += list(fixed_vertices)
	
	# Create cost function
	cost = 0
	for weight, src, dst in edges:
		cost += weight * ((symbols[src] - symbols[dst])**2)
	
	# Figure out the 'b' part of the matrix
	fixed_weights_into_movables = [0] * num_movable
	for weight, src, dst in edges:
		if src < num_movable and dst >= num_movable:
			fixed_weights_into_movables[src] += weight * fixed_vertices[dst-num_movable]
		elif dst < num_movable and src >= num_movable:
			fixed_weights_into_movables[dst] += weight * fixed_vertices[src-num_movable]
	
	# Solve for movable vertices' positions
	A = sympy.hessian(cost, symbols[:num_movable])
	b = 2*Matrix(fixed_weights_into_movables)
	return [float(x) for x in A.LUsolve(b)]


def qp(movable_vertices, fixed_vertices, edges, dimensions=2):
	"""Higher level quadratic placement.
	
	Parameters
	----------
	movable_vertices : [object, ...]
	fixed_vertices : {object: location, ...}
	edges : [(weight, object, object), ...]
	dimensions : int
	
	Returns
	-------
	{object: location, ...}
	"""
	
	placements = fixed_vertices.copy()
	placements.update({v: [None]*dimensions for v in movable_vertices})
	
	num_movable = len(movable_vertices)
	
	vertices = list(movable_vertices) + list(fixed_vertices)
	vertex_indices = {v: i for i, v in enumerate(vertices)}
	
	edges_by_index = [
		(weight, vertex_indices[src], vertex_indices[dst])
		for weight, src, dst in edges
	]
	
	for dimension in range(dimensions):
		for vertex_num, vertex_position in enumerate(qp_1d(
				num_movable,
				[location[dimension] for location in fixed_vertices.values()],
				edges_by_index)):
			placements[vertices[vertex_num]][dimension] = vertex_position
	
	return {v: tuple(loc) for v, loc in placements.items()}


if __name__=="__main__":
	# Define the network
	
	# A simple 1D network
	f1 = "f_1"
	f2 = "f_2"
	fixed_vertices = {f1: (0, 0),
	                  f2: (10, 0)}
	
	m1 = "m_1"
	m2 = "m_2"
	movable_vertices = [m1, m2]
	
	edges = [(1, f1, m1),
	         (2, m1, m2),
	         (1, m2, f2)]
	
	## A 2D network
	#f1 = "f_1"
	#f2 = "f_2"
	#f3 = "f_3"
	#f4 = "f_4"
	#fixed_vertices = {f1: (0, 0),
	#                  f2: (10, 0),
	#                  f3: (0, 5),
	#                  f4: (10, 5)}
	#
	#m1 = "m_1"
	#m2 = "m_2"
	#m3 = "m_3"
	#movable_vertices = [m1, m2, m3]
	#
	#edges = [(3, f1, m1),
	#         (1, f2, m2),
	#         (2, m1, m2),
	#         (1, m1, m3),
	#         (1, m2, m3),
	#         (1, m3, f3),
	#         (2, m3, f4)]
	
	for vertex, (x, y) in qp(movable_vertices, fixed_vertices, edges).items():
		print("\\{}{{{}, {}}}{{{}}}".format(
			"fixed" if vertex in fixed_vertices else "movable", x, y, vertex))
	for weight, src, dst in edges:
		print("\\edge{{{}}}{{{}}}{{{}}}".format(weight, src, dst))

