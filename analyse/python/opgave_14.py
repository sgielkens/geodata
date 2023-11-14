# Opgave 14
# Volgens A-model

import numpy as np
import lib.print_m as pm
import lib.models as models

# Gegeven
hA = 3.250

y = np.matrix('-7.451; 29.795; 37.232')
A = np.matrix('-1, 0; -1, 1; 0, 1')
a0 = np.matrix( [ [hA], [0], [-hA] ] )

# Vereffening volgens A-model
xdakje, ydakje, edakje = models.amodel(A, y, a0)

uitvoer = 'Geschatte waarden voor parameters xdakje:'
print(uitvoer)
pm.print_m('xdakje', xdakje, 3)
print('')

uitvoer = 'Geschatte waarden voor toevallige afwijkingen edakje:'
print(uitvoer)
pm.print_m('edakje', edakje, 4)
print('')

uitvoer = 'Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'
print(uitvoer)
pm.print_m('ydakje', ydakje, 3)
print('')

# Controle
nullen = A.T * edakje

uitvoer= 'Controle op A.T * edakje = 0'
print(uitvoer)
pm.print_m('nullen', nullen, 4)
print('')
