class SwapAndArithmetic:
	def able(self, x):
		x= sorted(x)
		diff = x[1] - x[0] 
		for idx in range(2, len(x)):
			 if (x[idx] - x[idx-1] != diff ):
			 	return "Impossible"
		return "Possible"