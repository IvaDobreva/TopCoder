class WidgetRepairs:
    def days(self, arrivals, numPerDay):
        days = 0
        allToday = nextDay = 0
        today = 0
        maxWid = sum(arrivals)
        day = 0

        while maxWid > 0:
            allToday = nextDay + arrivals[day]

            if day < len(arrivals)-1:
                day += 1

            if allToday > numPerDay:
                nextDay = allToday - numPerDay
                today = numPerDay
            else:
                nextDay = 0
                today = allToday

            if allToday != 0:
                days += 1

            maxWid -= today


        return days

x = WidgetRepairs()
today = (100, 100 )
maxD = 10
print(x.days(today, maxD))
