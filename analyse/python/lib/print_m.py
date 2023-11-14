import numpy as np
from numpy.linalg import inv, solve


def print_m(s, a, ndec = 4):
    print_format = "%8." + str(ndec) + "f"

    print(s + " = (" + ("%d" % a.shape[0]) + "x" + ("%d" % a.shape[1]) + ")-matrix")
    rows = a.shape[0]
    cols = a.shape[1]
    for i in range(0, rows):
        for j in range(0, cols):
            print(print_format %a[i, j], end=""),
        print("")
    print("")
