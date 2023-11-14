# Opgave 10

import numpy as np
import lib.print_m as pm

y = np.matrix('-2.2032 ; 11.2247')
A = np.matrix('0.12 -0.54 ; 0.45 0.33')
a0 = np.matrix('2.4 ; -3.4')

x = np.linalg.inv(A) * (y-a0)
# Controle
yc = A * x + a0

pm.print_m('y', y, 1)
pm.print_m('x', x, 1)
# Controle
pm.print_m('Controle yc', yc, 1)
pm.print_m('Controle I', A*np.linalg.inv(A), 3)
