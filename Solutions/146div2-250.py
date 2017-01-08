class YahtzeeScore:
	def maxPoints(self, toss):
		result =  []
		count = 0
		for i in range(0, len(toss)):
			for x in range(0, len(toss)):
				if toss[i] == toss[x]:
					count += 1
			result.append(toss[i]*count)
		return max(result)
