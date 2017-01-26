class Substitute:
    def getValue(self, key, value):
        decoded = 0
        for letter in value:
            if letter in key:
                decoded *= 10
                index = key.index(letter) + 1
                decoded += (index if index != 10 else 0)
        return decoded

x = Substitute()

print(x.getValue("TRADINGFEW", "LGXWEV"))
