class AlphabetOrderDiv2:
    def isOrdered(self, words):
        repeats = {}

        alphabet = []
        words = sorted(words)

        for word in words:
            for ch in word:
                if ch in alphabet:
                    

x = AlphabetOrderDiv2()
print(x.isOrdered(("topcoder", "topcoder")))
