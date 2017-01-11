class PeopleCircle:
    def order(self, numMales, numFemales, K):
        circle = ['M']*(numFemales+numMales)
        pos = len(circle)-1
        for i in range(0, numFemales):
                for c in range(0, K):
                    pos = (pos+1)%len(circle)
                    if circle[pos] == 'M':
                        c += 1
                circle[pos] = 'F'
        return ''.join(circle)
