class BinaryCode:
    def decode(self, message):
        q = list(message)
        flag1 = flag2 = True
        p1 = str(0)
        p2 = str(1)

        p1 += str(int(q[0]) - int(p1[0]))
        p2 += str(int(q[0]) - int(p2[0]))

        if int(p1[1]) > 1:
            p1 = "NONE"
            flag1 = False

        if int(p2[1]) > 1:
            p2 = "NONE"
            flag2 = False

        for i in range(1, len(q)-1):
            if flag1 == True:
                p1 += str(int(q[i])-(int(p1[i-1])+int(p1[i])))
                print(p1)
                if int(p1[i+1]) > 1 :
                    p1 = "NONE"
                    flag1 = False

            if flag2 == True:
                p2 += str(int(q[i])-(int(p2[i-1])+int(p2[i])))

                if int(p2[i+1]) > 1 :
                    p2 = "NONE"
                    flag2 = False

        return (p1, p2)

x = BinaryCode()
print(x.decode("12221112222221112221111111112221111"))
