class GuessTheNumber:
	def noGuesses(self, upper, answer):
		correct = False
		lower = 1
		k = 1
		while correct == False:
			x = int((lower + upper)/2)
			if x < 	answer:
				lower = x+1
				k += 1
			elif x>answer:
				upper = x-1
				k += 1
			else:
				correct = True
		return k
			
