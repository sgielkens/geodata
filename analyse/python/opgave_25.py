# Opgave 25
# Volgens A-model

import numpy as np
import lib.print_m as pm
import lib.models as models

# Gegeven
sum_hoek = 200
y = np.matrix('80.0013 ; 80.0033 ; 79.9943 ; 79.9957 ; 79.9956 ; 40.0002 ; 40.0006')
A = np.matrix('1 0; 1 0; 0 1 ; 0 1 ; 0 1 ; -1 -1 ; -1 -1 ')
a0 = np.matrix('0 ; 0 ; 0 ; 0 ; 0 ; 200 ; 200')

sigma_y = np.matrix('1 ; 1.4 ; 2 ; 2 ; 1 ; 1.4 ; 1.4')
sigma_y_diag = np.diagflat(sigma_y)
var_y = sigma_y_diag * sigma_y
Dy = np.diagflat(var_y)

Qy = Dy
Wy = np.linalg.inv(Qy)

# Vereffening volgens A-model
xdakje, ydakje, edakje = models.amodel(A, y, a0 , Wy)

uitvoer = 'Geschatte waarden voor parameters xdakje:'
print(uitvoer)
pm.print_m('xdakje', xdakje, 4)
print('')

uitvoer = 'Geschatte waarden voor toevallige afwijkingen edakje:'
print(uitvoer)
pm.print_m('edakje', edakje, 5)
print('')

uitvoer = 'Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'
print(uitvoer)
pm.print_m('ydakje', ydakje, 4)
print('')

# Controle
nullen = A.T * Wy * edakje

uitvoer= 'Controle op A.T * Wy * edakje = 0'
print(uitvoer)
pm.print_m('nullen', nullen, 5)
print('')
