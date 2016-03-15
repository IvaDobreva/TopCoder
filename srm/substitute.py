'''
An easy to remember 10-letter word or phrase, the key, is chosen. Every '1' in the value is replaced by the first letter of the key, every '2' is replaced by the second letter of the key, and so on. Every '0' is replaced by the last letter of the key. Letters that do not appear in the key can be inserted anywhere without affecting the value represented by the code.. This helps to make the resulting code much harder to break (without knowing the key).

Create a class Substitute that contains the method getValue that is given the s key and code as input and that returns the decoded value.


'''

class Substitute:
    def getValue(key, value):
        decoded = 0
        for letter in value:
            if letter in key:
                decoded *= 10
                index = key.index(letter) + 1
                decoded += (index if index != 10 else 0)
        return decoded

x = Substitute.getValue("TRADINGFEW", "LGXWEV")
y = Substitute.getValue("ABCDEFGHIJ","XJ")
z = Substitute.getValue("CRYSTALBUM","MMA")
print(x, y, z)
