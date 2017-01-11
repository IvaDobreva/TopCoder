class RectangularGrid:
	def countRectangles(self, width, height):
		count = 0
		for rectW in range(1, width+1):
			for rectH in range(1, height+1):
				if rectW != rectH:
					for left in range(0, width-rectW+1):
						for top in range(0, height-rectH+1):
							count+=1
		return count
