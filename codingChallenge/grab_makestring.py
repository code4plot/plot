def solution(A, B, C):
    # write your code in Python 3.6
    x = [A, B, C]
    letters = ['a', 'b' ,'c'] #reference
    s= '' #initialize empty string
    #start s with two consecutive letters if possible
    for i in range(3):
        if x[i] > 1:
            j = letters[i]
            s = j * 2
            x[i] -= 2
            break
    #for case A, B, C are 1 or 0
    if s == '':
        for i in range(3):
            if x[i] > 0:
                j = letters[i]
                s += j * x[i]
                x[i] -= x[i]
        return s
    while sum(x) > 0:
        for i in range(3):
            j = letters[i]
            if x[i] > 0 and s[-1] != j:
                times = min([x[i],2])
                s += j * times
                x[i] -= times
                break
        if sum(x) == abs(x[0] - sum(x[1:3])):
            for i in range(3):
                j = letters[i]
                if x[i] > 0 and s[-1] != j:
                    times = min([x[i],2])
                    s += j * times
                    x[i] -= times
            break
    return s

def makeStr():
    #start s with two consecutive letters if possible
    for i in range(3):
        j = letters[i]
        if x[i] > 1:
            s += j * 2
            x[i] -= 2
    if s == '':
        for i in range(3):
            if x[i] > 0:
                j = letters[i]
                s += j * x[i]
                x[i] -= x[i]
    
def solution(A, B, C):
    # write your code in Python 3.6
    #for case A, B, C are 1 or 0
    global x, letters, s
    x = [A, B, C]
    letters = ['a', 'b' ,'c'] #reference
    s = ''
    while sum(x) > 0:
        makeStr()
    return s