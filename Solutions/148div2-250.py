class DivisorDigits:
    def howMany(self, number):
        numDigits = len(str(number))
        count = 0

        for digit in range(0, numDigits):

            if int(str(number)[digit])!=0 and number%int(str(number)[digit])==0:
                count += 1
        return count

a = 52527
x = DivisorDigits
print(x.howMany(a,a))
