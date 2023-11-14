# Opgave 12

# Volgens B-model

y = [57.122; 76.664; 66.211]

B = [ 1; 1; 1]

b0 = [ 200 ]

t = B' * y - b0 ;
k = inv(B' * B) * t ;

edakje = B * k ;
ydakje = y - edakje ;

mal='%8.4f\n'
uitvoer={'edakje in mgon = ';sprintf(mal,edakje*1000)}

disp(char(uitvoer))

mal='%8.4f\n'
uitvoer={'ydakje in gon = ';sprintf(mal,ydakje)}

disp(char(uitvoer))
