# Opgave 16

addpath ("./lib")

# Gegeven
y = [78.83; 120.81; 38.71; 36.47; 80.61; 36.51] ;
A = [ 0 1 0 0;
      0 0 1 0;
      -1 1 0 0;
      0 0 -1 1;
      -1 0 1 0;
      0 0 -1 1;
] ;

# Vereffening volgens A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y) ;

uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 2) ;
disp('')

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 3) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 2) ;
disp('')

# Controle
nullen = A' * edakje ;

uitvoer=['Controle op A'' * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 3) ;
disp('')

