class ProfitCalculator:
	def percent( self, items):
		price = []
		cost = []
		for item in items:
			price.append(float(item.split(' ')[0]))
			cost.append(float(item.split(' ')[1]))

		totalp = sum(price)
		totalcost = sum(cost)

		percent = abs(totalp - totalcost)/totalp
		return int(percent*100)

x = ProfitCalculator()
prices = ("822.77 704.86","829.42 355.45","887.18 949.38")
print(x.percent(prices))
