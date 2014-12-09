import math

class Bonuses:
        def getDivision(self, points):
            total = sum(points)
            bonuses = ()
            array = []
            for employee in points:
                bonus = math.modf((employee*100.0/total))
                print bonus
                array.append(int(bonus[1]))
            
            cnt = 100-sum(array)
            copy=array[:]
            print cnt, total, len(points)
            copy.sort(reverse = True)
            for i in range(cnt):
                array[array.index(copy[i])]+=1

            return tuple(array)
                

points = {485, 324, 263, 143, 470, 292, 304, 188, 100, 254, 296,
         255, 360, 231, 311, 275,  93, 463, 115, 366, 197, 470}
x = Bonuses()
x.getDivision(points)
