class RectangularGrid:
	def countRectangles(self, width, height):
		rect  = width*(width+1)*height*(height+1)/4
		squares = 0
		for i in range(1, min(width,height)+1):
			squares += (width-i+1)*(height-i+1)
		return rect-squares
