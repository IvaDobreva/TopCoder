import collections
class ImageDithering:
	def count(self, dithered, screen):
		cnt = 0
		for line in screen:
			c = collections.Counter(line)
			for letter in dithered:
				cnt += c[letter]
		return cnt
