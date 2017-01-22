class Quipu:
    def readKnots(self, knots):
        splitrope = knots.split('-')
        number = ""
        for idx in range(1, len(splitrope)-1):
            number += str(len(splitrope[idx]))

        return int(number)

x = Quipu()
print(x.readKnots("-XX-XXXX-XXX-"))
