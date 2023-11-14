import numpy as np
import lib.print_m as pm

# Matrix voorbeeld
A=np.matrix(' 3  5  -4; -0.5  12  2')
pm.print_m('A', A)

# Diagonaalmatrix
A=np.matrix('7; 8; 3')
A=np.diagflat(A)
pm.print_m('A',A)

# Getransponeerde matrix
A = np.matrix('3 5 -4 ; -0.5 12 2')
pm.print_m('A',A)
pm.print_m('De getransponeerde van A', A.T)

# Vierkante matrix en zijn getransponeerde
A = np.matrix('7 2 0 ; 2 8 3 ; 0 3 5')
pm.print_m('A',A)
pm.print_m('De getransponeerde van A', A.T)

# Nulmatrix
A=np.zeros((2,3))
pm.print_m('Nulmatrix', A)

# Eenheidsmatrix
I=np.eye(3)
pm.print_m('Eenheidsmatrix', I)

# Optellen en aftrekken van matrices
A=np.matrix('2 4 6 ; 1 3 5')
B=np.matrix('1 2 3 ; 0 1 2')

Som = A+B
Verschil = A-B

pm.print_m('A',A)
pm.print_m('B',B)
pm.print_m('Som',Som)
pm.print_m('Verschil',Verschil)

# Vermenigvuldigen met scalar
s=5
A=np.matrix('3.4 5.3 ; -1.0 8.7 ; 14.2 -11.4')
Product = s*A
pm.print_m('A',A)
print('s =',s)
pm.print_m('Product',Product)

# Vermenigvuldigen van matrices
A=np.matrix(' 1 2 3 ; 4 5 6')
B=np.matrix('3 6 ; 2 5 ; 1 4')
Product = A*B
pm.print_m('A',A)
pm.print_m('B',B)
pm.print_m('Product',Product)

# Inverse van matrix:
A=np.matrix('3 8 7; 2 -1 4 ; -1 6 5')
B=np.linalg.inv(A)
C=A*B
pm.print_m('A',A)
pm.print_m('B',B)
# Controle dat het product de eenheidsmatrix is
pm.print_m('C',C)