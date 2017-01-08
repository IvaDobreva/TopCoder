class CCipher:
	def decode(self, cipherText, shift):
		text = list(cipherText)
		for i in range(0, len(text)):
			newChar = ord(text[i])-shift
			if newChar < 65 :
				newChar = 91-(shift-(ord(text[i])-65))
			text[i] = chr(newChar)
		return "".join(text)

x = CCipher()
print(x.decode("ABCDEFGHIJKLMNOPQRSTUVWXYZ", 10))
