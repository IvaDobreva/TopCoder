class TestTaking:
	def findMax(self, qustions, guessed, actual):
		return min(guessed, actual) + min(questions -guessed, questions - actual)