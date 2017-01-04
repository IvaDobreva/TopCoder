class TriangleMaking:
	def maxPerimeter (self, a, b, c):
		sides = [a,b,c]
		sides.sort()
		s = sides[0] + 1
		sides[2] = sides[2] - s+1
		return sum(sides)
		