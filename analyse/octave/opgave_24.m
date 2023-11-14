# Opgave 24

addpath ("./lib")

# Gegeven
y = [17.309; -7.451; 29.783; -9.841; 37.232] ;
A = [ 1, 0, -1; -1, 0, 0; -1, 1, 0; 0, 0, 1; 0, 1, 0] ;

var_y = [2 ; 2 ; 3 ; 1 ; 1] ;
Dy = diag(var_y) ;

Qy = Dy ;
Wy = inv(Qy) ;

# Vereffening volgens gewogen A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y, 0, Wy) ;

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
nullen = A' * Wy * edakje ;

uitvoer=['Controle op A'' * Wy * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 4) ;
disp('')
