class StepsConstruct:
	def construct(self, board, k):
		solution = False
		x = y = 0
		count = k
		path = ""
		pathlist = []
		n = len(board)
		m = len(board[n-1])
		while count != 0:
			if y!= (m-1) and board[x][y+1] == '.':
				path += 'D'
				count -= 1
				y+= 1
				continue
			if x!= (n-1) and board[x+1][y]=='.':
				path += 'R'
				count -= 1
				x+=1
				continue

			if x!= 0 and board[x-1][y] == '.':
				path += 'L'
				count -= 1
				x -= 1
				continue
			if y!=0 and board[x][y-1] == '.':
				path += 'U'
				count -= 1
				y -= 1
				continue

		if x!= n-1 and y!=m-1:
			return ""

		return path

loo = ("...", ".#.", "...")
loo2 = ()
x = StepsConstruct()
print(x.construct(loo, 4))
