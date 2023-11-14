# Opgave 18
# Volgens A-model

import numpy as np
import lib.print_m as pm
import lib.models as models

# Gegeven
y = np.matrix('5.5; 6.5; 9.5; 10.5')
A = np.matrix('2; 3; 4; 5')

nr = A.shape[0]
eentjes = np.ones((nr,1))
A=np.bmat('A eentjes')

# Vereffening volgens A-model
xdakje, ydakje, edakje = models.amodel(A, y)

uitvoer = 'Geschatte waarden voor parameters xdakje:'
print(uitvoer)
pm.print_m('xdakje', xdakje, 1)
print('')

uitvoer = 'Geschatte waarden voor toevallige afwijkingen edakje:'
print(uitvoer)
pm.print_m('edakje', edakje, 2)
print('')

uitvoer = 'Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'
print(uitvoer)
pm.print_m('ydakje', ydakje, 1)
print('')

# Controle
nullen = A.T * edakje

uitvoer= 'Controle op A.T * edakje = 0'
print(uitvoer)
pm.print_m('nullen', nullen, 2)
print('')
