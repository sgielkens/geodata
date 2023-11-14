# Opgave 17

addpath ("./lib")

# Gegeven
y = [0.572; 1.153; 3.620] ;
A = [ 1; 2; 2 * pi] ;

# Vereffening volgens A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y) ;

uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 4) ;
disp('')

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 5) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 4) ;
disp('')

# Controle
nullen = A' * edakje ;

uitvoer=['Controle op A'' * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 5) ;
disp('')

