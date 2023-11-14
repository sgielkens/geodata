# Opgave 25

addpath ("./lib")

# Gegeven
y = [80.0013 ; 80.0033 ; 79.9943 ; 79.9957 ; 79.9956 ; 40.0002 ; 40.0006] ;
A = [ 1 0; 1 0; 0 1 ; 0 1 ; 0 1 ; -1 -1 ; -1 -1 ] ;
a0 = [ 0 ; 0 ; 0 ; 0 ; 0 ; 200 ; 200 ] ;

sigma_y = [1 ; 1.4 ; 2 ; 2 ; 1 ; 1.4 ; 1.4] ;
sigma_y_diag = diag(sigma_y) ;

var_y = sigma_y_diag * sigma_y ;
Dy = diag(var_y) ;

Qy = Dy ;
Wy = inv(Qy) ;

# Vereffening volgens gewogen A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y, a0, Wy) ;

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
nullen = A' * Wy * edakje ;

uitvoer=['Controle op A'' * Wy * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 5) ;
disp('')
