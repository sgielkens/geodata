# Voorwaardenvergelijking (dictaat 3.5.3)

t=[20;60;100;120]
y=[1000.02;1000.96;1001.82;1002.75]

nr=size(t,1)
e=ones(nr,1)
A=[t e]

[m,n]=size(A)
b=m-n

A1=A(1:n,1:n)
A2=A(n+1:m,1:n)

B1=A2 * inv(A1)
B2=-eye(b)

B=[B1 B2]
B=B'

B' * B

edakje=B * inv(B' * B) * B' * y
ydakje=y-edakje



