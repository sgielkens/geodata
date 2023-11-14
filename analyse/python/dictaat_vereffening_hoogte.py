import numpy as np
import lib.print_m as pm

# Volgens B-model
print(' +-------- +' )
print(' | B-model |' )
print(' +-------- +' )
print(' ' )

y  =  np.matrix(' 1.5760; -0.1424; -1.4290; 0.7241; 0.6567; -1.5290' )
Qydiag  =  np.matrix(' 1; 2; 0.5; 2; 1; 2' )
Qy  =  np.diagflat(Qydiag)

B  =  np.matrix(' 1 1 1 0 0 0; 0 -1 0 1 1 1' )
B  =  B.T
# sluittermen
t  =  B.T*y
# correlaten
k  =  np.linalg.inv(B.T * Qy * B) * t

# geschatte toevallige afwijkingen
edakje  =  Qy * B * k
# vereffende waarnemingen
ydakje  =  y-edakje

pm.print_m(' y' ,y)
pm.print_m(' Qy diag' ,Qydiag)
pm.print_m(' B.T' ,B.T)
# uitgedrukt in mm
pm.print_m(' t' ,t*1000)

# uitgedrukt in mm
pm.print_m(' edakje' ,edakje*1000)
pm.print_m(' ydakje' ,ydakje)

# Volgens A-model
print(' +-------- +' )
print(' | A-model |' )
print(' +-------- +' )
print(' ' )

y = np.matrix('1.5760; -0.1424; -1.4290; 0.7241; 0.6567; -1.5290')
Qydiag = np.matrix('1; 2; 0.5; 2; 1; 2')
Qy = np.diagflat(Qydiag)
# hoogte van het vaste punt A
hA = 5

A = np.matrix(' 1 0 0 0 ; -1 1 0 0 ; 0 -1 0 0 ; -1 0 0 1 ; 0 0 1 -1 ; 0 1 -1 0')
a0 = np.mat([[-hA], [0], [hA], [0], [0], [0]])

# gewichtsmatrix
W = np.linalg.inv(Qy)
# inverse van de normaalmatrix
Qxdakje = np.linalg.inv(A.T * W * A)

# geschatte parameters
xdakje = Qxdakje * A.T * W * (y-a0)
# vereffende waarnemingen
ydakje = A * xdakje + a0
# geschatte toevallige afwijkingen
edakje = y - ydakje

pm.print_m('A',A)
pm.print_m('a0',a0)
pm.print_m('xdakje',xdakje)
pm.print_m('ydakje',ydakje)
# uitgedrukt in mm
pm.print_m('edakje',edakje*1000)
