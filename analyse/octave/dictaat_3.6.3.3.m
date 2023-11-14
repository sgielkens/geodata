# Vereffenen hooteverschillen B-model (dictaat 3.6.3.3)

y=[1.5760;-0.1424;-1.4290;0.7241;0.6567;-1.5290]

Qydiag=[1;2;0.5;2;1;2]
Qy=diag(Qydiag)

B=[1 1 1 0 0 0;
   0 -1 0 1 1 1]
B=B'

t=B'*y
k=inv(B'*Qy*B)*t

edakje=Qy*B*k
ydakje=y-edakje

mal='%8.4f\n'

uitvoer={'t in mm = '; sprintf(mal,t*1000);
          'edakje in mm = '; sprintf(mal,edakje*1000);
          'ydakje = '; sprintf(mal,ydakje)};

disp(char(uitvoer))

