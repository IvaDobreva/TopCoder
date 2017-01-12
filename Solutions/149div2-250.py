class FormatAmt:
    def amount(self, dollars, cents):
        money = "$"
        count = 1
        stD = str(dollars)
        stC = str(cents)

        if len(stC) == 1:
            stC += "0"
            stC = stC[::-1]

        for i in range(len(stD)-1, -1, -1):
            if count%3 == 0 and i != 0:
                stD = stD[:i] + "," + stD[i:]
            count += 1
        money = "$" + stD + "." + stC

        return money

x = FormatAmt()
print(x.amount(123456 , 9))
