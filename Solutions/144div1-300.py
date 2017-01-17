"""Bad example of solution """
def test(val):
    if val<0 or val>1:
        return False
    return True

class BinaryCode:

    def decode(self, message):

        q = [int(e) for e in message]
        binary = ()
        q.pop()

        for first in (0, 1):

            p = []
            str_result = ""
            idx = 0
            frst = True

            p.append(first)

            for el in q:
                if frst:
                    p.append(el-p[idx])

                    frst = False
                    idx += 1
                    if not test(p[idx]):
                         p = "NONE"
                         break

                    continue
                p.append(el - p[idx] - p[idx-1])
                idx += 1
                if not test(p[idx]):
                    p = "NONE"
                    break

            str_result = "".join(str(r) for r in p)
            binary += (str_result, )
        return tuple(binary)
