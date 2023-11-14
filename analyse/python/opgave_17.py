# Opgave 17
# Volgens A-model

import numpy as np
import lib.print_m as pm
import lib.models as models

# Gegeven
pi = np.pi

y = np.matrix('0.572; 1.153; 3.620')
A = np.matrix( [ [1], [2], [2 * pi] ] )

# Vereffening volgens A-model
xdakje, ydakje, edakje = models.amodel(A, y)

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
nullen = A.T * edakje

uitvoer= 'Controle op A.T * edakje = 0'
print(uitvoer)
pm.print_m('nullen', nullen, 5)
print('')
