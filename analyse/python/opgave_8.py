# Opgave 8

import numpy as np
import lib.print_m as pm

y = np.matrix('15.38 ; 32.13')
A = np.matrix('2.6 3.1 ; 5.7 6.3')

x = np.linalg.inv(A) * y
# Controle
yc = A * x

pm.print_m('y', y, 2)
pm.print_m('x', x, 2)
# Contrple
pm.print_m('yc', yc, 2)
