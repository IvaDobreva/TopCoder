class Cross:
	def exist(self, board):
		existFlag = False
		for n in range(0, len(board)):
			for m in range(0, len(board[n])):
				if board[n][m] == '#' and n!=0 and m!=0 and n<len(board)-1 and m<len(board[n])-1:
					if board[n+1][m] == '#' and board[n-1][m] == '#' and board[n][m-1] == '#' and board[n][m+1] == '#':
						return 'Exist'
		return 'Does not exist'

x = Cross()
print(x.exist((".##", "###","##.")))
