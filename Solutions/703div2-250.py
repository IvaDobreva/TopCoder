class AlternatingString:
	def maxLength(self, s):
		adj = []
		beg = 0
		end = len(s)
		for i in range(1, len(s)):
			if s[i] == s[i-1]:
				end = i
				adj.append(end - beg)
				beg = i
		adj.append(end-beg)
		return max(adj)	