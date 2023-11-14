# Opgave 23

addpath ("./lib")

# Gegeven
hA= 3.250 ;

y = [-7.451; 29.795; 37.232] ;
A = [ -1, 0; -1, 1; 0, 1] ;
a0 = [hA ; 0 ; -hA] ;

var_y = [1 ; 2 ; 1] ;
Dy = diag(var_y) ;

Qy = Dy ;
Wy = inv(Qy) ;

# Vereffening volgens gewogen A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y, a0, Wy) ;

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
