import numpy as np
import lib.print_m as pm

y=np.matrix('5 ; 7')
A=np.matrix('3 2 ; -1 5')

x = np.linalg.inv(A)*y
# Controle
yc = A*x

pm.print_m('y',y)
pm.print_m('A',A)
pm.print_m('x',x)
# Controle
pm.print_m('yc',yc)
