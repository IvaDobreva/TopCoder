import math

def combinations(n, k):
    div1 = math.factorial(n)
    div2 = math.factorial(k)*math.factorial(n-k)

    return div1/div2

class Lottery:

    def sortByOdds(self, rules):
        result = {}
        chance = 0

        for rule in rules:

            elements = rule.split(':')
            option = (elements[1]).split(' ')

            choices = int(option[1])
            blanks = int(option[2])
            
            if option[3] == 'T':
                sort = True
            else:
                sort = False
            
            if option[4] == 'T':
                unique = True
            else: 
                unique = False
            
            if sort == False and unique == False:
                chance = math.pow(choices, blanks)
            elif sort == True and unique == False:
                chance = combinations(choices+blanks-1, blanks)
            elif sort == False and unique == True:
                chance = (combinations(choices, blanks)*math.factorial(blanks))
            elif sort == True and unique == True:
                chance = (combinations(choices, blanks))
                   
            result[elements[0]] = chance
        return sorted(result, key=result.__getitem__)


rules = ("INDIGO: 93 8 T F",
 "ORANGE: 29 8 F T",
 "VIOLET: 76 6 F F",
 "BLUE: 100 8 T T",
 "RED: 99 8 T T",
 "GREEN: 78 6 F T",
 "YELLOW: 75 6 F F")

'''
rules = ("PICK ANY TWO: 10 2 F F"
,"PICK TWO IN ORDER: 10 2 T F"
,"PICK TWO DIFFERENT: 10 2 F T"
,"PICK TWO LIMITED: 10 2 T T")
'''
x = Lottery()
x.sortByOdds(rules)
