# Opgave 9

import numpy as np
import lib.print_m as pm

y = np.matrix('9 ; 33 ; -2')
A = np.matrix('2.6 3.1 4.2 ; 5.7 6.3 -0.5 ; -3.2 1.6 0.3')
a0 = np.matrix('-0.08 ; 0.12 ; 0.05')

x = np.linalg.inv(A) * (y-a0)
# Controle
yc = A * x + a0

pm.print_m('y', y, 1)
pm.print_m('x', x, 1)
# Controle
pm.print_m('Controle yc', yc, 1)
pm.print_m('Controle I', A*np.linalg.inv(A), 3)
