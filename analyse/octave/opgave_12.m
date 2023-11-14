# Opgave 12
# Volgens A-model

addpath ("./lib")

# Gegeven
y = [57.122; 76.664; 66.211] ;
A = [ 1 0; 0 1; -1 -1] ;
a0 = [ 0 ; 0 ; 200 ] ;

# Vereffening volgens A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y, a0) ;

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
