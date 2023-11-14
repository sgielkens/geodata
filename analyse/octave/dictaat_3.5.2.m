# Waarnemingsvergelijking (dictaat 3.5.2)

t=[20;60;100;120]
y=[1000.02;1000.96;1001.82;1002.75]

nr=size(t,1)
e=ones(nr,1)
A=[t e]

A' * A

x=inv(A' * A) * A' * y

ydakje=A*x
edakje=y-ydakje


