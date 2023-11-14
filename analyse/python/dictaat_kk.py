import numpy as np
import lib.print_m as pm

# A-model
print('+-------- +')
print('| A-model |')
print('+-------- +')
print('')

t = np.matrix('20;60;100;120')
y = np.matrix('1000.02;1000.96;1001.82;1002.75')

# aantal rijen van t
nr = t.shape[0]
# een vector met nr keer een 1 onder elkaar
e = np.ones((nr,1))
# naast elkaar: de kolomvector t en
# de kolomvector e
A = np.bmat('t e')

# de kleinste-kwadratenoplossing van x
x = np.linalg.inv(A.T * A) * A.T * y

pm.print_m('t',t)
pm.print_m('y',y)
pm.print_m('A',A)
pm.print_m('x',x)

# vereffende waarnemingen
# geschatte toevallige afwijkingen
ydakje = A*x
edakje = y-ydakje

pm.print_m('ydakje',ydakje)
pm.print_m('edakje',edakje)

# B-model
print('+-------- +')
print('| B-model |')
print('+-------- +')
print('')

t = np.matrix('20;60;100;120')
y = np.matrix('1000.02;1000.96;1001.82;1002.75')

# aantal rijen van t
nr = t.shape[0]
# een vector met nr keer een 1 onder elkaar
e = np.ones((nr,1))
 # naast elkaar: de kolomvector t en
# de kolomvector e
A = np.bmat('t e')

# aantal waarnemingen
m = A.shape[0]
# aantal parameters
n = A.shape[1]
# aantal overtallige waarnemingen
b = m-n

# eerste deel van A (vierkant)
A1 = A[0:n][0:n]
# tweede deel van A
# (niet noodzakelijk vierkant)
A2 = A[n:m][0:n]

# eerste deel van B
B1 = A2 * np.linalg.inv(A1)
# tweede deel van B
B2 = -np.eye(b)

B = np.bmat('B1 B2')
B = B.T
pm.print_m('B',B)
edakje = B * np.linalg.inv(B.T * B) * B.T * y
ydakje = y-edakje
pm.print_m('y dakje',ydakje)
pm.print_m('e dakje',edakje)