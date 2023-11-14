# Kleinste-kwadratenvereffening volgens A-model

# Input
# - modelmatrix
# - vector met waarnemingen
# - vector met constante termen, default 0

# Output
# - geschatte waarden voor parameters
# - waarden voor vereffende waarnemingen
# - geschatte waarden voor toevallige afwijkingen

import numpy as np

def amodel(A, y, a0=np.matrix('0'), Wy=np.matrix('0') ):
    a0_absent = (a0 == '0').all()
    if a0_absent:
        nr = y.shape[0]
        a0 = np.zeros((nr, 1))

    Wy_absent = (Wy == '0').all()
    if Wy_absent:
        xdakje = np.linalg.inv(A.T * A) * A.T * (y - a0)
    else:
        xdakje = np.linalg.inv(A.T * Wy * A) * A.T * Wy * (y - a0)

    ydakje = A * xdakje + a0
    edakje = y - ydakje

    return xdakje, ydakje, edakje
