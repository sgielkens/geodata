# Opgave 16
# Volgens A-model

import numpy as np
import lib.print_m as pm
import lib.models as models

# Gegeven
y = np.matrix('78.83; 120.81; 38.71; 36.47; 80.61; 36.51')
A = np.matrix( '\
    0 1 0 0; \
    0 0 1 0; \
    -1 1 0 0; \
    0 0 -1 1; \
    -1 0 1 0; \
    0 0 -1 1 \
    ')

# Vereffening volgens A-model
xdakje, ydakje, edakje = models.amodel(A, y)

uitvoer = 'Geschatte waarden voor parameters xdakje:'
print(uitvoer)
pm.print_m('xdakje', xdakje, 2)
print('')

uitvoer = 'Geschatte waarden voor toevallige afwijkingen edakje:'
print(uitvoer)
pm.print_m('edakje', edakje, 3)
print('')

uitvoer = 'Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'
print(uitvoer)
pm.print_m('ydakje', ydakje, 2)
print('')

# Controle
nullen = A.T * edakje

uitvoer= 'Controle op A.T * edakje = 0'
print(uitvoer)
pm.print_m('nullen', nullen, 3)
print('')
