# Opgave 13

addpath ("./lib")

# Gegeven
y = [2.84; 15.85; 18.80] ;
A = [ 1, 0; -1, 1; 0, 1] ;

# Vereffening volgens A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y) ;

uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 3) ;
disp('')

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 4) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 3) ;
disp('')

# Controle
nullen = A' * edakje ;

uitvoer=['Controle op A'' * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 4) ;
disp('')

