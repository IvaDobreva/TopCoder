class ComboLength:
	def howLong(self, moves):
		count = []
		length = 0
		index = 0
		begin = end = 0

		while index < len(moves):
			if moves[begin] == moves[end]:
				length += 1
				end += 1
			else:
				count.append(length)
				length = 0
				begin = end

			index += 1
			if begin == 0 and end == len(moves)-1:
				return len(moves)

		return max(count)
