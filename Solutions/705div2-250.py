class SuperUserDo:
    def install(self, A, B):
        installed = []
        flag = False
        s = 0
        for i in range(0, len(A)):
            for lib in range(A[i], B[i]+1):
                if lib in installed:
                    pass
                else:
                    installed.append(lib)
                    s += 1
        return s
