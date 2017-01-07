class ExerciseMachine:
	def getPercentages(self, time):
		timeArr = time.split(':')
		seconds = float(timeArr[0])*3600+float(timeArr[1])*60+float(timeArr[2])
		work = part = seconds/100
		ctr = 0
		while work < seconds:
			if round(work, 2)%1 == 0:
				ctr += 1
			work += part
		return ctr 
