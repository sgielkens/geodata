# Vereffenen hooteverschillen A-model (dictaat 3.6.3.4)

y=[1.5760;-0.1424;-1.4290;0.7241;0.6567;-1.5290]

Qydiag=[1;2;0.5;2;1;2]
Qy=diag(Qydiag)

hA=5

A=[ 1 0 0 0 ;
   -1 1 0 0 ;
    0 -1 0 0 ;
   -1 0 0 1 ;
    0 0 1 -1 ;
    0 1 -1 0]

a0=[-hA;0;hA;0;0;0]

W=inv(Qy)

Qxdakje=inv(A' * W * A)
xdakje=Qxdakje * A' * W * (y-a0)
ydakje=A*xdakje+a0
edakje=y-ydakje

mal='%8.4f\n'
uitvoer={'edakje in mm = ';sprintf(mal,edakje*1000)}

disp(char(uitvoer))

