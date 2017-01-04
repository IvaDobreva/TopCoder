class DivisibleSetDiv2:
	def isPossible(seld, b):
		x = 2
		p = x*x 
		for i in range(0, len(b)):
			if x**(b[i])%p != 0:
				return "Impossible"
		return "Possible"